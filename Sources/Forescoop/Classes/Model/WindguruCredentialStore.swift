//
//  WindguruCredentialStore.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation
import Security

public enum WindguruCredentialStore {
    private static let service = "Forescoop.Windguru"
    private static let activeAccountKey = "active-account"
    private static let activeProUserKey = "active-pro-user"
#if DEBUG
    private static let debugFallbackPrefix = "Forescoop.Windguru.Debug."
#endif

    public static func activeUsername() -> String? { string(for: activeAccountKey) }
    public static func saveActiveUsername(_ username: String) throws { try save(value: username, for: activeAccountKey) }
    public static func removeActiveUsername() { removeValue(for: activeAccountKey) }
    public static func activeProUser() -> Bool { string(for: activeProUserKey) == "true" }
    public static func saveActiveProUser(_ isProUser: Bool) throws { try save(value: isProUser ? "true" : "false", for: activeProUserKey) }
    public static func removeActiveProUser() { removeValue(for: activeProUserKey) }
    public static func password(for username: String) -> String? { string(for: username) }
    public static func save(password: String, for username: String) throws { try save(value: password, for: username) }
    public static func removePassword(for username: String) { removeValue(for: username) }

    private static func string(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecReturnData as String: true]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
#if DEBUG
        return UserDefaults.standard.string(forKey: debugFallbackKey(for: account))
#else
        return nil
#endif
    }

    private static func save(value: String, for account: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
        let attributes = [kSecValueData as String: Data(value.utf8)]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = Data(value.utf8)
            if SecItemAdd(item as CFDictionary, nil) == errSecSuccess { return }
        } else if status == errSecSuccess {
            return
        }
#if DEBUG
        UserDefaults.standard.set(value, forKey: debugFallbackKey(for: account))
#else
        throw WindguruCredentialStoreError.credentialsUnavailable
#endif
    }

    private static func removeValue(for account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
#if DEBUG
        UserDefaults.standard.removeObject(forKey: debugFallbackKey(for: account))
#endif
    }

#if DEBUG
    private static func debugFallbackKey(for account: String) -> String { debugFallbackPrefix + account }
#endif
}

private enum WindguruCredentialStoreError: LocalizedError {
    case credentialsUnavailable

    var errorDescription: String? {
        "The password could not be saved securely on this device."
    }
}
