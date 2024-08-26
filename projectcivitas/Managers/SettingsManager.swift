//
//  SettingsManager.swift
//

import Foundation

struct UserProfile {
    var location: String
    var followedLegislators: Set<UUID>
    
    mutating func toggleFollowLegislator(_ legislatorId: UUID) {
        if followedLegislators.contains(legislatorId) {
            followedLegislators.remove(legislatorId)
        } else {
            followedLegislators.insert(legislatorId)
        }
    }
    
    func isFollowing(_ legislatorId: UUID) -> Bool {
        followedLegislators.contains(legislatorId)
    }
}

class SettingsManager: ObservableObject {
    @Published var pushNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(pushNotificationsEnabled, forKey: "pushNotificationsEnabled")
        }
    }
    
    @Published var emailNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(emailNotificationsEnabled, forKey: "emailNotificationsEnabled")
        }
    }
    
    @Published var preferredTopics: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(preferredTopics), forKey: "preferredTopics")
        }
    }
    
    @Published var userProfile: UserProfile {
        didSet {
            saveUserProfile()
        }
    }
    
    init() {
        self.pushNotificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
        self.emailNotificationsEnabled = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        self.preferredTopics = Set(UserDefaults.standard.stringArray(forKey: "preferredTopics") ?? [])
        self.userProfile = Self.loadUserProfile()
    }
    
    private func saveUserProfile() {
        UserDefaults.standard.set(userProfile.location, forKey: "userLocation")
        UserDefaults.standard.set(userProfile.followedLegislators.map { $0.uuidString }, forKey: "followedLegislators")
    }
    
    private static func loadUserProfile() -> UserProfile {
        let location = UserDefaults.standard.string(forKey: "userLocation") ?? ""
        let followedLegislatorStrings = UserDefaults.standard.stringArray(forKey: "followedLegislators") ?? []
        let followedLegislators = Set(followedLegislatorStrings.compactMap { UUID(uuidString: $0) })
        return UserProfile(location: location, followedLegislators: followedLegislators)
    }
    
    func updateLocation(_ newLocation: String) {
        userProfile.location = newLocation
    }
    
    func toggleFollowLegislator(_ legislatorId: UUID) {
        userProfile.toggleFollowLegislator(legislatorId)
    }
    
    func isFollowingLegislator(_ legislatorId: UUID) -> Bool {
        userProfile.isFollowing(legislatorId)
    }
}
