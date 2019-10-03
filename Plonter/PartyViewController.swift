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
	var mainTimer: Timer?
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
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
			mainTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(timerDidComplete), userInfo: nil, repeats: false)
		} else {
			self.checkTime()
		}
		
	}
	
	@objc func updateTimer(_ sender: Timer) {
		let timeRemaining = mainTimer!.fireDate.timeIntervalSince(Date())
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("timer").setValue(timeRemaining.stringFromTimeInterval())
		secondsLeft.text = "\(timeRemaining.stringFromTimeInterval()) seconds left to join"
	}
	
	func checkTime() {
		let ref = Database.database().reference().child("Parties").child(partyID)
		ref.child("timer").observe(.value) { (snapshot) in
			let timeleft = snapshot.value!
			self.secondsLeft.text = "\(timeleft) seconds left to join"
		}
	}
	
	@objc func timerDidComplete(_ sender: Timer) {
		print("done")
		timer?.invalidate()
		// do animation pick winner
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
