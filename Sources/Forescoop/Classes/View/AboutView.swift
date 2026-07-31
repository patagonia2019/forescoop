//
//  AboutView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

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
            }

            Section("Supported devices") {
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
