//
//  Visualizations.swift
//

import SwiftUI


struct VoteDistributionBar: View {
    let yesVotes: Int
    let noVotes: Int
    
    private var totalVotes: Int {
        yesVotes + noVotes
    }
    
    private var yesPercentage: CGFloat {
        totalVotes > 0 ? CGFloat(yesVotes) / CGFloat(totalVotes) : 0
    }
    
    private func formatPercentage(_ value: CGFloat) -> String {
        String(format: "%.1f%%", value * 100)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if totalVotes == 0 {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    Text("No votes yet")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                }
            } else {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.fruitSaladGreen)
                        .frame(width: geometry.size.width * yesPercentage)
                        .overlay(
                            HStack {
                                Spacer()
                                Text(formatPercentage(yesPercentage))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                Spacer()
                            }, alignment: .leading
                        )
                    
                    Rectangle()
                        .fill(Color.oldGloryRed)
                        .frame(width: geometry.size.width * (1 - yesPercentage))
                        .overlay(
                            HStack {
                                Spacer()
                                Text(formatPercentage(1 - yesPercentage))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                Spacer()
                            }, alignment: .trailing
                        )
                }
            }
        }
        .frame(height: 30)
        .cornerRadius(15)
    }
}
