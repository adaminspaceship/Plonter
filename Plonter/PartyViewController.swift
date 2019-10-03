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
	
	@IBOutlet weak var currentPartyMemberCount: UILabel!
	@IBOutlet weak var readyButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		getParty()
    }
	
	func getParty() {
		let ref = Database.database().reference().child("Parties").child(partyID).child("members")
		ref.observe(.value) { (snapshot) in
			let members = JSON(snapshot.value!)
			
			self.currentPartyMemberCount.text = String(members.count) // change current party member count
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
		
	}
	
	@IBAction func readyButtonTapped(_ sender: UIButton) {
		sender.isSelected = true
		sender.setBackgroundColor(color: UIColor(hexString: myColor), forState: .selected)
		sender.setTitleColor(sender.backgroundColor?.isDarkColor == true ? .white : .black, for: .selected)
		sender.layer.borderColor = UIColor.black.cgColor
		sender.layer.cornerRadius = 8
		sender.clipsToBounds = true
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
