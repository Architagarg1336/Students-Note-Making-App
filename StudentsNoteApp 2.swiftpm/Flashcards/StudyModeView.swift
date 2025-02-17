import SwiftUI

struct StudyModeView: View {
    // MARK: - Properties
    let flashcards: [Flashcard]
    @ObservedObject var viewModel: FlashcardViewModel
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset = CGSize.zero
    @State private var cardOpacity = 1.0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Progress bar and counter
                progressHeader
                
                Spacer()
                
                // Flashcard
                cardStack
                
                Spacer()
                
                // Control buttons
                controlButtons
            }
        }
        .navigationTitle("Study Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
    
    // MARK: - View Components
    private var progressHeader: some View {
        HStack(spacing: 15) {
            ProgressView(value: Double(currentIndex + 1), total: Double(flashcards.count))
                .tint(Color.accentColor)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 6)
            
            Text("\(currentIndex + 1)/\(flashcards.count)")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(.secondarySystemBackground))
                )
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var cardStack: some View {
        ZStack {
            // Front of card (Question)
            ZStack {
                cardBackground
                
                CardContentView(
                    title: "Question",
                    content: flashcards[currentIndex].question,
                    subject: flashcards[currentIndex].subject,
                    difficulty: flashcards[currentIndex].difficulty,
                    showFlipHint: false
                )
            }
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            // Back of card (Answer)
            ZStack {
                cardBackground
                
                CardContentView(
                    title: "Answer",
                    content: flashcards[currentIndex].answer,
                    subject: flashcards[currentIndex].subject,
                    difficulty: flashcards[currentIndex].difficulty,
                    showFlipHint: true
                )
            }
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .padding(.horizontal)
        .opacity(cardOpacity)
        .offset(offset)
        .gesture(
            TapGesture().onEnded { _ in flipCard() }
        )
        .gesture(
            DragGesture()
                .onChanged(handleDragChange)
                .onEnded(handleDragEnd)
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
    
    private var controlButtons: some View {
        HStack(spacing: 25) {
            previousButton
            bookmarkButton
            flipButton
            nextButton
        }
        .padding(.bottom, 30)
        .padding(.horizontal)
    }
    
    // MARK: - Control Buttons
    private var previousButton: some View {
        Button(action: { previousCard() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
                .foregroundColor(currentIndex == 0 ? Color.secondary.opacity(0.3) : Color.accentColor)
        }
        .disabled(currentIndex == 0)
    }
    
    private var bookmarkButton: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                viewModel.markFlashcardForReview(flashcards[currentIndex])
            }
        }) {
            Image(systemName: flashcards[currentIndex].isMarkedForReview ? "bookmark.fill" : "bookmark")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
                .foregroundColor(flashcards[currentIndex].isMarkedForReview ? .yellow : .secondary)
        }
    }
    
    private var flipButton: some View {
        Button(action: { flipCard() }) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Flip")
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Capsule().fill(Color.accentColor))
            .foregroundColor(.white)
        }
    }
    
    private var nextButton: some View {
        Button(action: { nextCard() }) {
            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
                .foregroundColor(currentIndex == flashcards.count - 1 ? Color.secondary.opacity(0.3) : Color.accentColor)
        }
        .disabled(currentIndex == flashcards.count - 1)
    }
    
    // MARK: - Helper Methods
    private func flipCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isFlipped.toggle()
        }
    }
    
    private func handleDragChange(_ gesture: DragGesture.Value) {
        if abs(gesture.translation.width) > abs(gesture.translation.height) {
            offset = gesture.translation
            let dragPercentage = min(abs(gesture.translation.width) / 100, 1.0)
            cardOpacity = 1.0 - (dragPercentage * 0.2)
        }
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value) {
        if gesture.translation.width > 100 && currentIndex > 0 {
            previousCard(fromSwipe: true)
        } else if gesture.translation.width < -100 && currentIndex < flashcards.count - 1 {
            nextCard(fromSwipe: true)
        } else {
            withAnimation(.spring()) {
                offset = .zero
                cardOpacity = 1.0
            }
        }
    }
    
    private func nextCard(fromSwipe: Bool = false) {
        if currentIndex < flashcards.count - 1 {
            withAnimation {
                isFlipped = false
                currentIndex += 1
                if !fromSwipe {
                    offset = .zero
                    cardOpacity = 1.0
                }
            }
        }
    }
    
    private func previousCard(fromSwipe: Bool = false) {
        if currentIndex > 0 {
            withAnimation {
                isFlipped = false
                currentIndex -= 1
                if !fromSwipe {
                    offset = .zero
                    cardOpacity = 1.0
                }
            }
        }
    }
}
