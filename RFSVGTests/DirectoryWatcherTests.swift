//
//  DirectoryWatcherTests.swift
//  RFSVG
//
//  Created by Dunja Lalic on 1/30/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import XCTest
@testable import RFSVG

class DirectoryWatcherTests: XCTestCase, DirectoryWatcherDelegate {
    var path: String? = ""
    var url: URL? = nil
    var sut: DirectoryWatcher? = nil
    var expectation: XCTestExpectation?
    var delegateShouldFire: Bool = false
    
    override func setUp() {
        super.setUp()
        
        self.path = NSTemporaryDirectory() + "Tests"
        self.url = URL(fileURLWithPath: path!)
        
        if FileManager.default.fileExists(atPath: path!) {
            try! FileManager.default.removeItem(atPath: path!)
        }
        try! FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: false, attributes: nil)
        
        self.sut = DirectoryWatcher.init(URL: url!, delegate: self)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.sut?.stopMonitoring()
    }
    
    func testStartMonitoring() {
        self.expectation = expectation(description: "testStartMonitoring")
        self.delegateShouldFire = true
        
        self.sut?.startMonitoring()
        
        let fileData = "testStartMonitoring".data(using: .utf8)!
        try! fileData.write(to: (url?.appendingPathComponent("testStartMonitoring"))!)
        
        waitForExpectations(timeout: 1.0) { (error) in
            let items = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory() + "Tests")
            XCTAssertTrue(items.count == 1)
        }
    }
    
    func testStopMonitoring() {
        let e = expectation(description: "testStopMonitoring")
        self.delegateShouldFire = false
        
        self.sut?.stopMonitoring()
        
        let fileData = "testStopMonitoring".data(using: .utf8)!
        try! fileData.write(to: (url?.appendingPathComponent("testStopMonitoring"))!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            e.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: DirectoryWatcherDelegate
    
    internal func directoryDidChange(_ directoryWatcher: DirectoryWatcher) {
        if self.delegateShouldFire {
            self.expectation?.fulfill()
        } else {
            XCTFail()
        }
    }
}
