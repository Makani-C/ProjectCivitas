//
//  SettingsManager.swift

import Foundation

struct UserProfile {
    var followedItems: Set<UUID> = []
    
    mutating func toggleFollow(_ item: any Followable) {
        if followedItems.contains(item.id) {
            followedItems.remove(item.id)
        } else {
            followedItems.insert(item.id)
        }
    }
    
    func isFollowing(_ item: any Followable) -> Bool {
        followedItems.contains(item.id)
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
            objectWillChange.send()
        }
    }
    
    init() {
        self.pushNotificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
        self.emailNotificationsEnabled = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        self.preferredTopics = Set(UserDefaults.standard.stringArray(forKey: "preferredTopics") ?? [])
        self.userProfile = Self.loadUserProfile()
    }
    
    private func saveUserProfile() {
        let followedItemsArray = Array(userProfile.followedItems)
        UserDefaults.standard.set(followedItemsArray.map { $0.uuidString }, forKey: "followedItems")
    }
    
    private static func loadUserProfile() -> UserProfile {
        let followedItemStrings = UserDefaults.standard.stringArray(forKey: "followedItems") ?? []
        let followedItems = Set(followedItemStrings.compactMap { UUID(uuidString: $0) })
        var profile = UserProfile()
        profile.followedItems = followedItems
        return profile
    }
    
    func toggleFollow(_ item: any Followable) {
        if userProfile.isFollowing(item) {
            print("SettingsManager: Unfollowing item with ID: \(item.id)")
            userProfile.followedItems.remove(item.id)
        } else {
            print("SettingsManager: Following item with ID: \(item.id)")
            userProfile.followedItems.insert(item.id)
        }
        objectWillChange.send()
        print("SettingsManager: Current followed items: \(userProfile.followedItems)")
    }

    func isFollowing(_ item: any Followable) -> Bool {
        let isFollowing = userProfile.followedItems.contains(item.id)
        print("SettingsManager: Checking if following item with ID: \(item.id), result: \(isFollowing)")
        return isFollowing
    }
}
