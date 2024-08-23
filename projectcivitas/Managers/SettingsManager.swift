//
//  SettingsManager.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation

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
    
    init() {
        self.pushNotificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
        self.emailNotificationsEnabled = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        self.preferredTopics = Set(UserDefaults.standard.stringArray(forKey: "preferredTopics") ?? [])
    }
}
