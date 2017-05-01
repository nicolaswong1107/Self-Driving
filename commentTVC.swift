//
//  commentTVC.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 4/17/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class commentTVC: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        icon.layer.cornerRadius = icon.layer.bounds.width / 2
        icon.clipsToBounds = true
        comment.isEditable = false
    }
}
