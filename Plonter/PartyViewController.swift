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


class PartyViewController: UIViewController {
	
	var myColor = String()
	var partyID = String()
	var isCreator = Bool()
	var timer: Timer?
	@IBOutlet weak var readyButton: UIButton!
	@IBOutlet weak var secondsLeft: UILabel!
	@IBOutlet weak var myColorView: UIView!
	@IBOutlet weak var myColorLabel: UILabel!
	
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
		ref.child("members").observe(.value) { (snapshot) in
			let members = JSON(snapshot.value!)
			
			var latestMemberXCoordinates = self.view.frame.width/4
			var latestMemberYCoordinates = 213
			for member in members {
				if latestMemberXCoordinates > self.view.frame.width { latestMemberXCoordinates = self.view.frame.width/4 ; latestMemberYCoordinates+=125 }
				let bubble = UIView(frame: CGRect(x: Int(latestMemberXCoordinates), y: latestMemberYCoordinates, width: 1, height: 1))
				
				//customise bubble
				let userColor = UIColor(hexString: "#\(member.0)")
				bubble.backgroundColor = userColor
				bubble.tintColor = userColor
				bubble.layer.cornerRadius = bubble.frame.size.width/2
				bubble.clipsToBounds = true
				//add bubble to subview
				self.view.addSubview(bubble)
				UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations:  {
					bubble.transform = CGAffineTransform(scaleX: 85, y: 85)
				})
				latestMemberXCoordinates+=200
			}
		}
		
		// create timer if creator - maybe change so user picks time
		if self.isCreator {
			let endTime = Int(Date().timeIntervalSince1970)+30 // change depending on user
			startTimer(endTime)
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
				self.view.backgroundColor = UIColor(hexString: winner)
			}
		} else {
			sleep(1)
			let ref = Database.database().reference().child("Parties").child(partyID)
			ref.child("winner").observe(.value) { (snapshot) in
				let winner = snapshot.value!
				print(winner)
				self.view.backgroundColor = UIColor(hexString: winner as! String)
			}
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
