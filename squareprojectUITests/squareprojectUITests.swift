//
//  squareprojectUITests.swift
//  squareprojectUITests
//
//  Created by Brendon Brinkmann on 4/5/22.
//

import XCTest

class squareprojectUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLaunchApp() throws {
        // UI tests must launch the application that they test.
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDirectoryScreenExists() {
        app.launch()
        
        XCTAssertTrue(app.staticTexts["Directory"].exists)
        XCTAssertTrue(app.buttons["Sort"].exists)
    }
    
    //MARK: - Elements Exist
    
    func testSearchBarExists() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
    }
    
    //MARK: - Search Functions
    func testPullToRefresh() {
        app.launch()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.swipeDown(velocity: 100.0)
    }
    
    func testPullToRefreshAfterSearch() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Part Time")
        app.staticTexts["Directory"].tap()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.swipeDown(velocity: 100.0)
    }
    
    
    //MARK: - Search Functions
    func testTapSearchBar() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        XCTAssert(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
    }
    
    func testSearchNoResults() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Sample No Results")
        app.staticTexts["Directory"].tap()
        XCTAssertTrue(app.staticTexts["No Results Found"].exists)
    }
    
    func testSearchUserName() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Justine")
        XCTAssertTrue(app.staticTexts["Justine Mason"].exists)
    }
    
    func testSearchFullTime() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Full Time")
        XCTAssertTrue(app.staticTexts["Alaina Daly"].exists)
    }
    
    func testSearchEmployeeType() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Part Time")
        XCTAssertTrue(app.staticTexts["Camille Rogers"].exists)
    }
    
    func testSearchTeam() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Point of Sale")
        XCTAssertTrue(app.staticTexts["Justine Mason"].exists)
    }
    
    //MARK: - Sort Functions
    func testSortTeam() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["Team"].tap()
    }
    
    func testSortFirstName() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["First Name"].tap()
    }
    
    func testSortLastName() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["Last Name"].tap()
    }
    
    func testSortEmployeeType() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["Employee Type"].tap()
    }
    
    func testSortDefault() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["Default"].tap()
    }
    
    func testSortDismiss() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        
        app.alerts["Sort"].buttons["Dismiss"].tap()
    }
    
    //MARK: - Employee Taps
    
    func testTapEmployee() {
        app.launch()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Justine Mason"].tap()

        let alert = app.alerts["Justine Mason"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }
    
    func testTapEmployeeAfterFirstNameSearch() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Justine")
        XCTAssertTrue(app.staticTexts["Justine Mason"].exists)
        
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Justine Mason"].tap()

        let alert = app.alerts["Justine Mason"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }
    
    func testTapEmployeeAfterTeamSearch() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5.0))
        searchBar.tap()
        searchBar.typeText("Point of Sale")
        XCTAssertTrue(app.staticTexts["Justine Mason"].exists)
        XCTAssertTrue(app.staticTexts["Richard Stein"].exists)
        XCTAssertTrue(app.staticTexts["Michael Morin"].exists)

        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Richard Stein"].tap()

        let alert = app.alerts["Richard Stein"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }

    func testTapEmployeeAfterEmployeeTypeSort() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        app.alerts["Sort"].buttons["Employee Type"].tap()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Michael Morin"].tap()

        let alert = app.alerts["Michael Morin"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }
    
    func testTapEmployeeAfterFirstNameSort() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        app.alerts["Sort"].buttons["First Name"].tap()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Tim Nakamura"].tap()

        let alert = app.alerts["Tim Nakamura"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }
    
    func testTapEmployeeAfterTeamSort() {
        app.launch()
        XCTAssertTrue(app.searchFields.firstMatch.exists)
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5.0))
        sortButton.tap()
        app.alerts["Sort"].buttons["Team"].tap()
        XCTAssertTrue(app.tables.firstMatch.exists)
        let list = app.tables.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5.0))
        list.cells.staticTexts["Kaitlyn Spindel"].tap()

        let alert = app.alerts["Kaitlyn Spindel"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.staticTexts.firstMatch.exists)
        alert.buttons["Dismiss"].tap()
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
