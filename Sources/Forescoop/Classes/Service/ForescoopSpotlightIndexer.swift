#if canImport(CoreSpotlight) && !os(tvOS) && !os(watchOS)
import CoreSpotlight

/// Makes a person's current forecast and saved locations discoverable through
/// the system search UI on platforms that offer Core Spotlight.
public enum ForescoopSpotlightIndexer {
    private static let domain = "org.forescoop.forecast"

    public static func index(forecast: SpotForecast, savedLocations: [SavedMapLocation]) {
        var items = [forecastItem(forecast)]
        items.append(contentsOf: savedLocations.map(locationItem))

        CSSearchableIndex.default().indexSearchableItems(items) { _ in
            // Spotlight is supplementary; forecast presentation must never be
            // blocked by an indexing failure.
        }
    }

    private static func forecastItem(_ forecast: SpotForecast) -> CSSearchableItem {
        let hour = forecast.currentForecastHour
        let weather = forecast.forecast
        let temperature = weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour)
        let wind = weather?.windSpeed(hh: hour)
        let attributes = CSSearchableItemAttributeSet(itemContentType: "public.text")
        let location = forecast.locationDisplayName()
        attributes.title = "Forecast · \(location)"
        attributes.contentDescription = [
            temperature.map { "\(Int($0.rounded()))°C" },
            wind.map { "\(Int($0.rounded())) kt wind" }
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
        attributes.keywords = ["forecast", "weather", "wind", location]
        attributes.contentCreationDate = .now
        return CSSearchableItem(
            uniqueIdentifier: "\(domain).current.\(forecast.identifier ?? "default")",
            domainIdentifier: domain,
            attributeSet: attributes
        )
    }

    private static func locationItem(_ location: SavedMapLocation) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(itemContentType: "public.place")
        attributes.title = "Forecast · \(location.displayName)"
        attributes.contentDescription = location.detailText
        attributes.keywords = ["forecast", "weather", "wind", location.name, location.displayName]
        attributes.latitude = location.latitude as NSNumber
        attributes.longitude = location.longitude as NSNumber
        return CSSearchableItem(
            uniqueIdentifier: "\(domain).location.\(location.id.uuidString)",
            domainIdentifier: domain,
            attributeSet: attributes
        )
    }
}
#else
public enum ForescoopSpotlightIndexer {
    public static func index(forecast: SpotForecast, savedLocations: [SavedMapLocation]) {}
}
#endif
