# Migration log

## Internal library: Forescoop

- The internal Forescoop library is a root-level Swift package with the public product and module name `Forescoop`; consumer apps depend on and import `Forescoop`. Its package container is named `ForescoopPackage` to avoid an Xcode build-graph collision with the existing watch app target named `Forescoop`.
- Package resources live in `Sources/Forescoop/Resources` and are processed by Swift Package Manager.
- The package and test targets explicitly use `Sources/Forescoop` and `Tests/ForescoopTests`; example applications and other repository directories are outside the package boundary.
- All package and application targets now require version 26.0 or later of their respective platforms: iOS, watchOS, macOS, and tvOS.
- The package manifest uses Swift tools version 6.2, the first PackageDescription version that exposes the platform 26 deployment constants.
- `Definition` loads those resources through `Bundle.module`; it no longer depends on the legacy framework/resource-bundle layout.
- Legacy dependency-manager configuration, generated workspace metadata, build phases, and framework references have been removed.
- The Xcode project links the local `Forescoop` product directly for the iOS app, its tests, watch extension, macOS app, and tvOS app. Signing, entitlements, and deployment targets are unchanged.
- Legacy demo bundle identifiers have been renamed to the `org.forescoop…` namespace at the user's request.
- `iOSnowatch` is an iOS-only example target and scheme. It shares the iOS app sources and `Forescoop` package dependency, but deliberately has no watch app dependency or embedding phase.
- `ForescoopVisionOS` is a visionOS 26.0 target and scheme that reuses the UIKit iOS example sources and the `Forescoop` package, without watch embedding.
- The iOS forecast dashboard is now `ForecastDashboardView`, a SwiftUI root view. The UIKit login and API navigation screens remain for their later feature-by-feature migration.
- `SpotResult` accepts both the legacy array and Windguru's current dictionary form of search results, so the SwiftUI dashboard can resolve a live forecast.
- The dashboard requests the known Bariloche spot ID directly, avoiding unnecessary search-result ordering and schema changes for its fixed location.
- Forecast-hour keys are displayed as offsets from the current local day: the SwiftUI dashboard labels each selector entry with today's/next day's 24-hour time (`27` is tomorrow at `03 hs`), provides previous/next controls, and derives the selected slot's weather symbol from that same timestamp. Forecast initialization metadata is not used for the displayed calendar date because fallback data can be stale.
- Windguru's live forecast response includes auxiliary model payloads that are not weather forecasts. `SpotForecast` now ignores those payloads and explicitly prefers model `3`, preventing a mapping failure and the dashboard's fallback to the dated bundled fixture.
- Wind speed and temperature units are explicit package types. The SwiftUI dashboard exposes their selectors by tapping the displayed value; wind supports knots, m/s, km/h, mph, and Beaufort, while temperature supports Celsius and Fahrenheit.
- The dashboard's forecast detail section shows gusts, Windguru-style wind-direction arrow, high/mid/low cloud cover, humidity, freezing level, and sea-level pressure for the selected three-hour slot.
- The primary wind line keeps speed, gusts, direction, and the wind-unit selector together. Tapping direction alternates between its abbreviation and a Windguru-style arrow.
- Cloud cover is presented as a three-column High/Mid/Low table, with each percentage's gray background becoming denser as coverage increases.
- Sea-level pressure is an explicit package measurement type with hPa, mbar, inHg, and mmHg conversions. Its dashboard row is a tappable unit selector; freezing level and pressure use SF Symbols.
- Weather presentation exposes all applicable SF Symbols as an array rather than collapsing compound conditions into one icon. The dashboard renders that array horizontally, always including the slot's wind and sky state alongside rain, freezing/snow, fog, or tornado conditions when present.
- Snow detection uses Windguru's hourly precipitation (`APCP1`, falling back to the larger three-hour accumulation) together with the model temperature (`TMP`), so forecast slots with precipitation below freezing include `snowflake` in their symbol row.
- `ForecastDashboardView` receives its forecast service explicitly. The app's default remains the live Windguru service, while its SwiftUI preview injects `ForecastWindguruMockup` and therefore never makes a network request.
- Tapping the forecast location opens a SwiftUI spot picker. It supports public Windguru spot search and Simulator/device location; the latter reverse-geocodes the locality and loads the first matching public Windguru spot because exact coordinate forecasts require Windguru PRO credentials.
- The last successfully loaded Windguru spot ID is stored with `AppStorage`, so refreshes and recreated dashboard views keep the user's selected location.
- Precipitation is modelled as an explicit measurement type. The dashboard prefers Windguru's three-hour accumulation (`APCP`) to match its three-hour selector, falling back to the hourly value (`APCP1`) only when needed; people can switch between millimetres and inches.
- Freezing level is an explicit measurement type, with a dashboard selector for metres and feet.
- The dashboard resolves a spot's supported forecast models from `spotInfo`, then maps their IDs to readable names via `modelInfo`; selecting one reloads only the current spot with that model.
- Model selection is multi-select. One checked model loads it directly; multiple checked models create an explicit equal-weight `Forescoop Mix`, including circular averaging for wind direction. Windguru's own `WG` mix is not used because the public forecast endpoint exposes only its metadata, not forecast values.
- Windguru PRO login is explicit in the dashboard. The username is stored in `AppStorage`, while the password is verified against Windguru and stored only in Keychain; the service now exposes the authenticated `wforecast_latlon` operation for future map-based coordinate forecasts.
- Choose Location includes a map picker. With a saved PRO session it loads Windguru's exact latitude/longitude forecast; guests resolve the tapped coordinate to the nearest public Windguru spot instead.
- Saved map locations retain both map selections and searched Windguru spots. A searched spot is saved with its resolved Windguru coordinates only when no saved location already represents that coordinate.
- The iOS example targets are universal. `ForecastDashboardView` keeps its compact phone presentation and uses a two-column layout on regular-width iPad screens; iPad supports all interface orientations.
- The iPad dashboard adds a bottom location workspace with saved-location map pins and selectable location cards. Search-derived saved locations retain their Windguru spot ID; manually pinned locations keep the existing PRO-coordinate or guest-nearest-spot behavior.
- `ForecastDashboardView` renders a non-interactive native SwiftUI animated background from the selected slot's `weatherSymbolNames()`, combining weather-aware gradient, sun glow, clouds, wind streaks, and rain or snow particles without adding a third-party dependency.
- `ForescoopVisionOS` now launches a dedicated `VisionForecastView` with a wide SwiftUI forecast window, large weather symbols, and translucent material metric cards. It intentionally avoids the iPad dashboard layout and reuses the same live forecast service.
- visionOS now uses a native `App`/`WindowGroup` lifecycle rather than the shared UIKit app delegate. The forecast window provides a bottom ornament for Locations and Refresh; Locations opens a separate spatial window with the saved-location map and list.
- `ForescoopWatchOnly` is a watchOS 26 SwiftUI target and shared scheme. Its intentionally compact interface shows only location, weather symbols, temperature, wind speed, and forecast hour, using the local Swift package directly without the legacy WatchKit extension. It declares `iOSnowatch` as its WatchKit companion, so its bundle identifier is nested under that app's identifier as required by watchOS installation.
- The watch dashboard uses a dedicated, persistent spot selector rather than a refresh button. Watch and iPhone app containers are separate, so watch locations are stored locally until an App Group is explicitly introduced.
- `ForescoopMacOS` now hosts the shared SwiftUI forecast dashboard in a desktop window. macOS always uses the dashboard's wide, iPad-style layout, including the location map and saved-location workspace; iOS keeps its existing compact/adaptive behavior.

### Verification

- Swift package tests pass with all platform minimums set to 26.
- The watch-enabled iOS, macOS, and tvOS example schemes build successfully against their 26.0 Simulator/SDK targets.
- `swift test` builds the package successfully, loads all resource fixtures, and passes all 12 tests.
- The normal signed `ForescoopMacOS` Xcode build succeeds with the local package resolved by Swift Package Manager; its generated resource bundle is a valid signed bundle.
- The watch-enabled `Forescoop_Example` scheme builds successfully for an iOS Simulator when the destination is specified without forcing an iOS SDK, allowing Xcode to use the watchOS Simulator SDK for the embedded watch targets.
- The shared app delegate now has a tvOS-specific branch, allowing the tvOS storyboard to own its initial view controller without referencing the iOS-only `MainViewController`.
- `swift test` passes with a regression assertion that an hour offset of `27` resolves to tomorrow at 03:00 relative to a supplied current day; the iOS-only `iOSnowatch` scheme builds for an iOS Simulator.
