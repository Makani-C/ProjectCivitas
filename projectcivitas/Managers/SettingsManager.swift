//
//  SettingsManager.swift
//

import Foundation

struct UserProfile {
    var id: UUID
    var followedItems: Set<UUID>
}

class SettingsManager: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var pushNotificationsEnabled: Bool = true
    @Published var emailNotificationsEnabled: Bool = true
    @Published var preferredTopics: Set<String> = []

    init() {
        self.userProfile = UserProfile(id: UUID(), followedItems: [])
    }

    func toggleFollow<T: Followable>(_ item: T) {
        if userProfile.followedItems.contains(item.id) {
            userProfile.followedItems.remove(item.id)
        } else {
            userProfile.followedItems.insert(item.id)
        }
    }

    func isFollowing<T: Followable>(_ item: T) -> Bool {
        userProfile.followedItems.contains(item.id)
    }
}

extension SettingsManager {
    static let shared = SettingsManager()
}
