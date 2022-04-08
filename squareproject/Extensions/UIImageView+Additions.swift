//
//  UIImageView+Additions.swift
//  squareproject
//
//  Created by Brendon Brinkmann on 4/8/22.
//

import UIKit

extension UIImageView {
    func roundImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
    }
}
