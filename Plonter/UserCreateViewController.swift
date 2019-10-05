//
//  UserCreateViewController.swift
//  Plonter
//
//  Created by Adam Eliezerov on 05/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit

class UserCreateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		firstNameTextField.becomeFirstResponder()
		let userDefaults = UserDefaults.standard
		if let user_name = userDefaults.string(forKey: "user_name") {
			firstNameTextField.text = user_name
		}
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
    }
    
	@IBOutlet weak var firstNameTextField: UITextField!
	
	
	@IBAction func primaryActionTrigger(_ sender: Any) {
		if firstNameTextField.text != "" {
			let alert = UIAlertController(title: "Is \(self.firstNameTextField.text ?? "N/A") Your Name?", message: "Make sure this is your name. You can not change this later", preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "I'm Sure", style: .default, handler: { (alertAction) in
				let userDefaults = UserDefaults.standard
				userDefaults.set(self.firstNameTextField.text, forKey: "user_name")
				self.continueToApp()
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func continueToApp() {
		self.performSegue(withIdentifier: "toTabBar", sender: self)
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
	//Calls this function when the tap is recognized.
	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
    

}
