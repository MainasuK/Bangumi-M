//
//  Bangumi_M_UITests.swift
//  Bangumi M UITests
//
//  Created by Cirno MainasuK on 2016-8-2.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest
import SimulatorStatusMagic

class Bangumi_M_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        SDStatusBarManager.sharedInstance().enableOverrides()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
//        SDStatusBarManager.sharedInstance().disableOverrides()
    }

    private func setupStatusBar() {
        SDStatusBarManager.sharedInstance().enableOverrides()
    }

    func testSetupStatusBar() {
        setupStatusBar()
    }

    func testLogin() {
        sleep(5)

        let app = XCUIApplication()
        let emailTextField = app.textFields["email"]
        let passTextField = app.secureTextFields["password"]

        emailTextField.tap()
        emailTextField.typeText("cirno.percolator@gmail.com")

        passTextField.tap()
        passTextField.typeText("percolator\n")
        sleep(10)

        // Time to snapshotting…
        setupStatusBar()
    }

}
