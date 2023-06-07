//
//  MainViewControllerTests.swift
//  JFWindguru_Tests
//
//  Created by fox on 29/05/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import Forescoop
@testable import Forescoop_Example

final class MainViewControllerTests: XCTestCase {

    private var vc: MainViewController?
    override func setUpWithError() throws {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        vc = sb.instantiateViewController(identifier: "MainViewController") { coder in
            let forecastService = ForecastWindguruMockup()
            return MainViewController(coder: coder, forecastService: forecastService)
        }
        vc?.loadViewIfNeeded()
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
        XCTAssertTrue(vc?.isViewLoaded == true)
        XCTAssertEqual(vc?.loginButton.title(for: .normal), "Login")
        XCTAssertTrue(vc?.hourLabel.text?.isEmpty == false)
    }
}
