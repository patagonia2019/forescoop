//
//  ForecastGraphPoint.swift
//  ForescoopGraph package
//
//  Created by Javier on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation

public struct ForecastGraphPoint: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let wind: Double
    public let gust: Double
    public let direction: Double?
    public let cloudCover: Double
    public let humidity: Double
    public let pressure: Double
    public let temperature: Double
    public let precipitation: Double

    public init(id: String, date: Date, wind: Double, gust: Double, direction: Double?, cloudCover: Double, humidity: Double, pressure: Double, temperature: Double, precipitation: Double) {
        self.id = id
        self.date = date
        self.wind = wind
        self.gust = gust
        self.direction = direction
        self.cloudCover = cloudCover
        self.humidity = humidity
        self.pressure = pressure
        self.temperature = temperature
        self.precipitation = precipitation
    }
}

public struct ForecastGraphSeries: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let points: [ForecastGraphPoint]

    public init(id: String, name: String, points: [ForecastGraphPoint]) {
        self.id = id
        self.name = name
        self.points = points
    }
}
