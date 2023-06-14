//
//  ApiController.swift
//  Forescoop_Example
//
//  Created by fox on 14/06/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Forescoop

protocol ApiControllerDelegate {
    func showApiInfo(info: String)
    func showError(service: String?, error: Error?)
}

enum AnonymousBaseServices: String, CaseIterable {
    case user
    case geo_regions
    case countries
    case regions
    case spot
    case spots
    case search_spots
    case model_info
    case models_latlon
    case forecast
    static var allCases: [AnonymousBaseServices] {
        return [.user, .geo_regions, .countries, .regions, .spot, spots, .search_spots, .model_info, .models_latlon, .forecast]
    }
    static var allStrings: [String] {
        return allCases.map { $0.rawValue }
    }
}

enum UserBasedServices: String, CaseIterable {
    case add_f_spot
    case remove_f_spot
    case f_spots
    case c_spots
    case set_spots
    case sets
    case wforecast
    case wforecast_latlon
    static var allCases: [UserBasedServices] {
        return [.add_f_spot, .remove_f_spot, .f_spots, .c_spots, .set_spots, .sets, .wforecast, .wforecast_latlon]
    }
    static var allStrings: [String] {
        return allCases.map { $0.rawValue }
    }
}

class ApiController {
    private (set) var user: User?
    private (set) var password: String?
    var service: String {
        services[currentServicerOrdinal]
    }
    var currentServicerOrdinal: Int = 0
    private (set) var forecastService: ForecastWindguruProtocol? = nil
    
    lazy var services: [String] = {
        isUserAnonymous == false ? AnonymousBaseServices.allStrings + UserBasedServices.allStrings : AnonymousBaseServices.allStrings
    }()

    var numberOfServices: Int {
        services.count
    }
    
    subscript(index: Int) -> String {
        get {
            return services[index]
        }
    }
    
    var delegate: ApiControllerDelegate?
    
    init(user: User? = nil, password: String? = nil, forecastService: ForecastWindguruProtocol? = nil, delegate: ApiControllerDelegate? = nil) {
        self.user = user
        self.password = password
        self.forecastService = forecastService
        self.delegate = delegate
    }
    
    func start() async throws -> SpotForecast? {
        guard let spotId = try? await forecastService?.searchSpots(byLocation: "Bariloche")?.firstSpot?.identifier else { throw CustomError.cannotFindSpotId }
        let spotForecast = try? await forecastService?.forecast(bySpotId: spotId, model: nil)
        return spotForecast
    }
    
    func addSetSpots(id: String?) {
        guard let id = id else {
            shouldShowMessage("Missing mandatory field: [Set Id]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.addSetSpots(withSetId: id, username: user?.name, password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func loginAnonymous() {
        Task {
            do {
                user = try await forecastService?.login(withUsername: nil, password: nil)
                shouldShowApiInfo(info: user?.description)
                password = nil
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func login(username: String?, pass: String?) {
        guard let username = username, username.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [Username]")
            return
        }
        guard let pass = pass, username.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [Password]")
            return
        }
        Task {
            do {
                user = try await forecastService?.login(withUsername: username, password: pass)
                password = pass
                shouldShowApiInfo(info: user?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func geoRegions() {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.geoRegions()?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func addFavoriteSpot(id: String?) {
        guard let id = id, id.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [Spot Id]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.addFavoriteSpot(withSpotId: id, username: user?.name, password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }

    func removeFavoriteSpot(id: String?) {
        guard let id = id, id.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [Spot Id]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.removeFavoriteSpot(withSpotId: id, username: user?.name, password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func forecastSpot(id: String?, model: String?) {
        guard let id = id, id.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [Spot Id]")
            return
        }
        
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.forecast(bySpotId: id, model: model?.isEmpty == true ? nil : model)?.description)
            } catch {
                shouldShowError(error)
            }
        }
   }
    
    func spotInfo(spotId: String?) {
        guard let spotId = spotId, !spotId.isEmpty else {
            shouldShowMessage("Missing mandatory field: [Spot Id]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.spotInfo(bySpotId: spotId)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }

    func spots(countryId: String?, regionId: String?) {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.spots(withCountryId: countryId, regionId: regionId)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func searchSpots(location: String?) {
        guard let location = location, !location.isEmpty else {
            shouldShowMessage("Missing mandatory field: [Location]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.searchSpots(byLocation: location)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
        
    func customSpots() {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.customSpots(withUsername: user?.name, password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func favoriteSpots() {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.favoriteSpots(withUsername: user?.name, password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func setSpots() {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.setSpots(withUsername: user?.name, password: password)?.description)

            } catch {
                shouldShowError(error)
            }
        }
    }

    func modelInfo(id: String?) {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.modelInfo(onlyModelId: id?.isEmpty == true ? nil : id)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func countries(regionId: String?) {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.countries(byRegionId: regionId?.isEmpty == true ? nil : regionId)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func regions(countryId: String?) {
        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.regions(byCountryId: countryId?.isEmpty == true ? nil : countryId)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func models(lat: String?, lon: String?) {
        guard let lat = lat, lat.isEmpty == false,
            let lon = lon, lon.isEmpty == false
        else {
            shouldShowMessage("Missing mandatory field: [lat] / [lon]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.models(bylat: lat, lon: lon)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    func wforecast(spotId: String?, modelId: String?) {
        guard let spotId = spotId, spotId.isEmpty == false else {
            shouldShowMessage("Missing mandatory field: [spot id]")
            return
        }

        Task {
            do {
                shouldShowApiInfo(info: try await forecastService?.wforecast(bySpotId: spotId,
                                                                             model: modelId?.isEmpty == true ? nil : modelId,
                                                                             username: user?.name,
                                                                             password: password)?.description)
            } catch {
                shouldShowError(error)
            }
        }
    }
    
    var isUserAnonymous: Bool {
        user?.isAnonymous == true
    }
    
    var userDescription: String? {
        user?.description
    }
    
    var userName: String? {
        user?.name
    }
}

private extension ApiController {
    
    func shouldShowApiInfo(info: String?) {
        DispatchQueue.main.sync {
            delegate?.showApiInfo(info: info ?? "n/a")
        }
    }
    
    func shouldShowError(_ error: Error) {
        DispatchQueue.main.sync {
            delegate?.showError(service: service, error: error)
        }
    }
    
    func shouldShowMessage(_ message: String) {
        let error = CustomError.unexpected(code: -1, message: message)
        delegate?.showError(service: service, error: error)
    }
}
