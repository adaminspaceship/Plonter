//
//  Utilities.swift
//  Plonter
//
//  Created by Adam Eliezerov on 05/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

struct Utilities {
	
	static func firstLaunch()->Bool{
		let defaults = UserDefaults.standard
		if let _ = defaults.string(forKey: "user_name"){
			print("App already launched")
			return false
		} else {
			return true
		}
	}
	
	static func vibratePhone(_ type: vibrationType) {
		switch type {
		case .Peek:
			AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
		case .Pop:
			AudioServicesPlaySystemSound(1520) // Actuate "Pop" feedback (strong boom)
		case .Nope:
			AudioServicesPlaySystemSound(1521) // Actuate "Nope" feedback (series of three weak booms)
		}
	}
	
	
	
	enum vibrationType {
		case Peek
		case Pop
		case Nope
	}
	
}

extension PartyViewController {
	
	
	func playAudio(_ fileName: String) {
		guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else { return }
        let soundURl = URL(fileURLWithPath: path)
        player = try? AVAudioPlayer(contentsOf: soundURl)
        player.prepareToPlay()
        player.play()
	}
}
