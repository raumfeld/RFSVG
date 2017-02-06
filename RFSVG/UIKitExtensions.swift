//
//  UIKitExtensions.swift
//  RFSVG
//
//  Created by Dunja Lalic on 1/30/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import UIKit

extension UIButton {
    open func setImageFromSVG(_ name: String, for state: UIControlState) {
        var rect = UIEdgeInsetsInsetRect(self.bounds, self.titleEdgeInsets)
        rect = UIEdgeInsetsInsetRect(rect, self.imageEdgeInsets)
        var image = UIImage.imageFromSVG(name, size: rect.size)
        if (image.cgImage != nil) {
            image = image.withRenderingMode(.alwaysTemplate)
        }
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(image, for: state)
    }
}

extension UIImageView {
    open func setImageFromSVG(_ name: String) {
        self.contentMode = .scaleAspectFit
        let image = UIImage.imageFromSVG(name, size: self.bounds.size)
        self.image = image
    }
}

extension UIImage {
    open static func imageFromSVG(_ name: String,size: CGSize) -> UIImage {
        let image = RFSVGCache.sharedInstance.image(name: name, size: size)
        return image
    }
}
