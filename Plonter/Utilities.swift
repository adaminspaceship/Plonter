//
//  Utilities.swift
//  Plonter
//
//  Created by Adam Eliezerov on 05/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import Foundation

struct Utilities {
	static func firstLaunch()->Bool{
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
