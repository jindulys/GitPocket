//
//  GithubModulerTests.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-15.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import XCTest
@testable import GitPocket

class GithubModulerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectToJSON() {
        let testString = objectToJSON("string")
        XCTAssertTrue(testString == JSON.Str("string"))
        
        let jsonArray = objectToJSON(["1", NSNumber(int: 10)])
        XCTAssertTrue(jsonArray == JSON.Array([.Str("1"), .Number(NSNumber(int: 10))]))
        
        let jsonDic = objectToJSON(["1": "String", "2": NSNumber(float: 66.6)])
        XCTAssertTrue(jsonDic == JSON.Dictionary(["1":.Str("String"), "2": .Number(NSNumber(float: 66.6))]))
    }

}

