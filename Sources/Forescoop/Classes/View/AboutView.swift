//
//  AboutView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation
import SwiftUI

/// Product and acknowledgement information for Ventus.
public struct AboutView: View {
    public init() {}

    public var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: "wind")
                        .font(.system(size: 36))
                        .foregroundStyle(.tint)
                        .frame(width: 52, height: 52)
                        .background(.tint.opacity(0.12), in: .rect(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Ventus")
                            .font(.title2.bold())
                        Text("Wind and weather forecasts")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                LabeledContent("Created by", value: "Javier Fuchs")
                LabeledContent("Version", value: versionDescription)
                Link(destination: URL(string: "mailto:javier.fuchs@gmail.com")!) {
                    Label("javier.fuchs@gmail.com", systemImage: "envelope")
                }
                Link(destination: URL(string: "https://github.com/patagonia2019/forescoop")!) {
                    Label("Ventus on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }

            Section("Supported devices") {
                LabeledContent("Minimum Apple OS", value: "Version 26 or later")
                supportedDevice("macOS", symbol: "laptopcomputer")
                supportedDevice("iOS", symbol: "iphone")
                supportedDevice("iPadOS", symbol: "ipad")
                supportedDevice("watchOS", symbol: "applewatch")
                supportedDevice("visionOS", symbol: "visionpro")
                supportedDevice("tvOS", symbol: "appletv")
            }

            Section("External libraries") {
                Link(destination: URL(string: "https://github.com/airbnb/lottie-spm")!) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lottie")
                            Text("Animation framework by Airbnb")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "play.rectangle")
                    }
                }
            }

            Section("Forecast data") {
                Link(destination: URL(string: "https://www.windguru.cz")!) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Windguru API")
                            Text("Forecast and location data")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "wind")
                    }
                }
                Text("Thank you to Windguru for making its forecast API available to anyone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Animation artwork") {
                Link(destination: URL(string: "https://lottiefiles.com/d264bhmrid6j0w1s")!) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lottie – Adriana")
                            Text("Weather animations by Adriana Mandjarova")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart")
                    }
                }
                Text("Thank you to Adriana Mandjarova for sharing these free Lottie weather animations.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Link(destination: URL(string: "https://lottiefiles.com/asadawan")!) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lottie – Asad")
                            Text("Weather animations by Asad Awan")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart")
                    }
                }
                Text("Thank you to Asad Awan for sharing these free Lottie weather animations.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }

    private var versionDescription: String {
        guard let metadataURL = Bundle.module.url(forResource: "VentusPackageInfo", withExtension: "plist"),
              let metadataData = try? Data(contentsOf: metadataURL),
              let metadata = try? PropertyListSerialization.propertyList(
                  from: metadataData,
                  format: nil
              ) as? [String: Any],
              let version = metadata["CFBundleShortVersionString"] as? String else {
            return "0.1.0"
        }
        let build = metadata["CFBundleVersion"] as? String
        guard let build, build != version else { return version }
        return "\(version) (\(build))"
    }

    @ViewBuilder
    private func supportedDevice(_ name: String, symbol: String) -> some View {
        Label(name, systemImage: symbol)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
