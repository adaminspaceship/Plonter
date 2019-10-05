//
//  ViewController.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
	
	@IBOutlet weak var hiNameLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		let userDefaults = UserDefaults.standard
		if let user_name = userDefaults.string(forKey: "user_name") {
			self.hiNameLabel.text = "Hi, \(user_name)!"
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		if Utilities.firstLaunch() {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let userCreateViewController = storyboard.instantiateViewController(withIdentifier: "UserCreateViewController")
			userCreateViewController.modalPresentationStyle = .formSheet
			if #available(iOS 13.0, *) {
				userCreateViewController.isModalInPresentation = true
			} else {
				// Fallback on earlier versions
			}
			self.present(userCreateViewController, animated: true, completion: nil)
		}
	}
	
	
	
}

