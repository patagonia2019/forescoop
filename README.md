# Forescoop

Forescoop is a Swift weather-forecast framework and a set of sample apps built around the Windguru API. The shared package provides forecast retrieval, typed domain models, units and weather presentation helpers; the example targets show a modern SwiftUI forecast experience across Apple platforms.

![Forescoop architecture](docs/architecture.png)

The editable source for this diagram is [docs/architecture.puml](docs/architecture.puml).

## Highlights

- Live Windguru spot forecasts, spot search, model metadata, and optional Windguru PRO coordinate forecasts.
- SwiftUI forecast dashboards for iPhone, iPad, macOS, and visionOS, plus a compact watchOS forecast and location picker.
- Forecast-model multi-selection with a local equal-weight **Forescoop Mix**, including circular wind-direction averaging.
- Explicit units for wind, temperature, precipitation, freezing level, and sea-level pressure.
- Weather-aware native SwiftUI background effects, including wind, clouds, rain, and snow.
- Fixture-backed mock service for SwiftUI previews and tests that do not make network requests.

## Platforms and targets

The package requires Swift tools 6.2 and Apple platform version 26.0 or later.

| Target | Experience |
| --- | --- |
| iOS / iPadOS | `ForecastDashboardView`, spot/map picker, saved locations, model selection, and Windguru PRO sign-in |
| macOS | Wide dashboard with the saved-location map workspace |
| visionOS | Dedicated SwiftUI forecast window and a separate Locations window |
| watchOS | Compact forecast and persistent local spot selector |
| tvOS | Storyboard-based sample app |

`iOSnowatch` is an iOS-only sample target. `ForescoopWatchOnly` is a separate watchOS app whose companion is `iOSnowatch`.

## Add the framework

Add this repository in Xcode's **Package Dependencies** UI, or declare it in a package manifest:

```swift
.package(url: "https://github.com/patagonia2019/forescoop.git", from: "0.1.0")
```

Add the `Forescoop` product to your target, then import it:

```swift
import Forescoop
```

The package container is named `ForescoopPackage`; its public library product and module are both named `Forescoop`.

## Run the examples

Open [Example/Forescoop.xcodeproj](Example/Forescoop.xcodeproj) in Xcode. It resolves the local Swift package directly and contains shared schemes for iOS, macOS, tvOS, visionOS, and watchOS.

To exercise the framework and its bundled fixtures from the command line:

```sh
swift test
```

## Forecast data and privacy

The dashboard starts with Windguru's live public forecast service. It remembers the last selected Windguru spot and saved locations using `AppStorage`. A Windguru PRO sign-in enables exact latitude/longitude forecasts: the username is stored with app preferences, while the password is retained only in Keychain. Guest map selections resolve to the nearest public Windguru spot instead.

For offline previews and tests, inject `ForecastWindguruMockup`; it reads JSON fixtures from `Sources/Forescoop/Resources` through `Bundle.module`.

## Architecture

The example apps depend on `ForecastWindguruProtocol`, rather than on the network implementation directly. `ForecastWindguruService` uses `URLSession` to map Windguru responses into the shared forecast domain. `ForecastWindguruMockup` implements the same protocol with bundled fixtures.

The [PlantUML source](docs/architecture.puml) is the canonical diagram. Regenerate `docs/architecture.png` with PlantUML after changing it:

```sh
plantuml -tpng docs/architecture.puml
```

## Migration notes

The former standalone migration log is maintained here.

- The internal library was migrated to the root Swift package, with resources processed by Swift Package Manager and loaded through `Bundle.module`. Legacy dependency-manager configuration, generated workspace metadata, framework references, and build phases were removed.
- Every package and example target has a 26.0 deployment target. The Xcode project links the local `Forescoop` product directly for iOS, watchOS, macOS, tvOS, and visionOS.
- The iOS dashboard moved to the SwiftUI `ForecastDashboardView`; UIKit login and API-navigation screens remain while they are migrated incrementally. iPad uses an adaptive two-column dashboard, while macOS always uses the wide layout.
- Forecast display is based on the current local day, so an hour key of `27` means tomorrow at 03:00. The detail view includes speed, gusts, direction, cloud cover, humidity, freezing level, and pressure, with selectable units.
- Public spot forecasts explicitly prefer Windguru model `3` and ignore auxiliary non-forecast model payloads. Multiple selected models form the local `Forescoop Mix`; Windguru's metadata-only `WG` mix is not used.
- The location flow supports public search, device/map selection, saved locations, and the Windguru PRO exact-coordinate path. Search-derived saved locations retain their resolved spot ID.
- visionOS uses a native `App`/`WindowGroup` lifecycle, and the watchOS app uses its own local saved locations because its container is separate from the iPhone app.

## License

Forescoop is available under the MIT license. See [LICENSE](LICENSE).

## Author

southfox — javier.fuchs@gmail.com
