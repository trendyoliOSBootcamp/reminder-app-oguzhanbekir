//
//  UITextField+Extension.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 14.05.2021.
//

import UIKit

class FormTextField: UITextField {

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}
