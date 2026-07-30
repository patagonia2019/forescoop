//
//  ForescoopTests.swift
//  ForescoopTests
//
//  Created by Javier Fuchs on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import XCTest
@testable import Forescoop

final class ForescoopTests: XCTestCase {
    private struct TestPreferencesProvider: ForecastPreferencesProviding {
        let forecastUnitPreferences: ForecastUnitPreferences
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Forescoop().text, "Hello, World!")
    }

    @MainActor
    func testDashboardViewModelUsesInjectedDevicePreferences() {
        let expected = ForecastUnitPreferences(
            temperatureUnit: .fahrenheit,
            windSpeedUnit: .milesPerHour,
            waveHeightUnit: .feet,
            pressureUnit: .inchesOfMercury,
            precipitationUnit: .inches,
            freezingLevelUnit: .feet
        )
        let viewModel = ForecastDashboardViewModel(
            forecastService: ForecastWindguruMockup(),
            preferencesProvider: TestPreferencesProvider(forecastUnitPreferences: expected)
        )

        XCTAssertEqual(viewModel.deviceUnitPreferences, expected)
    }
}
