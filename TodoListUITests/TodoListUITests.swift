//
//  TodoListUITests.swift
//  TodoListUITests
//
//  Created by Usama Nasar on 16/07/2019.
//  Copyright © 2019 Usama Nasar. All rights reserved.
//

import XCTest

class TodoListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        super.setUp()
        app = XCUIApplication()
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
        super.tearDown()
    }
    
    func testSignUpButtonDisplays() {
        app.launch()
        XCTAssertTrue(app.buttons["Sign up"].exists)
    }
    
    func testSignUpButtonShowsSignUpUi() {
        app.launch()
        app.buttons["Sign up"].tap()
        XCTAssertFalse(app.buttons["Sign in"].exists)
    }
    
    func testsignup() {
        app.launch()
        app.buttons["Sign up"].tap()
        let alert = app.alerts["Register"]
        let user = "user@user.com"
        alert.typeText("\(user)\n")
        alert.typeText("123456\n")
    }
    
    func testlogin() {
        app.launch()
        let email = app.textFields["Email"]
        //        let password = app.textFields["Password"]
        let user = "user@user.com"
        if email.exists{
            email.tap()
            email.typeText("\(user)\n")
            app.typeText("123456")
            app.buttons["Login"].tap()
        }
        app.buttons["User"].tap()
    }
    
}
