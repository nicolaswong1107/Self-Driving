//
//  ViewPostTableViewCell.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 3/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class ViewPostTableViewCell: UITableViewCell {
    @IBOutlet weak var usericon: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var titles: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        usericon.layer.cornerRadius = usericon.layer.bounds.width / 2
        usericon.clipsToBounds = true
        content.isEditable = false
        content.isScrollEnabled = false
    }
}
