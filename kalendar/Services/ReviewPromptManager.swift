//
//  ReviewPromptManager.swift
//  kalendar
//
//  Decides when to ask StoreKit's environment `requestReview` action to prompt
//  for an App Store review. Apple's system independently rate-limits how often
//  anything actually appears (a few times per year at most), so this only has
//  to pick one honest signal of engagement and ask exactly once.

import Foundation

enum ReviewPromptManager {
    private static let noteCountKey = "com.kalendar.reviewPrompt.noteCount"
    private static let hasPromptedKey = "com.kalendar.reviewPrompt.hasPrompted"

    /// Adding a few notes is a reasonable sign someone is actually using the
    /// app, not just poking around once.
    private static let noteCountThreshold = 3

    /// Call each time the user adds a note. Returns true the one time the
    /// engagement threshold is crossed; the caller should invoke StoreKit's
    /// `requestReview` action when it does. Never signals more than once.
    static func noteWasAdded() -> Bool {
        guard !UserDefaults.standard.bool(forKey: hasPromptedKey) else { return false }

        let count = UserDefaults.standard.integer(forKey: noteCountKey) + 1
        UserDefaults.standard.set(count, forKey: noteCountKey)

        guard count >= noteCountThreshold else { return false }
        UserDefaults.standard.set(true, forKey: hasPromptedKey)
        return true
    }
}
