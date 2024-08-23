//
// Chips.swift

import Foundation
import SwiftUI

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(title).font(.footnote)
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.caption)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(.white.opacity(0.8))
        .foregroundColor(.blue)
        .cornerRadius(16)
    }
}

struct TagChip: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.footnote)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}
