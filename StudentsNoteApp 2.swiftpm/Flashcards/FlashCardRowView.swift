import SwiftUI

struct FlashcardRowView: View {
    let flashcard: Flashcard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(flashcard.question)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text("Subject: \(flashcard.subject)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Circle()
                    .fill(difficultyColor(for: flashcard.difficulty))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func difficultyColor(for difficulty: Flashcard.Difficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .red
        }
    }
}
