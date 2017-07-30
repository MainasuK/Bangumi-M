//
//  KeychainAsscessTests.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-17.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest
import KeychainAccess

@testable import Bangumi_M

class KeychainAsscessTests: XCTestCase {

    var keychain: Keychain!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        keychain = Keychain(service: "com.keychainasscess.test")
    }

    func testSave() {
        do {
            try keychain.set("password", key: "key")
        } catch {
            consolePrint(error)
            XCTAssertNil(error)
        }
    }

    func testGet() {
        let value = String(arc4random_uniform(100) + 1)
        keychain["key"] = value

        do {
            let val = try keychain.get("key")
            consolePrint(val)
        } catch {
            consolePrint(error)
            XCTAssertNil(error)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        do {
            try keychain.removeAll()
        } catch {
            consolePrint(error)
        }

        super.tearDown()
    }

}
