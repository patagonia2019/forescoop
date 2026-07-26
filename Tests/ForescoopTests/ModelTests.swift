//
//  ModelTests.swift
//  ForescoopTests
//
//  Created by Javier Fuchs on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import XCTest
import Forescoop
import CoreLocation

class ModelTests: XCTestCase {
    
    private var definition: Definition?
    private var countriesDict: [String: Any]?
    private var spotResultDict: [String: Any]?
    private var anonymousUserDict: [String: Any]?
    private var userDict: [String: Any]?
    private var geoRegionsDict: [String: Any]?
    private var regionsDict: [String: Any]?
    private var spotInfoDict: [String: Any]?
    private var modelsDict: [String: Any]?
    private var spotForecastDict: [String: Any]?
    private var wSpotForecastDict: [String: Any]?

    override func setUp() {
        super.setUp()
        definition = Definition()
        countriesDict = definition?.json(jsonFile: "Countries")
        XCTAssertNotNil(countriesDict)
        spotResultDict = definition?.json(jsonFile: "SpotResult")
        XCTAssertNotNil(spotResultDict)
        anonymousUserDict = definition?.json(jsonFile: "AnonymousUser")
        XCTAssertNotNil(anonymousUserDict)
        userDict = definition?.json(jsonFile: "User")
        XCTAssertNotNil(userDict)
        geoRegionsDict = definition?.json(jsonFile: "GeoRegions")
        XCTAssertNotNil(geoRegionsDict)
        regionsDict = definition?.json(jsonFile: "Regions")
        XCTAssertNotNil(regionsDict)
        spotInfoDict = definition?.json(jsonFile: "SpotInfo")
        XCTAssertNotNil(spotInfoDict)
        modelsDict = definition?.json(jsonFile: "Models")
        XCTAssertNotNil(modelsDict)
        spotForecastDict = definition?.json(jsonFile: "SpotForecast")
        XCTAssertNotNil(spotForecastDict)
        wSpotForecastDict = definition?.json(jsonFile: "WSpotForecast")
        XCTAssertNotNil(wSpotForecastDict)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCountries() {
        let countries: Countries?
        do {
            countries = try Countries(map: countriesDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(countries)
        XCTAssertEqual(countriesDict?.count, countries?.sorted.count)
        XCTAssertEqual(countries?.sorted.first?.oficialName, "Argentina")
        XCTAssertEqual(countries?.sorted.first?.identifier, "32")
    }
    
    func testSpotResult() {
        let spotResult: SpotResult?
        do {
            spotResult = try SpotResult(map: spotResultDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(spotResult)
        XCTAssertEqual(spotResult?.numberOfSpots, 20)
        XCTAssertEqual(spotResult?.allSpots.count, 20)
        let spot = spotResult?.firstSpot
        XCTAssertEqual(spot?.name, "Bariloche")
        XCTAssertEqual(spot?.userIdentifier, "169")
        XCTAssertEqual(spot?.identifier, "64141")
        XCTAssertEqual(spot?.countryName, "Argentina")
        XCTAssertNil(spot?.nickName)
    }
    
    func testSpotNickname() {
        let spotResult: SpotResult?
        do {
            spotResult = try SpotResult(map: spotResultDict)
        } catch {
            return XCTFail()
        }
        let spot = spotResult?.find(nickname: "EAPCM")
        XCTAssertNotNil(spot)
        XCTAssertEqual(spot?.name, "Argentina,  Bariloche, playa sin viento L. Moreno este")
    }
    
    func testUser() {
        let user: User?
        do {
            user = try User(map: userDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(user)
        XCTAssertTrue(user?.isAnonymous == false)
        XCTAssertEqual(user?.name, "southfox")
        XCTAssertEqual(user?.countryIdentifier, 0)
        XCTAssertEqual(user?.windUnits, "kmh")
        XCTAssertEqual(user?.temperatureUnits, "c")
        XCTAssertEqual(user?.waveUnits, "m")
        XCTAssertTrue(user?.isPro == false)
        XCTAssertTrue(user?.noAdvertisement == false)
        XCTAssertEqual(user?.viewHoursFrom, 5)
        XCTAssertEqual(user?.viewHoursTo, 22)
        XCTAssertEqual(user?.temperatureLimit, 0)
        XCTAssertEqual(user?.windRatingLimits, [10.997305, 14.986523, 18.97574])
        let windColor = user?.windColor
        XCTAssertNotNil(windColor)
        XCTAssertEqual(user?.temperatureColor.count, 9)
        XCTAssertEqual(user?.cloudColor.count, 2)
        XCTAssertNotNil(user?.precipitationColor)
        XCTAssertNotNil(user?.precip1Color)
        XCTAssertNotNil(user?.pressureColor)
        XCTAssertNotNil(user?.rhColor)
        XCTAssertNotNil(user?.wpowerColor)
        XCTAssertNotNil(user?.tideColor)
        XCTAssertNotNil(user?.initialColor)
    }
    
    func testAnonymousUser() {
        let user: User?
        do {
            user = try User(map: anonymousUserDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(user)
        XCTAssertTrue(user?.isAnonymous == true)
        XCTAssertEqual(user?.name, "Anonymous")
        XCTAssertEqual(user?.countryIdentifier, 0)
        XCTAssertEqual(user?.windUnits, "knots")
        XCTAssertEqual(user?.temperatureUnits, "c")
        XCTAssertEqual(user?.waveUnits, "m")
        XCTAssertTrue(user?.isPro == false)
        XCTAssertTrue(user?.noAdvertisement == false)
        XCTAssertEqual(user?.viewHoursFrom, 3)
        XCTAssertEqual(user?.viewHoursTo, 22)
        XCTAssertEqual(user?.temperatureLimit, 10)
        XCTAssertEqual(user?.windRatingLimits, [10.63,15.57,19.41])
        let windColor = user?.windColor
        // TODO: cannot compare colors
        // XCTAssertTrue(windColor!.last!.color.isEqual(UIColor(red: 0, green: 1, blue: 0.00392157, alpha: 0)))
        // XCTAssertEqual(windColor?.last?.color, UIColor(red: 0, green: 1, blue: 0.00392157, alpha: 0))
        XCTAssertNotNil(windColor)
        XCTAssertEqual(user?.temperatureColor.count, 9)
        XCTAssertEqual(user?.cloudColor.count, 2)
        XCTAssertNotNil(user?.precipitationColor)
        XCTAssertNotNil(user?.precip1Color)
        XCTAssertNotNil(user?.pressureColor)
        XCTAssertNotNil(user?.rhColor)
        XCTAssertNotNil(user?.wpowerColor)
        XCTAssertNotNil(user?.tideColor)
        XCTAssertNotNil(user?.initialColor)
    }
    
    func testGeoRegions() {
        let geoRegions: GeoRegions?
        do {
            geoRegions = try GeoRegions(map: geoRegionsDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(geoRegions)
        XCTAssertEqual(geoRegionsDict?.count, geoRegions?.sorted.count)
        XCTAssertEqual(geoRegions?.sorted.first?.oficialName, "Africa")
    }

    func testRegions() {
        let regions: Regions?
        do {
            regions = try Regions(map: regionsDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(regions)
        XCTAssertEqual(regionsDict?.count, regions?.sorted?.count)
        XCTAssertEqual(regions?.sorted?.first?.oficialName, "Acre")
    }

    func testSpotInfo() {
        let spotInfo: SpotInfo?
        do {
            spotInfo = try SpotInfo(map: spotInfoDict)
        } catch {
            return XCTFail()
        }
        checkSpotInfo(spotInfo: spotInfo)
    }
    
    func testModels() {
        let models: [Model]?
        do {
            models = try Models(map: modelsDict)?.sorted
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(models)
        XCTAssertEqual(modelsDict?.count, models?.count)
        let model = models?.first
        XCTAssertEqual(model?.identifier, 3)
        XCTAssertEqual(model?.oficinalName, "GFS 13 km")
        XCTAssertEqual(model?.shortName, "gfs")
        XCTAssertEqual(model?.hrStart, 0)
        XCTAssertEqual(model?.hrEnd, 378)
        XCTAssertEqual(model?.hrStep, 1)
        XCTAssertEqual(model?.periodNumber, 6)
        XCTAssertEqual(model?.updateTime, "+4 hours +45 minutes")
        XCTAssertEqual(model?.showVars.first, "WINDSPD")
    }
    
    func testSpotForecast() {
        var forecastResponse = spotForecastDict
        var forecastModels = forecastResponse?["forecast"] as? [String: Any]
        forecastModels?["61"] = ["alt": 1_146, "hr": ["0": "0"]]
        forecastResponse?["forecast"] = forecastModels

        let spotForecast: SpotForecast?
        do {
            spotForecast = try SpotForecast(map: forecastResponse)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(spotForecast?.asCurrentWindDirectionName)
        checkSpotInfo(spotInfo: spotForecast)
        XCTAssertEqual(spotForecast?.numberOfForecasts, 1)
        XCTAssertEqual(spotForecast?.model, "3")
        let forecastModel = spotForecast?.forecastModel
        XCTAssertEqual(forecastModel?.modelIdentifier, "3")
        let forecast = spotForecast?.forecast
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.initializationStamp, 1686160800)
        XCTAssertEqual(forecast?.gmtHourOffset, -3)
        XCTAssertEqual(forecast?.initializationDate, DateTime("2023-06-07 18:00:00", gmtHourOffset: forecast?.gmtHourOffset ?? 0)?.asDate)
        let referenceDate = Date(timeIntervalSince1970: 1_689_811_200) // 2023-07-21 12:00 UTC
        let expectedForecastDate = Calendar.current.date(byAdding: .hour, value: 27, to: Calendar.current.startOfDay(for: referenceDate))
        XCTAssertEqual(spotForecast?.forecastDate(hour: "27", relativeTo: referenceDate), expectedForecastDate)
        XCTAssertEqual(forecast?.modelName, "GFS 13 km")

        /// Testing weather data
        XCTAssertEqual(forecast?.numberOfWeathers, 15)
        XCTAssertEqual(forecast?.windDirectionName(hh: "10"), "NW")
        XCTAssertEqual(forecast?.windDirection(hh: "10"), 304)
        XCTAssertEqual(forecast?.windSpeed(hh: "10"), 11.5)
        XCTAssertEqual(forecast?.temperature(hh: "10"), 4.3)
        XCTAssertEqual(forecast?.temperatureReal(hh: "10"), 6.3)
        XCTAssertEqual(forecast?.cloudCoverTotal(hh: "10"), 100)
        XCTAssertEqual(forecast?.cloudCoverHigh(hh: "10"), 0)
        XCTAssertEqual(forecast?.cloudCoverMid(hh: "10"), 5)
        XCTAssertEqual(forecast?.cloudCoverLow(hh: "10"), 100)
        XCTAssertEqual(forecast?.relativeHumidity(hh: "10"), 95)
        XCTAssertEqual(forecast?.windGusts(hh: "10"), 80.3768)
        XCTAssertEqual(forecast?.windGustsKnots(hh: "10"), 43.4)
        let weatherSymbols = spotForecast?.weatherSymbolNames(hour: "10") ?? []
        XCTAssertGreaterThanOrEqual(weatherSymbols.count, 2)
        XCTAssertEqual(weatherSymbols.count, Set(weatherSymbols).count)
        XCTAssertTrue(spotForecast?.weatherSymbolNames(hour: "29").contains("snowflake") == true)
        let blendedForecast: SpotForecast?
        do {
            blendedForecast = try SpotForecast.blended([spotForecast!, spotForecast!])
        } catch {
            return XCTFail("Expected an equal-weight model blend")
        }
        XCTAssertEqual(blendedForecast?.forecast?.modelName, "Forescoop Mix (2 models)")
        let blendHour = forecast?.availableHours.first
        XCTAssertEqual(blendedForecast?.forecast?.windSpeed(hh: blendHour), forecast?.windSpeed(hh: blendHour))

        var nonOverlappingResponse = spotForecastDict
        var nonOverlappingModels = nonOverlappingResponse?["forecast"] as? [String: Any]
        var nonOverlappingModel = nonOverlappingModels?["3"] as? [String: Any]
        nonOverlappingModel?["WINDSPD"] = ["999": 4.0]
        nonOverlappingModels?["3"] = nonOverlappingModel
        nonOverlappingResponse?["forecast"] = nonOverlappingModels
        let nonOverlappingForecast = try? SpotForecast(map: nonOverlappingResponse)
        let fallbackForecast = try? SpotForecast.blended([spotForecast!, nonOverlappingForecast!])
        XCTAssertEqual(fallbackForecast?.forecast?.modelName, forecast?.modelName)

        XCTAssertEqual(forecast?.seaLevelPressure(hh: "10"), 1002.0)
        XCTAssertEqual(forecast?.freezingLevelHeightInMeters(hh: "10"), 2590.0)
        XCTAssertEqual(forecast?.precipitation(hh: "165"), 0)
        XCTAssertEqual(forecast?.precipitation1(hh: "10"), 0.8)
    }

    func testWeatherUnitConversions() {
        let wind = Knots(10)
        XCTAssertEqual(wind.value(in: .knots), 10)
        XCTAssertEqual(wind.value(in: .metersPerSecond) ?? 0, 5.14444, accuracy: 0.00001)
        XCTAssertEqual(wind.value(in: .kilometersPerHour) ?? 0, 18.52, accuracy: 0.00001)
        XCTAssertEqual(wind.value(in: .milesPerHour) ?? 0, 11.5078, accuracy: 0.00001)
        XCTAssertEqual(wind.value(in: .beaufort), 3)

        XCTAssertEqual(Temperature(celsius: 0).value(in: .celsius), 0)
        XCTAssertEqual(Temperature(celsius: 0).value(in: .fahrenheit), 32)

        let pressure = AtmosphericPressure(hectopascals: 1_013.25)
        XCTAssertEqual(pressure.value(in: .hectopascals), 1_013.25)
        XCTAssertEqual(pressure.value(in: .millibars), 1_013.25)
        XCTAssertEqual(pressure.value(in: .inchesOfMercury), 29.921_255, accuracy: 0.000_001)
        XCTAssertEqual(pressure.value(in: .millimetersOfMercury), 760.001, accuracy: 0.001)

        let precipitation = Precipitation(millimeters: 25.4)
        XCTAssertEqual(precipitation.value(in: .millimeters), 25.4)
        XCTAssertEqual(precipitation.value(in: .inches), 1)

        let freezingLevel = FreezingLevel(meters: 1_000)
        XCTAssertEqual(freezingLevel.value(in: .meters), 1_000)
        XCTAssertEqual(freezingLevel.value(in: .feet), 3_280.839_895, accuracy: 0.000_001)
    }

    func testForecastKeepsItsSourceCadence() throws {
        let forecast = try Forecast(map: [
            "WINDSPD": ["0": 5.0, "1": 6.0, "2": 7.0, "3": 8.0]
        ])

        XCTAssertEqual(forecast?.availableHours, ["0", "1", "2", "3"])
    }

    func testWSpotForecast() {
        let wspotForecast: WSpotForecast?
        do {
            wspotForecast = try WSpotForecast(map: wSpotForecastDict)
        } catch {
            return XCTFail()
        }
        XCTAssertNotNil(wspotForecast)
        XCTAssertEqual(wspotForecast?.identifier, "64141")
        XCTAssertEqual(wspotForecast?.userIdentifier, "169")
        XCTAssertEqual(wspotForecast?.nickName, "other user's custom spot")
        XCTAssertEqual(wspotForecast?.spotname, "Argentina - Bariloche")
        let coordinateForecast = try? wspotForecast.flatMap(SpotForecast.from(coordinateForecast:))
        XCTAssertNotNil(coordinateForecast)
        XCTAssertNotNil(coordinateForecast?.forecast?.windSpeed(hh: "0"))
        XCTAssertEqual(wspotForecast?.location?.coordinate.latitude, -41.1281)
        XCTAssertEqual(wspotForecast?.location?.coordinate.longitude, -71.348)
        XCTAssertEqual(wspotForecast?.location?.altitude, 770)
        XCTAssertEqual(wspotForecast?.modelId, 3)
        XCTAssertEqual(wspotForecast?.elapse?.starting, "09:09")
        XCTAssertEqual(wspotForecast?.elapse?.ending, "18:19")
        XCTAssertEqual(wspotForecast?.timezoneUtc, "UTC-3")
        XCTAssertEqual(wspotForecast?.timezoneId, "America/Argentina/Mendoza")
        XCTAssertEqual(wspotForecast?.timezone?.identifier, "GMT-0300")
        XCTAssertEqual(wspotForecast?.timezone?.abbreviation(), "GMT-3")
        XCTAssertEqual(wspotForecast?.gmtHourOffset, -3)
        XCTAssertEqual(wspotForecast?.numberOfTides, 0)
        let forecast = wspotForecast?.forecast
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.numberOfHours, 127)
        XCTAssertEqual(forecast?.day(hour: 10), "09")
        XCTAssertEqual(forecast?.weekday(hour: 10), "Friday")
        XCTAssertEqual(forecast?.temperature(hour: 21), -2.9)
        XCTAssertEqual(forecast?.temperatureReal(hour: 21), -0.5)
        XCTAssertEqual(forecast?.relativeHumidity(hour: 10), 89)
        XCTAssertNil(forecast?.specificMoistureExtractionRateN(hour: 10))
        XCTAssertNil(forecast?.specificMoistureExtractionRate(hour: 10))
        XCTAssertEqual(forecast?.windSpeed(hour: 10), 8.1)
        XCTAssertEqual(forecast?.windSpeedKnots(hour: 10), 8.1)
        XCTAssertEqual(forecast?.windSpeedKmh(hour: 10), 15.0012)
        XCTAssertEqual(forecast?.windSpeedMph(hour: 10), 9.321318)
        XCTAssertEqual(forecast?.windSpeedMps(hour: 10), 4.1669963999999995)
        XCTAssertEqual(forecast?.windSpeedBft(hour: 10), 3)
        XCTAssertEqual(forecast?.windSpeedBftEffect(hour: 10), "Gentle Breeze")
        XCTAssertEqual(forecast?.windSpeedBftEffectOnSea(hour: 10), "Large wavelets. Crests begin to break. Foam of glassy appearance. Perhaps scattered white horses.")
        XCTAssertEqual(forecast?.windSpeedBftEffectOnLand(hour: 10), "Leaves and smaller twigs in constant motion.")
        XCTAssertEqual(forecast?.windDirection(hour: 10), 278)
        XCTAssertEqual(forecast?.windDirectionName(hour: 10), "WNW")
        XCTAssertEqual(forecast?.windGust(hour: 10), 14.0)
        XCTAssertEqual(forecast?.pcpt(hour: 10), 1)
        XCTAssertEqual(forecast?.seaLevelPressure(hour: 10), 1015)
        XCTAssertEqual(forecast?.freezingLevel(hour: 10), 654)
        
        // marine values
        XCTAssertEqual(forecast?.peakWavePeriod(hour: 10), 8.1)
        XCTAssertEqual(forecast?.waveHeight(hour: 122), 1.58)
        XCTAssertEqual(forecast?.meanWavePeriod(hour: 116), 6.9)
        XCTAssertEqual(forecast?.meanWaveDirection(hour: 116), 3.0)
        XCTAssertEqual(forecast?.swellHeight(hour: 10), 0.76)
        XCTAssertEqual(forecast?.swellPeriod(hour: 10), 8.0)
        XCTAssertEqual(forecast?.swellDirection(hour: 10), 320.0)
        XCTAssertEqual(forecast?.swellHeight2(hour: 10), 0.43)
        XCTAssertEqual(forecast?.swellPeriod2(hour: 10), 9.7)
        XCTAssertEqual(forecast?.swellDirection2(hour: 10), 276.0)
        XCTAssertEqual(forecast?.peakWaveDirection(hour: 10), 312.0)
        XCTAssertEqual(forecast?.significantWaveHeight(hour: 10), 0.88)
        XCTAssertEqual(forecast?.cloudCoverTotal(hour: 22), 7)
        XCTAssertEqual(forecast?.cloudCoverHigh(hour: 4), 0)
        XCTAssertEqual(forecast?.cloudCoverMid(hour: 3), 100)
        XCTAssertEqual(forecast?.cloudCoverLow(hour: 5), 100)

    }

    func testProForecastPreservesNullableWeatherValues() throws {
        let definition = Definition()
        let proPayload = try XCTUnwrap(definition.json(jsonFile: "wforecast"))
        let proForecast = try XCTUnwrap(WSpotForecast(map: proPayload))
        let convertedProForecast = try XCTUnwrap(SpotForecast.from(coordinateForecast: proForecast))
        let proWeather = try XCTUnwrap(convertedProForecast.forecast)
        let models = try XCTUnwrap(proPayload["fcst"] as? [String: Any])
        let model = try XCTUnwrap(models["3"] as? [String: Any])
        let hours = try XCTUnwrap(model["hours"] as? [Int])
        let clouds = try XCTUnwrap(model["TCDC"] as? [Any])
        let precipitation = try XCTUnwrap(model["APCP"] as? [Any])
        let hourlyPrecipitation = try XCTUnwrap(model["APCP1"] as? [Any])

        let hourIndex = 12
        let hour = String(hours[hourIndex])
        XCTAssertEqual(convertedProForecast.availableForecastHours.count, hours.count)
        XCTAssertEqual(proWeather.cloudCoverTotal(hh: hour), (clouds[hourIndex] as? NSNumber)?.intValue)
        XCTAssertEqual(proWeather.precipitation(hh: hour), (precipitation[hourIndex] as? NSNumber)?.doubleValue)
        XCTAssertEqual(proWeather.precipitation1(hh: hour), (hourlyPrecipitation[hourIndex] as? NSNumber)?.doubleValue)
    }
}

private extension ModelTests {
    func checkSpotInfo(spotInfo: SpotInfo?) {
        XCTAssertNotNil(spotInfo)
        XCTAssertEqual(spotInfo?.identifier, "64141")
        XCTAssertEqual(spotInfo?.name, "Bariloche")
        XCTAssertEqual(spotInfo?.countryName, "Argentina")
        XCTAssertEqual(spotInfo?.countryIdentifier, 32)
        XCTAssertEqual(spotInfo?.location?.coordinate.latitude, -41.1281)
        XCTAssertEqual(spotInfo?.location?.coordinate.longitude, -71.348)
        XCTAssertEqual(spotInfo?.location?.altitude, 770)
        XCTAssertEqual(spotInfo?.timezone?.identifier, "America/Argentina/Mendoza")
        XCTAssertEqual(spotInfo?.timezone?.abbreviation(), "GMT-3")
        XCTAssertEqual(spotInfo?.gmtHourOffset, -3)
        XCTAssertEqual(spotInfo?.elapse?.starting, "09:09")
        XCTAssertEqual(spotInfo?.elapse?.ending, "18:19")
        XCTAssertEqual(spotInfo?.currentModels, [100,3,45,59])
        XCTAssertEqual(spotInfo?.currentTides, "0")
    }
}
