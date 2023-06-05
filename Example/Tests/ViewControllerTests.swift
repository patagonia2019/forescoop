//
//  ViewControllerTests.swift
//  JFWindguru_Tests
//
//  Created by fox on 29/05/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import JFWindguru_Example

final class ViewControllerTests: XCTestCase {

    private var vc: ViewController!
    
    override func setUpWithError() throws {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        vc = sb.instantiateViewController(identifier: "ViewController") { coder in
            ViewController(coder: coder)
        }
        vc.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        vc = nil
    }

    // Test init
    // Test viewDidLoad
    // - default / initial values
    // - on success / on failure?
    
    func testInitVC() throws {
        XCTAssertNotNil(vc)
        XCTAssertTrue(vc.isViewLoaded)
        XCTAssertEqual(vc.loginButton.title(for: .normal), "Login")
        XCTAssertTrue(vc.hourLabel.text?.isEmpty == false)
    }
    
    // How to test the observer, KWDForecastUpdated
    // Where spotForecast is updated?
    // Was the UI upadated?
    // Does it fire a network request?
    

}
