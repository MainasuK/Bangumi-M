//
//  Bangumi_MUITests.swift
//  Bangumi MUITests
//
//  Created by Cirno MainasuK on 2015-9-30.
//  Copyright © 2015年 Cirno MainasuK. All rights reserved.
//

import XCTest

class Bangumi_MUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testTapSearchButton() {
        sleep(15)
        
        let app = XCUIApplication()
        let navigationBar = app.navigationBars["进度管理"]
        let menuButton2 = navigationBar.buttons["menu"]
        menuButton2.tap()
        
        let tablesQuery = app.tables
        let aboutButton = tablesQuery.buttons["About"]
        aboutButton.tap()
        
        let menuButton = app.navigationBars["Bangumi M"].buttons["menu"]
        menuButton.tap()
        tablesQuery.buttons["超展开"].tap()
        sleep(10)
        app.buttons["Done"].tap()
        menuButton.tap()
        
        let button = tablesQuery.buttons["进度管理"]
        button.tap()
        navigationBar.buttons["Search"].tap()
        
        // Your first item in search box
        tablesQuery.staticTexts["アナーキー・イン・ザ・JK"].tap()
        app.navigationBars["Bangumi_M.DetailView"].buttons["收藏"].tap()
        sleep(10)
        tablesQuery.buttons["在读"].tap()
        tablesQuery.otherElements["Rating"].tap()
        app.navigationBars["少女祈祷中…"].buttons["保存"].tap()
        
        sleep(10)
        
        menuButton2.tap()
        aboutButton.tap()
        menuButton.tap()
        button.tap()
        
    }
    
}
