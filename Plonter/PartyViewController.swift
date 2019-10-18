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
import AVFoundation

class PartyViewController: UIViewController {
	
	var player:AVAudioPlayer!
	var myColor = String()
	var partyID = String()
	var isCreator = Bool()
	var timer: Timer?
	@IBOutlet weak var secondsLeft: UILabel!
	@IBOutlet weak var myColorView: UIView!
	@IBOutlet weak var myColorLabel: UILabel!
	var bubbles = [UIView]()
	@IBOutlet weak var joinedThePartyLabel: UILabel!
	var totalMembers = Int()
	
	
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
		myColorLabel.textColor = myColorView.backgroundColor?.isDarkColor == true ? .white : .black
		UIApplication.shared.isIdleTimerDisabled = true
		
		ref.child("totalMembers").observe(.value) { (snapshot) in
			if snapshot.exists() {
				let totalMembersJSON = JSON(snapshot.value!)
				self.totalMembers = totalMembersJSON.intValue
				self.shouldStart()
			} else {
				self.totalMembers = 999
			}
		}
		
		ref.observeSingleEvent(of: .value) { (snapshot) in
			let partyJSON = JSON(snapshot.value!)
			let partyPin = partyJSON["pin"].stringValue
			self.myColorLabel.text = "Party Pin: \(partyPin)"
		}
    }
	
	func canDismiss() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.view.addGestureRecognizer(tap)
	}
	@objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
		// fade out applause/aww
		player.setVolume(0, fadeDuration: 2)
		// handling code
		self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
	}
	var membersAdded = 0
	func getParty() {
		var latestMemberXCoordinates = self.view.frame.width/4
		var latestMemberYCoordinates = 213
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("members").observe(.childAdded) { (snapshot) in
			let memberHEX = JSON(snapshot.key).stringValue
			print("snapshot: \(snapshot.value!)")
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
			self.membersAdded += 1
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
			
			if self.membersAdded == self.totalMembers {
				self.shouldStart()
			} else if self.totalMembers == 999 {
				print("Waiting for host to start")
				self.secondsLeft.text = "Waiting for host to start"
			} else {
				print("members added: \(self.membersAdded), total members: \(self.totalMembers)")
				self.secondsLeft.text = "Waiting for \(self.totalMembers-self.membersAdded) more to join" // change
			}
			
		}
		
	}
	
	
	func shouldStart() {
		let ref = Database.database().reference().child("Parties").child(partyID)
		if !(timer?.isValid ?? false ) {
			if self.isCreator {
				// start game
				ref.child("shouldStart").setValue(true)
				self.startTimer()
			} else if !self.isCreator {
				self.startClientTimer()
			}
		}
	}
	
	func startTimer() {
		playAudio("final")
		self.secondsLeft.isHidden = true
		timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(animatebubbles), userInfo: nil, repeats: false)
	}
	
	func startClientTimer() {
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("shouldStart").observe(.value) { (snapshot) in
			if snapshot.exists() {
				self.startTimer()
			}
		}
	}
	
	@objc func animatebubbles() {
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
			label.text = "You Won ⭐️"
			label.textColor = self.view.backgroundColor?.isDarkColor == true ? .white : .black
			playAudio("applause")
			// adding confetti
			let confettiView = SAConfettiView(frame: self.view.bounds)
			self.view.addSubview(confettiView)
			confettiView.startConfetti()
		} else {
			// you lose
			label.text = "\(winnerName) Won"
			label.textColor = self.view.backgroundColor?.isDarkColor == true ? .white : .black
			playAudio("aww")
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
