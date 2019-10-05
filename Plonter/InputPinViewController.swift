//
//  InputPinViewController.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import PinCodeTextField
import FirebaseDatabase
import SwiftyJSON

class InputPinViewController: UIViewController, PinCodeTextFieldDelegate {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var pinCodeField: PinCodeTextField!
	var partyID = String()
	var myColor = String()
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		pinCodeField.delegate = self
		pinCodeField.keyboardType = .numberPad
		pinCodeField.becomeFirstResponder()
		//Looks for single or multiple taps.
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
    }
	
	// add member to party

	func textFieldDidEndEditing(_ textField: PinCodeTextField) {
		// check if textfield is blank
		if textField.text != "" && textField.text != nil{
			shouldJoinParty(textField)
		}
		
	}
	
	func shouldJoinParty(_ textField: PinCodeTextField) {
		activityIndicator.startAnimating()
		let pinCode = textField.text ?? ""
		let partyRef = Database.database().reference().child("Parties")
		let ref = partyRef.queryOrdered(byChild: "pin").queryEqual(toValue: pinCode)
		let user_id = UserDefaults.standard.string(forKey: "user_name")
		ref.observeSingleEvent(of: .value) { (snapshot) in
			let postDict = snapshot.value as? [String : AnyObject] ?? [:]
			if postDict.isEmpty {
				// party doesn't exist
				self.activityIndicator.stopAnimating()
			} else {
				// party exists
				for item in postDict.keys {
					self.partyID = item
					let members = JSON(postDict[item])["members"]
					let randomColor = Colors.randomizeHexColor()
					if members[randomColor].stringValue != "" {
						// change color first
						let newRandomColor = Colors.randomizeHexColor()
						partyRef.child(item).child("members").child(newRandomColor).setValue(user_id!)
						self.myColor = newRandomColor
					} else {
						// create the user with this color
						partyRef.child(item).child("members").child(randomColor).setValue(user_id!)
						self.myColor = randomColor
					}
					self.activityIndicator.stopAnimating()
					Utilities.vibratePhone(.Peek)
					self.performSegue(withIdentifier: "toParty", sender: self)
				}
			}
			
		}
	}

	
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		let partyViewController = segue.destination as? PartyViewController
		partyViewController?.partyID = self.partyID
		partyViewController?.myColor = self.myColor
		partyViewController?.isCreator = false
    }
    
	
	//Calls this function when the tap is recognized.
	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}

}
