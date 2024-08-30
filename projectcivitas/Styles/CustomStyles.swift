//
//  CustomStyles.swift
//

import SwiftUI

struct CustomNavigationLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary) // Use primary color instead of blue
    }
}
