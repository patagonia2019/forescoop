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
                NavigationLink { WatchSpotIDEditor(add: add) } label: { Image(systemName: "plus.circle.fill").font(.title3) }
                    .accessibilityLabel("Add Windguru spot")
                Spacer()
            }
        }
        .navigationTitle("Location")
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
                let identifier = spotID.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !identifier.isEmpty else { return }
                let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
                add(WatchLocation(spotID: identifier, name: title.isEmpty ? "Windguru spot" : title))
                dismiss()
            } label: { Image(systemName: "checkmark.circle.fill").font(.title3) }
            .accessibilityLabel("Add location")
            .disabled(spotID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .navigationTitle("Add location")
    }
}
#endif
