//
//  AppDelegate.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
//		FirebaseOptions.defaultOptions()?.deepLinkURLScheme = customURLScheme
		FirebaseApp.configure()
		return true
	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}

	

	// MARK: UISceneSession Lifecycle
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		if let incomingURL = userActivity.webpageURL {
			print("incoming URL is \(incomingURL)")
			let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamiclink, error) in
				guard error == nil else {
					print("found error: \(error!.localizedDescription)")
					return
				}
				if let dynamiclink = dynamiclink {
					self.handleincomingDynamicLink(dynamiclink)
				}
			}
			return linkHandled
		}
		return false
	}
	
	
	func handleincomingDynamicLink(_ dynamicLink: DynamicLink) {
		guard let url = dynamicLink.url else {
			print("nope")
			return
		}
		print(url)
		
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
		let queryItems = components.queryItems
		
		if components.path == "/parties" {
			if let partyIDQueryItem = queryItems?.first(where: {$0.name == "party"}) {
				guard let partyID = partyIDQueryItem.value else { return }
				
				shouldJoinParty(partyID, completion: { (myColor) -> Void in
					let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
					guard let partyViewController = storyboard.instantiateViewController(withIdentifier: "PartyViewController") as? PartyViewController
					else { return }
					partyViewController.partyID = partyID
					partyViewController.isCreator = false
					partyViewController.myColor = myColor
					partyViewController.modalPresentationStyle = .fullScreen
					(self.window?.rootViewController)?.present(partyViewController, animated: true, completion: nil)
				})
			}
		}
	}
	
	func shouldJoinParty(_ partyID: String, completion: @escaping (String) -> ()) {
		let partyRef = Database.database().reference().child("Parties")
		let ref = partyRef.child(partyID)
		let user_id = UserDefaults.standard.string(forKey: "user_name")
		
		ref.observeSingleEvent(of: .value) { (snapshot) in
			let postDict = snapshot.value as? [String : AnyObject] ?? [:]
			if postDict.isEmpty {
				// party doesn't exist
			} else {
				// party exists
				let members = JSON(postDict["members"])
				let randomColor = Colors.randomizeHexColor()
				if members[randomColor].stringValue != "" {
					// change color first
					let newRandomColor = Colors.randomizeHexColor()
					ref.child("members").child(newRandomColor).setValue(user_id!)
					completion(newRandomColor)
				} else {
					// create the user with this color
					ref.child("members").child(randomColor).setValue(user_id!)
					completion(randomColor)
				}
			}
			
		}
	}
	
	

	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

	struct LaunchOptionsHandler {
		
		static func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> NSUserActivity? {
			if let activityType = launchOptions?[.userActivityType] as? String {
				if activityType == NSUserActivityTypeBrowsingWeb {
					return NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
				}
			}
			
	 
			return nil
		}
	}
	
}

