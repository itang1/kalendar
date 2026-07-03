//
//  NotePersistenceStore.swift
//  kalendar
//
//  Persists day notes locally and mirrors them through iCloud key-value storage
//  so they sync across a user's devices signed into the same Apple ID.
//
//  Each day is stored under its own key ("note.<dayKey>") rather than in a single
//  blob. Per-day keys mean two devices editing different days offline don't clobber
//  each other on the next sync, keep us far under the 1 MB / 1024-key KVS quota,
//  and let a deletion propagate: removing a day's key (and its absence from the
//  synced set) is what tells other devices the note is gone.

import Foundation

struct UserDayData: Codable {
    var comments: [String]
}

enum NotePersistenceStore {
    /// Namespace for the per-day keys. The stored key is `keyPrefix + dayKey`.
    private static let keyPrefix = "note."
    /// The single-blob key used by earlier versions, migrated on first launch.
    private static let legacyKey = "com.kalendar.userDayData"

    private static var cloud: NSUbiquitousKeyValueStore { .default }
    private static var local: UserDefaults { .standard }

    /// Whether the user is signed into iCloud. When true, the iCloud store is the
    /// source of truth (its set of keys, including absences, reflects every device's
    /// edits and deletions); when false we fall back to local storage only.
    private static var iCloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    /// Fires when iCloud delivers a change made on another device. Observe this to
    /// re-merge notes into the in-memory model via `loadAuthoritative()`.
    static let didChangeExternally = NSUbiquitousKeyValueStore.didChangeExternallyNotification

    static func startSyncing() {
        migrateLegacyBlobIfNeeded()
        cloud.synchronize()
    }

    /// Cold-start load. Uses iCloud as authoritative when it holds anything, so a
    /// deletion synced from another device stays deleted; falls back to local when
    /// iCloud is unavailable or has not synced any keys yet, so notes are never
    /// hidden before the first sync completes.
    static func load() -> [String: UserDayData] {
        let localEntries = decodeEntries(local.dictionaryRepresentation())
        guard iCloudAvailable else { return localEntries }
        let cloudEntries = decodeEntries(cloud.dictionaryRepresentation)
        return cloudEntries.isEmpty ? localEntries : cloudEntries
    }

    /// The authoritative iCloud state, used after `didChangeExternally`. A day
    /// missing from the returned dictionary means its note was deleted on another
    /// device, so callers should clear that day rather than keep a stale value.
    static func loadAuthoritative() -> [String: UserDayData] {
        decodeEntries(cloud.dictionaryRepresentation)
    }

    /// Writes the full desired state. Every key in `allKeys` is either written
    /// (when it has non-empty comments in `data`) or removed (otherwise), so a note
    /// cleared on this device deletes its key locally and in iCloud, and that
    /// removal syncs to the user's other devices.
    static func save(_ data: [String: UserDayData], allKeys: Set<String>) {
        for key in allKeys {
            let storageKey = keyPrefix + key
            if let entry = data[key], !entry.comments.isEmpty,
               let encoded = try? JSONEncoder().encode(entry) {
                local.set(encoded, forKey: storageKey)
                cloud.set(encoded, forKey: storageKey)
            } else {
                local.removeObject(forKey: storageKey)
                cloud.removeObject(forKey: storageKey)
            }
        }
    }

    // MARK: - Helpers

    private static func decodeEntries(_ raw: [String: Any]) -> [String: UserDayData] {
        var result: [String: UserDayData] = [:]
        for (storageKey, value) in raw where storageKey.hasPrefix(keyPrefix) {
            guard let data = value as? Data,
                  let entry = try? JSONDecoder().decode(UserDayData.self, from: data) else { continue }
            result[String(storageKey.dropFirst(keyPrefix.count))] = entry
        }
        return result
    }

    /// One-time migration from the old single-blob key to per-day keys. Runs before
    /// the first load and is a no-op once the blob has been expanded and removed.
    private static func migrateLegacyBlobIfNeeded() {
        let legacyData = cloud.data(forKey: legacyKey) ?? local.data(forKey: legacyKey)
        guard let legacyData,
              let decoded = try? JSONDecoder().decode([String: UserDayData].self, from: legacyData) else { return }

        for (dayKey, entry) in decoded where !entry.comments.isEmpty {
            let storageKey = keyPrefix + dayKey
            let alreadyMigrated = local.data(forKey: storageKey) != nil || cloud.data(forKey: storageKey) != nil
            guard !alreadyMigrated, let encoded = try? JSONEncoder().encode(entry) else { continue }
            local.set(encoded, forKey: storageKey)
            cloud.set(encoded, forKey: storageKey)
        }
        local.removeObject(forKey: legacyKey)
        cloud.removeObject(forKey: legacyKey)
    }
}
