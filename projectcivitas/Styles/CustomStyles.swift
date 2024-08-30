//
//  CustomStyles.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/30/24.
//

import SwiftUI

struct CustomNavigationLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary) // Use primary color instead of blue
    }
}
