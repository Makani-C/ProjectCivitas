//
//  Buttons.swift

import Foundation
import SwiftUI


struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
        }
    }
}


struct VoteButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    let isSelected: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? color : color.opacity(0.2))
                .foregroundColor(isSelected ? .white : color)
                .cornerRadius(8)
        }
    }
}

struct FollowButton: View {
    @ObservedObject var settingsManager: SettingsManager
    let item: any Followable
    
    var body: some View {
        Text(settingsManager.isFollowing(item) ? "Followed" : "Follow")
            .font(.footnote)
            .bold()
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(settingsManager.isFollowing(item) ? .white : .clear)
            .foregroundColor(settingsManager.isFollowing(item) ? Color.oldGloryRed : .white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 1)
            )
            .onTapGesture {
                settingsManager.toggleFollow(item)
            }
    }
}
