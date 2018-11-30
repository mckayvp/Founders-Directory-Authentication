//
//  Extensions.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/21/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

extension UIImageView {
    func applyBorder() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.3
    }

    func applyCircleMask() {
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }
}

extension UINavigationController {
    func makeBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = UIColor.clear
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.barTintColor = UIColor.clear
    }

    func resetBarTransparency(_ tintColor: UIColor) {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.barTintColor = tintColor
    }
}

extension String {
    var length : Int {
        return self.count
    }
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
}
