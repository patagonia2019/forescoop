//
//  WindguruProfileView.swift
//  Forescoop package
//

#if !os(watchOS)
import Foundation
import SwiftUI

public struct WindguruProfileView: View {
    public let user: User
    private let onSignOut: () -> Void

    public init(
        user: User,
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        username: String? = nil,
        password: String? = nil,
        onSignOut: @escaping () -> Void = {}
    ) {
        self.user = user
        _ = forecastService
        _ = username
        _ = password
        self.onSignOut = onSignOut
    }

    public var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name)
                            .font(.title3.bold())
                        Text(user.username ?? "Windguru account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 34))
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)

                LabeledContent("Account ID", value: "#\(user.id_user)")
                LabeledContent("Membership", value: user.isPro ? "Windguru PRO" : "Standard")
                if user.noAdvertisement {
                    Label("Ad-free account", systemImage: "checkmark.shield")
                        .foregroundStyle(.secondary)
                }

                Button("Logout", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: onSignOut)
            } header: {
                Text("Account")
            }

            Section("Forecast preferences") {
                LabeledContent("Wind", value: unitLabel(user.windUnits, fallback: "Default"))
                LabeledContent("Temperature", value: unitLabel(user.temperatureUnits, fallback: "Default"))
                LabeledContent("Waves", value: unitLabel(user.waveUnits, fallback: "Default"))
                if user.viewHoursTo > user.viewHoursFrom {
                    LabeledContent("Visible hours", value: "\(user.viewHoursFrom):00–\(user.viewHoursTo):00")
                }
                if !user.windRatingLimits.isEmpty {
                    LabeledContent("Wind ratings", value: user.windRatingLimits.map { String(format: "%.1f", $0) }.joined(separator: ", "))
                }
            }

        }
#if os(macOS)
        .listStyle(.inset)
#elseif !os(tvOS)
        .listStyle(.insetGrouped)
#endif
    }

    private func unitLabel(_ value: String?, fallback: String) -> String {
        guard let value, !value.isEmpty else { return fallback }
        return value.uppercased()
    }
}

#Preview("Windguru PRO profile") {
    let user = try! User(map: [
        "id_user": 42,
        "username": "forescoop",
        "pro": 1,
        "no_ads": 1,
        "wind_units": "knots",
        "temp_units": "c",
        "wave_units": "m",
        "view_hours_from": 3,
        "view_hours_to": 22,
        "wind_rating_limits": [10.6, 15.6, 19.4]
    ])!
    WindguruProfileView(user: user, forecastService: ForecastWindguruMockup())
}
#endif
