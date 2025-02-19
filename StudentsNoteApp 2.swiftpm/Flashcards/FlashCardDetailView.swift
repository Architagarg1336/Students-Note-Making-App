import SwiftUI


struct FlashcardDetailView: View {
    let flashcard: Flashcard
    @ObservedObject var viewModel: FlashcardViewModel
    @State private var isFlipped = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
               
                cardView
                    .frame(height: 300)
                    .padding(.horizontal)
                
                
                statisticsSection
                
              
                actionsSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Flashcard")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var cardView: some View {
        ZStack {
           
            if !isFlipped {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack {
                    Text(flashcard.question)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    Text("Question")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            
           
            if isFlipped {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack {
                    Text(flashcard.answer)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    Text("Answer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Difficulty",
                    value: flashcard.difficulty.rawValue.capitalized,
                    icon: difficultyIcon,
                    color: difficultyColor
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                if flashcard.isMarkedForReview {
                    viewModel.unmarkFlashcardForReview(flashcard)
                } else {
                    viewModel.markFlashcardForReview(flashcard)
                }
            }) {
                Label(
                    flashcard.isMarkedForReview ? "Remove from Review List" : "Mark for Review",
                    systemImage: flashcard.isMarkedForReview ? "bookmark.fill" : "bookmark"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(flashcard.isMarkedForReview ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal)
        }
    }
    
    private var difficultyIcon: String {
        switch flashcard.difficulty {
        case .easy: return "tortoise.fill"
        case .medium: return "hare.fill"
        case .hard: return "flame.fill"
        }
    }
    
    private var difficultyColor: Color {
        switch flashcard.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
