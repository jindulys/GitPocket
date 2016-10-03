//
//  GitPocketTests.swift
//  GitPocketTests
//
//  Created by yansong li on 2015-07-04.
//  Copyright © 2015 yansong li. All rights reserved.
//

import XCTest
import GitPocket

class GitPocketTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testWebViewController() {
        let v = WebViewController()
        v.webURL = "http://www.google.com"
        XCTAssertNotNil(v.view, "View Did Not load")
    }
    
}
