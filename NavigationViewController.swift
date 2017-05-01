//
//  NavigationViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // color of nigation bar
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.navigationBar.tintColor = .white
        
        self.navigationBar.barTintColor = UIColor(red: 45/255, green: 213/255, blue: 255/255, alpha: 1)
        
        self.navigationBar.isTranslucent = false
    }
    //status bar white
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
