//
//  WatchOnlyApp.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI
import Forescoop

@main
struct ForescoopWatchOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            WatchForecastView()
        }
    }
}

private struct WatchForecastView: View {
    private let forecastService: ForecastWindguruProtocol = ForecastWindguruService()
    @AppStorage("watchSelectedWindguruSpotID") private var selectedSpotID = "64141"
    @State private var locations = WatchLocationStore.load()
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    let hour = forecast.currentForecastHour
                    let weather = forecast.forecast
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Text(forecast.asCurrentLocation ?? selectedLocation?.name ?? "Forecast")
                            .font(.headline)
                            .lineLimit(1)

                            NavigationLink(value: WatchDestination.locations) {
                                Image(systemName: "mappin.circle.fill")
                            }
                            .accessibilityLabel("Choose location")
                        }

                        HStack(spacing: 5) {
                            ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) {
                                Image(systemName: $0)
                            }
                        }
                        .font(.title2)

                        Text(temperature(weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour)))
                            .font(.system(.title2, design: .rounded).weight(.semibold))

                        Label(wind(weather?.windSpeed(hh: hour)), systemImage: "wind")
                            .font(.caption)
                        Text("Updated for \(hour ?? "—") hs")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                } else if let errorMessage {
                    ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: WatchDestination.self) { destination in
                switch destination {
                case .locations:
                    WatchLocationPicker(
                        locations: locations,
                        selectedSpotID: selectedSpotID,
                        select: select,
                        add: add
                    )
                }
            }
        }
        .task { await loadForecast() }
        .onChange(of: selectedSpotID) { _, _ in
            Task { await loadForecast() }
        }
    }

    @MainActor
    private func loadForecast() async {
        do {
            errorMessage = nil
            forecast = try await forecastService.forecast(bySpotId: selectedSpotID, model: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var selectedLocation: WatchLocation? {
        locations.first { $0.spotID == selectedSpotID }
    }

    private func select(_ location: WatchLocation) {
        selectedSpotID = location.spotID
    }

    private func add(_ location: WatchLocation) {
        guard locations.contains(where: { $0.spotID == location.spotID }) == false else {
            selectedSpotID = location.spotID
            return
        }
        locations.append(location)
        WatchLocationStore.save(locations)
        selectedSpotID = location.spotID
    }

    private func temperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0))))°C"
    }

    private func wind(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0)))) kt"
    }
}

private enum WatchDestination: Hashable {
    case locations
}

private struct WatchLocation: Codable, Identifiable, Hashable {
    let spotID: String
    let name: String

    var id: String { spotID }
}

private enum WatchLocationStore {
    private static let key = "watchSavedWindguruLocations"
    private static let defaultLocations = [WatchLocation(spotID: "64141", name: "Bariloche")]

    static func load() -> [WatchLocation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let locations = try? JSONDecoder().decode([WatchLocation].self, from: data),
              locations.isEmpty == false else {
            return defaultLocations
        }
        return locations
    }

    static func save(_ locations: [WatchLocation]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(locations), forKey: key)
    }
}

private struct WatchLocationPicker: View {
    let locations: [WatchLocation]
    let selectedSpotID: String
    let select: (WatchLocation) -> Void
    let add: (WatchLocation) -> Void

    var body: some View {
        List {
            Section("Locations") {
                ForEach(locations) { location in
                    Button {
                        select(location)
                    } label: {
                        HStack {
                            Label(location.name, systemImage: "mappin.circle")
                            Spacer()
                            if location.spotID == selectedSpotID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }

            HStack {
                Spacer()
                NavigationLink(value: true) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityLabel("Add Windguru spot")
                Spacer()
            }
        }
        .navigationTitle("Location")
        .navigationDestination(for: Bool.self) { _ in
            WatchSpotIDEditor(add: add)
        }
    }
}

private struct WatchSpotIDEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var spotID = ""
    let add: (WatchLocation) -> Void

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Windguru spot ID", text: $spotID)

            Button {
                let trimmedID = spotID.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedID.isEmpty == false else { return }
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                add(WatchLocation(spotID: trimmedID, name: trimmedName.isEmpty ? "Windguru spot" : trimmedName))
                dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
            }
            .accessibilityLabel("Add location")
            .disabled(spotID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .navigationTitle("Add location")
    }
}
#endif
