//
//  UIText.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/3/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

@IBDesignable
class UIText: UITextView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWith: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWith
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
