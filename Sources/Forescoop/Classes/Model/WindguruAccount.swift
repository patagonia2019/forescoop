//
//  WindguruAccount.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Combine
import Foundation

@MainActor
public final class WindguruAccount: ObservableObject {
    @Published public private(set) var username: String
    @Published public private(set) var isProUser: Bool
    @Published public private(set) var profile: User?

    public var password: String? { WindguruCredentialStore.password(for: username) }
    public var isAuthenticated: Bool { !username.isEmpty && password != nil }

    public init() {
        username = WindguruCredentialStore.activeUsername() ?? ""
        isProUser = WindguruCredentialStore.activeProUser()
    }

    public init(username: String, isProUser: Bool = false) {
        self.username = username
        self.isProUser = isProUser
    }

    public func signIn(username: String, isProUser: Bool) {
        self.username = username
        self.isProUser = isProUser
        try? WindguruCredentialStore.saveActiveUsername(username)
        try? WindguruCredentialStore.saveActiveProUser(isProUser)
    }

    public func update(profile: User) {
        self.profile = profile
        isProUser = profile.isPro
        try? WindguruCredentialStore.saveActiveProUser(profile.isPro)
    }

    public func signOut() {
        WindguruCredentialStore.removePassword(for: username)
        username = ""
        isProUser = false
        profile = nil
        WindguruCredentialStore.removeActiveUsername()
        WindguruCredentialStore.removeActiveProUser()
    }
}
