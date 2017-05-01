//
//  TabBarViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = .white
        
        self.tabBar.barTintColor = UIColor(red: 45/255, green: 213/255, blue: 255/255, alpha: 1)
        
        self.tabBar.isTranslucent = false
    }
}
