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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		getParty()
		myColorView.backgroundColor = UIColor(hexString: myColor)
		myColorView.tintColor = UIColor(hexString: myColor)
//		myColorView.
		myColorLabel.textColor = myColorView.backgroundColor?.isDarkColor == true ? .white : .black
    }
	
	func getParty() {
		let ref = Database.database().reference().child("Parties").child(partyID)
		var secondsToJoinPicked = Int()
		ref.child("members").observe(.value) { (snapshot) in
			let members = JSON(snapshot.value!)
			
			var latestMemberXCoordinates = self.view.frame.width/4
			var latestMemberYCoordinates = 213
			for member in members {
				if latestMemberXCoordinates > self.view.frame.width { latestMemberXCoordinates = self.view.frame.width/4 ; latestMemberYCoordinates+=125 }
				let bubble = UIView(frame: CGRect(x: Int(latestMemberXCoordinates), y: latestMemberYCoordinates, width: 1, height: 1))
//				self.memberArray.append(member.0)
//				print(self.memberArray)
				//customise bubble
				let userColor = UIColor(hexString: "#\(member.0)")
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
				latestMemberXCoordinates+=200
				
			}
		}
		
		// create timer if creator - maybe change so user picks time
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
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
		ref.child("endTime").observeSingleEvent(of: .value) { (snapshot) in
			let endTime = snapshot.value as! String
			self.endTime = Int(endTime)!
			
		}
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClientTimer), userInfo: nil, repeats: true)
	}
	@objc func updateClientTimer(_ sender: Timer) {
		let secondsRemaining = self.endTime-Int(Date().timeIntervalSince1970)
		self.secondsLeft.text = "\(secondsRemaining) seconds left to join"
		if secondsRemaining == 0 { self.animatebubbles() }
	}
	
	func animatebubbles() {
		timer?.invalidate()
		secondsLeft.isHidden = true
		if isCreator {
			let ref = Database.database().reference().child("Parties").child(partyID)
			ref.child("members").observeSingleEvent(of: .value) { (snapshot) in
				var members = [String]()
				for item in snapshot.children {
					members.append((item as AnyObject).key)
				}
				let winner = members.randomElement()!
				ref.child("winner").setValue(winner)
				self.checkIfWinner(winner)
			}
		} else {
			let ref = Database.database().reference().child("Parties").child(partyID)
			ref.child("winner").observe(.value) { (snapshot) in
				if let winner = snapshot.value! as? String {
					print(winner)
					self.view.backgroundColor = UIColor(hexString: winner)
					self.checkIfWinner(winner)
				}
			}
		}
		
	}
	
	
	
	func checkIfWinner(_ winnerHEX: String) {
		
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
		label.font = UIFont.systemFont(ofSize: 55, weight: .semibold)
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
			label.text = "You Lost ☹️"
			label.textColor = self.view.backgroundColor?.isDarkColor == true ? .white : .black
		}
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
