import XCTest
import CoreLocation
import Forescoop

class ModelTests: XCTestCase {
    
    private var definition: Definition?
    private var countriesDict: [String: Any]?
    private var spotResultDict: [String: Any]?
    private var anonymousUserDict: [String: Any]?
    private var geoRegionsDict: [String: Any]?
    private var regionsDict: [String: Any]?
    private var spotInfoDict: [String: Any]?
    private var modelsDict: [String: Any]?
    private var spotForecastDict: [String: Any]?

    override func setUp() {
        super.setUp()
        definition = Definition()
        countriesDict = definition?.json(jsonFile: "Countries")
        XCTAssertNotNil(countriesDict)
        spotResultDict = definition?.json(jsonFile: "SpotResult")
        XCTAssertNotNil(spotResultDict)
        anonymousUserDict = definition?.json(jsonFile: "User")
        XCTAssertNotNil(anonymousUserDict)
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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCountries() {
        let countries = Countries(map: countriesDict)
        XCTAssertNotNil(countries)
        XCTAssertEqual(countriesDict?.count, countries.sorted.count)
        XCTAssertEqual(countries.sorted.first?.oficialName, "Argentina")
        XCTAssertEqual(countries.sorted.first?.identifier, "32")
    }
    
    func testSpotResult() {
        let spotResult = SpotResult(map: spotResultDict)
        XCTAssertNotNil(spotResult)
        XCTAssertEqual(spotResult?.numberOfSpots, 20)
        let spot = spotResult?.firstSpot
        XCTAssertEqual(spot?.name, "Bariloche")
        XCTAssertEqual(spot?.userIdentifier, "169")
        XCTAssertEqual(spot?.identifier, "64141")
        XCTAssertEqual(spot?.countryName, "Argentina")
        XCTAssertNil(spot?.nickName)
    }
    
    func testSpotNickname() {
        let spotResult = SpotResult(map: spotResultDict)
        let spot = spotResult?.find(nickname: "EAPCM")
        XCTAssertNotNil(spot)
        XCTAssertEqual(spot?.name, "Argentina,  Bariloche, playa sin viento L. Moreno este")
    }
    
    func testAnonymousUser() {
        let user = User(map: anonymousUserDict)
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
        let geoRegions = GeoRegions(map: geoRegionsDict)
        XCTAssertNotNil(geoRegions)
        XCTAssertEqual(geoRegionsDict?.count, geoRegions?.sorted.count)
        XCTAssertEqual(geoRegions?.sorted.first?.oficialName, "Africa")
    }

    func testRegions() {
        let regions = GeoRegions(map: regionsDict)
        XCTAssertNotNil(regions)
        XCTAssertEqual(regionsDict?.count, regions?.sorted.count)
        XCTAssertEqual(regions?.sorted.first?.oficialName, "Acre")
    }

    func testSpotInfo() {
        let spotInfo = SpotInfo(map: spotInfoDict)
        checkSpotInfo(spotInfo: spotInfo)
    }
    
    func testModels() {
        let models = Models(map: modelsDict)?.sorted
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
        let spotForecast = SpotForecast(map: spotForecastDict)
        checkSpotInfo(spotInfo: spotForecast)
        XCTAssertEqual(spotForecast?.numberOfForecasts, 1)
        XCTAssertEqual(spotForecast?.model, "3")
        let forecast = spotForecast?.forecast
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.initializationStamp, 1686160800)
        XCTAssertEqual(forecast?.initializationDate, DateTime("2023-06-07 18:00:00", gmtHourOffset: 0)?.asDate)
        XCTAssertEqual(forecast?.modelName, "GFS 13 km")
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
