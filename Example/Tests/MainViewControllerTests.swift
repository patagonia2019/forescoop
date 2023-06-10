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

    private var vc: MainViewController? {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "MainViewController") { coder in
            let forecastService = ForecastWindguruMockup()
            return MainViewController(coder: coder, forecastService: forecastService)
        } as? MainViewController
        vc?.loadViewIfNeeded()
        return vc
    }
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
        
    func testForecastInfo() {
        XCTAssertNotNil(vc)
        XCTAssertTrue(vc?.isViewLoaded == true)
        XCTAssertEqual(vc?.loginButton.title(for: .normal), "Login")
        XCTAssertEqual(vc?.weatherLabel.text, "☀️🌥")
        XCTAssertEqual(vc?.windDirectionLabel.text, "WNW")
        XCTAssertEqual(vc?.temperatureLabel.text, "5.7°C")
        XCTAssertEqual(vc?.locationLabel.text, "Bariloche")
        XCTAssertEqual(vc?.windSpeedLabel.text, "10.1 knots")
        XCTAssertEqual(vc?.hourLabel.text, "09 hs")
        XCTAssertTrue(vc?.isUpdated == true)
    }
}
