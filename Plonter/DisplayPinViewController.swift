//
//  DisplayPinViewController.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseDynamicLinks

class DisplayPinViewController: UIViewController {
	
	@IBOutlet weak var secondsStepper: UIStepper!
	@IBOutlet weak var secondsToJoin: UILabel!
	// MARK: Declare Variables
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var pinLabel: UILabel!
	@IBOutlet var PinDigits: [UILabel]!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	var myColor = String()
	var partyID = String()
	var fourUniqueDigits: String {
		var result = ""
		repeat {
			// create a string with up to 4 leading zeros with a random number 0...9999
			result = String(format:"%04d", arc4random_uniform(10000) )
			// generate another random number if the set of characters count is less than four
		} while result.count < 4
		return result    // ran 5 times
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// hide while loading
		toggleHide(shouldHide: true)
		createNewParty()
		secondsStepper.minimumValue = 1
		secondsStepper.maximumValue = 6
    }
    
	@IBAction func didPressSharePin(_ sender: Any) {
//		let items = ["This app is my favorite"]
//		let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//		present(ac, animated: true)
		createURL()
	}
	
	@IBAction func didPressDone(_ sender: Any) {
		let newPartyRef = Database.database().reference().child("Parties").child(partyID)
		newPartyRef.child("secondsToJoin").setValue(String(Int(secondsStepper.value)*10))
		self.performSegue(withIdentifier: "toCreateParty", sender: self)
	}
	
	@IBAction func secondsStepperChanged(_ sender: UIStepper) {
		secondsToJoin.text = "\(Int(sender.value)*10) seconds to join party"
	}
	
	func createNewParty() {
		let newPartyRef = Database.database().reference().child("Parties").childByAutoId()
		let partyPin = fourUniqueDigits
		let user_id = UserDefaults.standard.string(forKey: "user_id")
		partyID = newPartyRef.key!
		myColor = Colors.randomizeHexColor()
		
		newPartyRef.setValue(["members":[myColor:user_id],"pin":partyPin,"secondsToJoin":Int(secondsStepper.value)])
		toggleHide(shouldHide: false)
		for digit in PinDigits {
			digit.text = partyPin[digit.tag]
		}
	}
	
	func toggleHide(shouldHide: Bool) {
		shareButton.isHidden = shouldHide
		doneButton.isHidden = shouldHide
		pinLabel.isHidden = shouldHide
		for num in PinDigits { num.isHidden = shouldHide }
		// activating or switching off activity indicator
		if shouldHide { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		let partyViewController = segue.destination as? PartyViewController
		partyViewController?.partyID = partyID
		partyViewController?.isCreator = true
		partyViewController?.myColor = myColor
    }

	
	func createURL() {
		
		var components = URLComponents()
		components.scheme = "https"
		components.host = "plonterapp.page.link"
		components.path = "/parties"
		
		let partyQueryItem = URLQueryItem(name: "party", value: partyID)
		components.queryItems = [partyQueryItem]
		
		guard let linkParamater = components.url else { return }
		print(linkParamater.absoluteString)
		
		
		let shareLink = DynamicLinkComponents.init(link: linkParamater, domainURIPrefix: "https://plonterapp.page.link")
		
		if let bundleID = Bundle.main.bundleIdentifier {
			shareLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
		}
		shareLink?.iOSParameters?.appStoreID = "1482395143" // change to my bundleid
		shareLink?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
		shareLink?.socialMetaTagParameters?.title = "Join my party in Plonter!"
		
		guard let longURL = shareLink?.url else { return }
		print(longURL)
		
		shareLink?.shorten(completion: { (url, warnings, error) in
			if let error = error {
				print("got an error: \(error)")
			}
			if let warnings = warnings {
				for warning in warnings {
					print("warning: \(warning)")
				}
			}
			
			guard let url = url else { return }
			print("short url: \(url)")
		})
		
	}

}



extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}
