//
//  Icons.swift
//  projectcivitas
//

import SwiftUI

struct FollowStar: View {
    let isFollowed: Bool
    
    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(isFollowed ? .oldGloryBlue : .clear)
            .font(.system(size: 12))
    }
}
