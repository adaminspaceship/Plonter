//
//  SceneDelegate.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	@available(iOS 13.0, *)
	@available(iOS 13.0, *)
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		if #available(iOS 13.0, *) {
			guard let _ = (scene as? UIWindowScene) else { return }
		} else {
			// Fallback on earlier versions
		}
	}

	@available(iOS 13.0, *)
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	@available(iOS 13.0, *)
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	@available(iOS 13.0, *)
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	@available(iOS 13.0, *)
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	@available(iOS 13.0, *)
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
	}
	func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
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
		}
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
				let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
				guard let partyViewController = storyboard.instantiateViewController(withIdentifier: "PartyViewController") as? PartyViewController
					else { return }
				partyViewController.partyID = partyID
				partyViewController.isCreator = false
				shouldJoinParty(partyID, completion: { (myColor) -> Void in
					partyViewController.myColor = myColor
					partyViewController.modalPresentationStyle = .fullScreen
					(self.window?.rootViewController as? UIViewController)?.present(partyViewController, animated: true, completion: nil)
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

}

