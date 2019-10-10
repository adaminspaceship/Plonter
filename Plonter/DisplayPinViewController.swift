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
		secondsStepper.maximumValue = 6 // change later on
		secondsStepper.value = 1
		hideButton(button: doneButton, shouldHide: true)
    }
    
	@IBAction func didPressSharePin(_ sender: Any) {
		createURL()
	}
	
	func hideButton(button: UIButton, shouldHide: Bool){
		doneButton.isEnabled = !shouldHide
	}
	
	@IBAction func didPressDone(_ sender: Any) {
		let newPartyRef = Database.database().reference().child("Parties").child(partyID)
		newPartyRef.child("totalMembers").setValue(String(secondsStepper.value))
		self.performSegue(withIdentifier: "toCreateParty", sender: self)
	}
	
	@IBAction func secondsStepperChanged(_ sender: UIStepper) {
		hideButton(button: doneButton, shouldHide: false)
		//if statement for member/members
		if sender.value == 1 {
			self.hideButton(button: self.doneButton, shouldHide: true)
			self.secondsToJoin.text = "\(Int(sender.value)) party member"
		} else {
			self.secondsToJoin.text = "\(Int(sender.value)) party members"
		}
		
	}
	
	func createNewParty() {
		let newPartyRef = Database.database().reference().child("Parties").childByAutoId()
		let partyPin = fourUniqueDigits
		let user_id = UserDefaults.standard.string(forKey: "user_name")
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
		activityIndicator.startAnimating()
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
		shareLink?.socialMetaTagParameters?.imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/plonter-c4edb.appspot.com/o/Icon.png?alt=media&token=f68c5816-688d-4ccd-9fc3-cad6992e40c0")
		guard let longURL = shareLink?.url else { return }
		print(longURL)
		
		shareLink?.shorten(completion: { (url, warnings, error) in
			// finished shortening url
			self.activityIndicator.stopAnimating()
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
			let items = ["Join my party at Plonter!",url] as [Any]
			let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
			Utilities.vibratePhone(.Peek)
			self.present(ac, animated: true)
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
