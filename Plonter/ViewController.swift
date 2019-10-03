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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let defaults = UserDefaults.standard
		if firstLaunch() { defaults.set(UUID().uuidString, forKey: "user_id") }
		// Do any additional setup after loading the view.
	}
	
	func firstLaunch()->Bool{
		let defaults = UserDefaults.standard
		if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
			print("App already launched")
			return false
		} else {
			defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
			print("App launched first time")
			return true
		}
	}
	
}

