//
//  NotePersistenceStore.swift
//  kalendar
//
//  Persists day notes locally and mirrors them through iCloud key-value storage
//  so they sync across a user's devices signed into the same Apple ID.

import Foundation

struct UserDayData: Codable {
    var comments: [String]
}

enum NotePersistenceStore {
    private static let key = "com.kalendar.userDayData"

    /// Fires when iCloud delivers a change made on another device. Observe this to
    /// re-merge notes into the in-memory model.
    static let didChangeExternally = NSUbiquitousKeyValueStore.didChangeExternallyNotification

    static func startSyncing() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    /// iCloud data wins when present, since it reflects the most recent sync from
    /// any device; local UserDefaults data covers the case where iCloud hasn't
    /// synced yet (no account, entitlement not provisioned, or offline).
    static func load() -> [String: UserDayData] {
        decode(NSUbiquitousKeyValueStore.default.data(forKey: key))
            ?? decode(UserDefaults.standard.data(forKey: key))
            ?? [:]
    }

    static func save(_ data: [String: UserDayData]) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: key)
        NSUbiquitousKeyValueStore.default.set(encoded, forKey: key)
    }

    private static func decode(_ data: Data?) -> [String: UserDayData]? {
        guard let data, let decoded = try? JSONDecoder().decode([String: UserDayData].self, from: data) else {
            return nil
        }
        return decoded
    }
}
