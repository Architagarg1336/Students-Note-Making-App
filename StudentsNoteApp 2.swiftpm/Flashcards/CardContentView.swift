//
//  CardContentView.swift
//  StudentsNoteApp
//
//  Created by Archita Garg on 17/02/25.
//


import SwiftUI

struct CardContentView: View {
    let title: String
    let content: String
    let subject: String
    let difficulty: Flashcard.Difficulty
    let showFlipHint: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                Spacer()
                
                if showFlipHint {
                    Text("Tap to flip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(Color(.tertiarySystemBackground))
                        )
                }
            }
            
            // Main content
            ScrollView {
                Text(content)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
            
            Spacer()
            
            // Bottom metadata
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.7))
                    Text(subject)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: difficultyIcon)
                        .font(.caption)
                        .foregroundColor(difficultyColor)
                    Text(difficulty.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
    }
    
    private var difficultyIcon: String {
        switch difficulty {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
