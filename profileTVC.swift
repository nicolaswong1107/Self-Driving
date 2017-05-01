//
//  profileTVC.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 4/18/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class profileTVC: UITableViewCell {
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        icon.layer.cornerRadius = icon.layer.bounds.width / 2
        icon.clipsToBounds = true
        content.isEditable = false
        content.isScrollEnabled = false
    }
}
