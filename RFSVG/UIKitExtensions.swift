//
//  UIKitExtensions.swift
//  RFSVG
//
//  Created by Dunja Lalic on 1/30/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import UIKit

extension UIButton {
    
    /// Creates an image from SVG file and sets it to the button
    /// where image size is determined from the button bounds and `imageEdgeInsets`,
    ///
    /// - Important:
    ///   - The image rendered is rendered in `alwaysTemplate` mode
    ///   - Button's imageView content mode is set to `scaleAspectFit`
    ///
    /// - Parameters:
    ///   - name: Name of SVG file
    ///   - state: The state that uses the specified title. The values are described in `UIControlState`
    open func setImageFromSVG(_ name: String, for state: UIControlState) {
        var rect = UIEdgeInsetsInsetRect(self.bounds, self.titleEdgeInsets)
        rect = UIEdgeInsetsInsetRect(rect, self.imageEdgeInsets)
        var image = UIImage.imageFromSVG(name, size: rect.size)
        if image.cgImage != nil {
            image = image.withRenderingMode(.alwaysTemplate)
        }
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(image, for: state)
    }
}

extension UIImageView {
    
    /// Creates an image from SVG file and sets it to the image view
    /// where image size is determined from the image view bounds.
    ///
    /// - Important:
    ///   - Button's imageView content mode is set to `scaleAspectFit`
    ///
    /// - Parameters:
    ///   - name: Name of SVG file
    open func setImageFromSVG(_ name: String) {
        self.contentMode = .scaleAspectFit
        let image = UIImage.imageFromSVG(name, size: self.bounds.size)
        self.image = image
    }
}

extension UIImage {
    
    /// Creates an image from SVG file and returns it.
    ///
    /// - Parameters:
    ///   - name: Name of SVG file
    ///   - size: Desired size
    /// - Returns: A freshly rendered or cached (if existing version for size exists) `UIImage` from SVG file
    open static func imageFromSVG(_ name: String, size: CGSize) -> UIImage {
        let image = RFSVGCache.sharedInstance.image(name: name, size: size)
        return image
    }
}
