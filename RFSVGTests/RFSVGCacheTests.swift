//
//  RFSVGCacheTests.swift
//  RFSVGTests
//
//  Created by Dunja Lalic on 1/25/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import XCTest
@testable import RFSVG

class RFSVGCacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        if FileManager.default.fileExists(atPath: RFSVGCache.sharedInstance.pathForTemporaryDirectory()) {
            try! FileManager.default.removeItem(atPath: RFSVGCache.sharedInstance.pathForTemporaryDirectory())
        }
        try! FileManager.default.createDirectory(atPath: RFSVGCache.sharedInstance.pathForTemporaryDirectory(), withIntermediateDirectories: false, attributes: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
        
        RFSVGCache.sharedInstance.bundle = Bundle(for: type(of: self))
    }
    
    override func tearDown() {
        super.tearDown()
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
    }
    
    func testMemoryCaching() {
        let image = UIImage.imageFromSVG("unicorn", size: CGSize.init(width: 20, height: 20))
        let cachedImage = RFSVGCache.sharedInstance.imageFromMemoryCache(name: "unicorn", size: CGSize.init(width: 20, height: 20))

        XCTAssertNotNil(image)
        XCTAssertNotNil(cachedImage)
    }
    
    func testMemoryCacheClearanceOnLowMemoryWarning() {
        _ = UIImage.imageFromSVG("unicorn", size: CGSize.init(width: 20, height: 20))
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)
    
        let cachedImage = RFSVGCache.sharedInstance.imageFromMemoryCache(name: "unicorn", size: CGSize.init(width: 20, height: 20))
        
        XCTAssertNil(cachedImage)
    }
    
    func testDiskCaching() {
        let e = expectation(description: "testDiskCaching")
        
        let image = UIImage.imageFromSVG("unicorn", size: CGSize.init(width: 10, height: 10))
        
        XCTAssertNotNil(image)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            e.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { (error) in
            let image = RFSVGCache.sharedInstance.imageFromDiskCache(name: "unicorn", size: CGSize.init(width: 10, height: 10))
            
            XCTAssertNotNil(image)
            
            let path = RFSVGCache.sharedInstance.pathForTemporaryDirectory()
            let items = try! FileManager.default.contentsOfDirectory(atPath: path)
            XCTAssertTrue(items.count == 1)
            
            let cachedImage = RFSVGCache.sharedInstance.imageFromMemoryCache(name: "unicorn", size: CGSize.init(width: 10, height: 10))
            XCTAssertNil(cachedImage)
        }
    }
}
