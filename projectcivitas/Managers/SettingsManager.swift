//
//  SettingsManager.swift
//

import Foundation

class SettingsManager: ObservableObject {
    @Published var userId: UUID
    @Published var emailNotificationsEnabled: Bool = true
    @Published var followedItems: Set<UUID>
    @Published var pushNotificationsEnabled: Bool = true
    @Published var preferredTopics: Set<String> = []

    init(userId: UUID) {
        self.userId = userId
        self.followedItems = []
    }

    func toggleFollow<T: Followable>(_ item: T) {
        if followedItems.contains(item.id) {
            followedItems.remove(item.id)
        } else {
            followedItems.insert(item.id)
        }
    }

    func isFollowing<T: Followable>(_ item: T) -> Bool {
        followedItems.contains(item.id)
    }
}
