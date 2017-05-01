//
//  searchCell.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/15/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class searchCell: UITableViewCell, UISearchBarDelegate {

    @IBOutlet weak var Uimage: UIImageView!
    @IBOutlet weak var Uname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Uimage.layer.cornerRadius = Uimage.layer.bounds.width / 2
        Uimage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
