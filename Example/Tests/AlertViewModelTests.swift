//
//  AlertViewModelTests.swift
//  JFWindguru_Tests
//
//  Created by fox on 29/05/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import Forescoop
@testable import Forescoop_Example

final class AlertViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
        
    func testAnonymousUserServiceUserAlertViewModel() {
        let definition = Definition()
        XCTAssertNotNil(definition)
        let user = try? User(map: definition.json(jsonFile: "AnonymousUser"))
        XCTAssertTrue(user?.isAnonymous == true)
        XCTAssertNotNil(user)
        let apiController = ApiController(user: user, forecastService: ForecastWindguruMockup(), delegate: self)
        XCTAssertNotNil(apiController)
        apiController.currentServiceOrdinal = 0
        XCTAssertNotNil(apiController.service)
        XCTAssertEqual(apiController.service, AnonymousBaseServices.user.rawValue)
        XCTAssertTrue(apiController.isUserAnonymous)
        guard let alert = AlertViewModel(apiController: apiController).alertController else { return }
        XCTAssertNotNil(alert)
    }

    func testRealUserServiceUserAlertViewModel() {
        let definition = Definition()
        XCTAssertNotNil(definition)
        let user = try? User(map: definition.json(jsonFile: "User"))
        XCTAssertNotNil(user)
        let apiController = ApiController(user: user, password: "xxx", forecastService: ForecastWindguruMockup(), delegate: self)
        XCTAssertNotNil(apiController)
        apiController.currentServiceOrdinal = 0
        XCTAssertNotNil(apiController.service)
        XCTAssertEqual(apiController.service, AnonymousBaseServices.user.rawValue)
        XCTAssertFalse(apiController.isUserAnonymous)
        guard let alert = AlertViewModel(apiController: apiController).alertController else { return }
        XCTAssertNotNil(alert)
    }

    func testRealUserGeoRegionsAlertViewModel() {
        let definition = Definition()
        XCTAssertNotNil(definition)
        let user = try? User(map: definition.json(jsonFile: "User"))
        XCTAssertNotNil(user)
        let apiController = ApiController(user: user, password: "xxx", forecastService: ForecastWindguruMockup(), delegate: self)
        XCTAssertNotNil(apiController)
        apiController.currentServiceOrdinal = 1
        XCTAssertNotNil(apiController.service)
        XCTAssertEqual(apiController.service, AnonymousBaseServices.geo_regions.rawValue)
        XCTAssertFalse(apiController.isUserAnonymous)
        guard let alert = AlertViewModel(apiController: apiController).alertController else { return }
        XCTAssertNotNil(alert)
    }

    func testRealUserCountriesAlertViewModel() {
        let definition = Definition()
        XCTAssertNotNil(definition)
        let user = try? User(map: definition.json(jsonFile: "User"))
        XCTAssertNotNil(user)
        let apiController = ApiController(user: user, password: "xxx", forecastService: ForecastWindguruMockup(), delegate: self)
        XCTAssertNotNil(apiController)
        apiController.currentServiceOrdinal = 2
        XCTAssertNotNil(apiController.service)
        XCTAssertEqual(apiController.service, AnonymousBaseServices.countries.rawValue)
        XCTAssertFalse(apiController.isUserAnonymous)
        guard let alert = AlertViewModel(apiController: apiController).alertController else { return }
        XCTAssertNotNil(alert)
    }
}

extension AlertViewModelTests: ApiControllerDelegate {
    func showApiInfo(info: String) {
        XCTAssertNotNil(info)
    }
    
    func showError(service: String?, error: Error?) {
        XCTAssertNotNil(service)
        XCTAssertNotNil(error)
    }
}
