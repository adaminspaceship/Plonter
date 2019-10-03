//
//  FriendTableViewCell.swift
//  Plonter
//
//  Created by Adam Eliezerov on 03/10/2019.
//  Copyright © 2019 Adam Eliezerov. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		friendBG.layer.cornerRadius = 8
		friendBG.layer.borderWidth = 2
		friendSelected.isHidden = true
		friendBG.backgroundColor = Colors.randomizeColor()
    }
	@IBOutlet weak var friendName: UILabel!
	@IBOutlet weak var friendBG: UIView!
	@IBOutlet weak var friendSelected: UIView!
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
