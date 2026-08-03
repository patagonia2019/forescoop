//
//  WatchLocationPicker.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI

struct WatchLocation: Codable, Identifiable, Hashable {
    let spotID: String
    let name: String
    var id: String { spotID }
}

enum WatchLocationStore {
    private static let key = "watchSavedWindguruLocations"
    private static let defaultLocations = [WatchLocation(spotID: "64141", name: "Bariloche")]

    static func load() -> [WatchLocation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let locations = try? JSONDecoder().decode([WatchLocation].self, from: data),
              !locations.isEmpty else { return defaultLocations }
        return locations
    }

    static func save(_ locations: [WatchLocation]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(locations), forKey: key)
    }
}

struct WatchLocationPicker: View {
    let locations: [WatchLocation]
    let selectedSpotID: String
    nonisolated(unsafe) let forecastService: ForecastWindguruProtocol
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
                            if location.spotID == selectedSpotID { Image(systemName: "checkmark").foregroundStyle(.tint) }
                        }
                    }
                }
            }
            HStack {
                Spacer()
                NavigationLink { WatchSpotSearchView(forecastService: forecastService, add: add) } label: { Image(systemName: "plus.circle.fill").font(.title3) }
                    .accessibilityLabel("Search and add Windguru spot")
                Spacer()
            }
        }
        .navigationTitle("Location")
        .forecastAccessibilityContainer(
            "Watch locations",
            hint: "Select a saved location or search Windguru spots by name.",
            identifier: "watch.locations"
        )
    }
}

private struct WatchSpotSearchView: View {
    @Environment(\.dismiss) private var dismiss
    nonisolated(unsafe) let forecastService: ForecastWindguruProtocol
    @State private var query = ""
    @State private var spotID = ""
    @State private var results = [SpotOwner]()
    @State private var isSearching = false
    @State private var errorMessage: String?
    let add: (WatchLocation) -> Void

    var body: some View {
        List {
            Section("Search Windguru") {
                TextField("Spot name", text: $query)
                    .onSubmit { Task { await search() } }
                Button("Search", systemImage: "magnifyingglass") {
                    Task { await search() }
                }
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearching)
                if isSearching { ProgressView("Searching spots…") }
                if let errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.red) }
            }

            if !results.isEmpty {
                Section("Results") {
                    ForEach(results, id: \.identifier) { spot in
                        Button {
                            guard let identifier = spot.identifier else { return }
                            add(WatchLocation(spotID: identifier, name: spot.name ?? "Windguru spot"))
                            dismiss()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(spot.name ?? "Windguru spot")
                                Text(spot.countryName ?? "").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Add by ID") {
                TextField("Windguru spot ID", text: $spotID)
                Button("Add spot ID", systemImage: "checkmark.circle.fill") {
                    let identifier = spotID.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !identifier.isEmpty else { return }
                    add(WatchLocation(spotID: identifier, name: "Windguru spot #\(identifier)"))
                    dismiss()
                }
                .disabled(spotID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Add location")
    }

    @MainActor
    private func search() async {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }
        do {
            results = try await forecastService.searchSpots(byLocation: searchTerm)?.allSpots ?? []
            if results.isEmpty { errorMessage = "No spots found." }
        } catch {
            errorMessage = "Couldn’t search spots."
        }
    }
}
#endif
