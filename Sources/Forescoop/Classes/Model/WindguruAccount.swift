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
        let legacyUsername = UserDefaults.standard.string(forKey: "windguruUsername")
        username = WindguruCredentialStore.activeUsername() ?? legacyUsername ?? ""
        if WindguruCredentialStore.activeUsername() == nil, let legacyUsername {
            try? WindguruCredentialStore.saveActiveUsername(legacyUsername)
            UserDefaults.standard.removeObject(forKey: "windguruUsername")
        }
        isProUser = UserDefaults.standard.bool(forKey: "windguruIsProUser")
    }

    public init(username: String, isProUser: Bool = false) {
        self.username = username
        self.isProUser = isProUser
    }

    public func signIn(username: String, isProUser: Bool) {
        self.username = username
        self.isProUser = isProUser
        try? WindguruCredentialStore.saveActiveUsername(username)
        UserDefaults.standard.set(isProUser, forKey: "windguruIsProUser")
    }

    public func update(profile: User) {
        self.profile = profile
        isProUser = profile.isPro
        UserDefaults.standard.set(profile.isPro, forKey: "windguruIsProUser")
    }

    public func signOut() {
        WindguruCredentialStore.removePassword(for: username)
        username = ""
        isProUser = false
        profile = nil
        WindguruCredentialStore.removeActiveUsername()
        UserDefaults.standard.removeObject(forKey: "windguruIsProUser")
    }
}
