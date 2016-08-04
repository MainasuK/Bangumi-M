//
//  BangumiRequestLoginTest.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest

@testable import Bangumi_M

class BangumiRequestTest: Bangumi_M_Tests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        User.removeInfo()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        User.removeInfo()
    }
    
    func testUserLogin() {
        let requestExpectation = expectation(description: "Request finish")
        var userID = 0
        
        request.userLogin(kDemoEmail, password: kDemoPassword) { (result: Result<User>) in
            
            do {
                let user = try result.resolve()
                userID = user.id
            } catch {
                consolePrint(error)
                XCTAssertNil(error, "Should no error excepte network issue")
            }
            
            requestExpectation.fulfill()
        }
        
        waitForExpectations(timeout: TimeInterval(20)) { (error: Error?) in
            XCTAssertNil(error, "Should no error")
            XCTAssertEqual(userID, self.kDemoID, "Should same ID")
        }
    }

}
