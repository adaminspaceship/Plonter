//
//  Colors.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
	
	// MARK: Color Variables
	static let yellow = "F1C40F"
	static let orange = UIColor(red:1.00, green:0.50, blue:0.31, alpha:1.0)
	static let pink = UIColor(red:1.00, green:0.42, blue:0.51, alpha:1.0)
	static let blue = "2C3E50"
	static let green = UIColor(red:0.48, green:0.93, blue:0.62, alpha:1.0)
	
	static let colorArray = [UIColor(red:0.93, green:0.80, blue:0.41, alpha:1.0), UIColor(red:1.00, green:0.50, blue:0.31, alpha:1.0), UIColor(red:1.00, green:0.42, blue:0.51, alpha:1.0), UIColor(red:0.44, green:0.63, blue:1.00, alpha:1.0), UIColor(red:0.48, green:0.93, blue:0.62, alpha:1.0)]
	
	static let hexColorArray: [String] = [
		"F1C40F",
		"3498DB",
		"1ABC9C",
		"16A085",
		"2C3E50",
		"E67E22",
		"C0392B",
		"7F8C8D",
		"ECF0F1"
	]
	
	// MARK: Functions
	static func randomizeColor() -> UIColor {
		return colorArray.randomElement()!
	}
	static func randomizeHexColor() -> String {
		return hexColorArray.randomElement()!
	}
}
