//
//  UIKitExtensionsTests.swift
//  RFSVG
//
//  Created by Dunja Lalic on 1/30/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import FBSnapshotTestCase
import UIKit
@testable import RFSVG
import SMWebView

class UIKitExtensionsTests: FBSnapshotTestCase {
    
    var bundle: Bundle?
    var expectation: XCTestExpectation?
    var webViews = Array<SMWebView>()
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
        self.isDeviceAgnostic = false
        self.bundle = Bundle(for: type(of: self))
        RFSVGCache.sharedInstance.bundle = self.bundle!
    }
    
    func testCompareWithWebView() {
        self.expectation = expectation(description: "testCompareWithWebView")
        
        var counter = 1
        let enumerator = FileManager.default.enumerator(atPath: (self.bundle?.bundlePath)!)
        while let filePath = enumerator?.nextObject() as? String {
            if !filePath.contains("Frameworks") && NSURL(fileURLWithPath: filePath).pathExtension == "svg" {
                if self.recordMode {
                    self.createAndSnapshotWebViewFromPath(filePath: filePath)
                    counter += 1
                    
                } else {
                    self.createAndSnapshotImageViewFromPath(filePath: filePath)
                }
            }
        }
        
        if !self.recordMode {
            self.expectation?.fulfill()
        }
        self.waitForExpectations(timeout: TimeInterval(counter))
    }

    func createAndSnapshotWebViewFromPath(filePath: String) {
        let webView = SMWebView.init()
        webView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        webView.scalesPageToFit = false
        self.webViews.append(webView)
        
        let url = self.bundle?.bundleURL.appendingPathComponent(filePath)
        let urlString = url?.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        let htmlFilePath = self.bundle?.path(forResource: "renderSVG", ofType: "html")
        var html = try! String.init(contentsOfFile: htmlFilePath!)
        html = html.replacingOccurrences(of: "###", with: urlString!)
        
        webView.loadHTML(html, baseURL: (self.bundle?.bundleURL)!).didCompleteLoading { [weak self] webView in
            self?.verifyWebViewSnapshot(webView: webView,identifier: filePath)
        }
    }
    
    func verifyWebViewSnapshot(webView: SMWebView, identifier: String) {
        FBSnapshotVerifyView(webView, identifier: identifier, suffixes: FBSnapshotTestCaseDefaultSuffixes(), tolerance: 0)
        
        if let index = self.webViews.index(of: webView) {
            self.webViews.remove(at: index)
        }
        
        if self.webViews.count == 0 {
            self.expectation?.fulfill()
        }
    }
    
    func createAndSnapshotImageViewFromPath(filePath: String) {
        let fileName = NSString(string: filePath).deletingPathExtension
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        imageView.tintColor = .black
        imageView.backgroundColor = .white
        imageView.setImageFromSVG(fileName)
        
        FBSnapshotVerifyView(imageView, identifier: filePath, suffixes: FBSnapshotTestCaseDefaultSuffixes(), tolerance: 0.1)
    }

    func testButton() {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        button.setImageFromSVG("unicorn", for: .normal)
        FBSnapshotVerifyView(button)
    }
    
    func testImageView() {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        imageView.setImageFromSVG("unicorn")
        FBSnapshotVerifyView(imageView)
    }
    
    func testImageViewWithTintColor() {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.tintColor = UIColor.init(red: 0.992, green:0.867, blue:0.902, alpha:1.0)
        
        var image = UIImage.imageFromSVG("unicorn", size: imageView.bounds.size)
        image = image.withRenderingMode(.alwaysTemplate)
        
        imageView.image = image
        
        FBSnapshotVerifyView(imageView)
    }
}
