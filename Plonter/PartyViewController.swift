//
//  PartyViewController.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON
import SAConfettiView


class PartyViewController: UIViewController {
	
	var myColor = String()
	var partyID = String()
	var isCreator = Bool()
	var timer: Timer?
	@IBOutlet weak var secondsLeft: UILabel!
	@IBOutlet weak var myColorView: UIView!
	@IBOutlet weak var myColorLabel: UILabel!
	var memberArray = [String]()
	var bubbles = [UIView]()
	@IBOutlet weak var joinedThePartyLabel: UILabel!
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("winner").observe(.value) { (snapshot) in
			if snapshot.exists() {
				// party done already
				self.joinedThePartyLabel.text = "Someone already won"
				self.canDismiss()
			} else {
				self.getParty()
			}
		}
		myColorView.backgroundColor = UIColor(hexString: myColor)
		myColorView.tintColor = UIColor(hexString: myColor)
//		myColorView.
		myColorLabel.textColor = myColorView.backgroundColor?.isDarkColor == true ? .white : .black
		UIApplication.shared.isIdleTimerDisabled = true
		
		ref.child("pin").observeSingleEvent(of: .value) { (snapshot) in
			let partyPin = snapshot.value as? String
			self.myColorLabel.text = "Party Pin: \(partyPin ?? "N/A")"
		}
    }
	
	
	func canDismiss() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.view.addGestureRecognizer(tap)
	}
	@objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
		// handling code
		self.performSegue(withIdentifier: "toMain", sender: self)
	}
	
	
	func getParty() {
		var latestMemberXCoordinates = self.view.frame.width/4
		var latestMemberYCoordinates = 213
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("members").observe(.childAdded) { (snapshot) in
			let memberHEX = JSON(snapshot.key).stringValue
			if latestMemberXCoordinates > self.view.frame.width { latestMemberXCoordinates = self.view.frame.width/4 ; latestMemberYCoordinates+=125 }
			let bubble = UIView(frame: CGRect(x: Int(latestMemberXCoordinates), y: latestMemberYCoordinates, width: 1, height: 1))
			let userColor = UIColor(hexString: "#\(memberHEX)")
			bubble.backgroundColor = userColor
			bubble.tintColor = userColor
			bubble.layer.cornerRadius = bubble.frame.size.width/2
			bubble.clipsToBounds = true
			//add bubble to subview
			self.view.addSubview(bubble)
			self.bubbles.append(bubble)
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations:  {
				bubble.transform = CGAffineTransform(scaleX: 85, y: 85)
			})
			self.joinedThePartyLabel.text = "\(JSON(snapshot.value!).stringValue) joined the party!"
			self.joinedThePartyLabel.alpha = 0
			
			UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
				self.joinedThePartyLabel.alpha = 1.0
			}) { (yes) in
				UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
					self.joinedThePartyLabel.alpha = 0
				}, completion: nil)
			}
			latestMemberXCoordinates+=200
		}
		
		if self.isCreator {
			ref.child("secondsToJoin").observeSingleEvent(of: .value) { (snapshot) in
				let endTime = Int(Date().timeIntervalSince1970)+Int(snapshot.value as! String)! // change depending on user
				self.startTimer(endTime)
			}
		} else {
			self.startClientTimer()
		}
		
		
		
	}
	
	func startTimer(_ endTime: Int) {
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("endTime").setValue(String(endTime))
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
		self.endTime = endTime
		
	}
	var endTime = Int()
//	ref.child("endTime").observe(.value) { (snapshot) in
//		let retrievedEndTime =
//	}
	
	@objc func updateTimer(_ sender: Timer) {
		let secondsRemaining = self.endTime-Int(Date().timeIntervalSince1970)
		secondsLeft.text = "\(secondsRemaining) seconds left to join"
		if secondsRemaining == 0 { self.animatebubbles() }
	}
//	let retrievedEndTime = Date(timeIntervalSince1970: Double(endTime))
	func startClientTimer() {
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("endTime").observe(.value) { (snapshot) in
			if snapshot.exists() {
				let endTime = snapshot.value as? String
				self.endTime = Int(endTime!)!
				self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
			}
		}
		
	}
	func animatebubbles() {
		timer?.invalidate()
		secondsLeft.isHidden = true
		if isCreator {
			let ref = Database.database().reference().child("Parties").child(partyID)
			ref.child("members").observeSingleEvent(of: .value) { (snapshot) in
				var members = [String:String]()
				for item in snapshot.children {
					let newItem = item as! DataSnapshot
					let memberHex = String(newItem.key)
					let memberName = newItem.value
					members[memberHex] = memberName as? String
				}
				let winner = members.randomElement()!
				ref.child("winner").setValue(winner.key)
				self.checkIfWinner(winnerHEX: winner.key, winnerName: winner.value)
			}
		} else {
			let ref = Database.database().reference().child("Parties").child(partyID)
			ref.observe(.value) { (snapshot) in
				let json = JSON(snapshot.value!)
				let winnerHEX = json["winner"].stringValue
				let winnerName = json["members"][winnerHEX].stringValue
				self.checkIfWinner(winnerHEX: winnerHEX, winnerName: winnerName)
				
			}
		}
		
	}
	
	
	
	func checkIfWinner(winnerHEX: String, winnerName: String) {
		
		// hiding
		for bubble in self.bubbles {
			bubble.removeFromSuperview()
		}
		self.secondsLeft.isHidden = true
		self.myColorView.isHidden = true
		self.myColorLabel.isHidden = true
		let fillScreenView = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 1, height: 1))
		fillScreenView.backgroundColor = UIColor(hexString: winnerHEX)
		fillScreenView.tintColor = UIColor(hexString: winnerHEX)
		fillScreenView.cornerRadius = fillScreenView.frame.width/2
		self.view.addSubview(fillScreenView)
		
		// create text label
		let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y, width: 300, height: 85))
		label.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
		//animate background
		UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations:  {
			fillScreenView.transform = CGAffineTransform(scaleX: 1000, y: 1000)
			self.view.addSubview(label)
		})
		
		// add sound
		if myColor == winnerHEX {
			// you win
			print("you won!")
			label.text = "You Won ⭐️"
			label.textColor = self.view.backgroundColor?.isDarkColor == true ? .white : .black
			// adding confetti
			let confettiView = SAConfettiView(frame: self.view.bounds)
			self.view.addSubview(confettiView)
			label.sendSubviewToBack(confettiView)
			confettiView.startConfetti()
		} else {
			// you lose
			print("you lost!")
			label.text = "\(winnerName) Won ☹️"
			label.textColor = self.view.backgroundColor?.isDarkColor == true ? .white : .black
		}
		self.canDismiss()
	}

	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
