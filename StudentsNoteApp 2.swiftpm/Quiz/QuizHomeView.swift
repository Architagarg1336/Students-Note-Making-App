import SwiftUI

struct QuizHomeView: View {
    @ObservedObject var flashcardViewModel: FlashcardViewModel
    @State private var showingQuiz = false
    @State private var selectedQuizType: QuizType?
    @State private var selectedSubject: String?
    @State private var selectedDifficulty: Flashcard.Difficulty?
    
    enum QuizType {
        case all, bySubject, byDifficulty
    }
    
    private var availableSubjects: [String] {
        Array(Set(flashcardViewModel.flashcards.map { $0.subject })).sorted()
    }
    
    private func resetFilters() {
        selectedQuizType = nil
        selectedSubject = nil
        selectedDifficulty = nil
    }
    
    private func getFilteredFlashcards() -> [Flashcard] {
        var cards = flashcardViewModel.flashcards
        
        if selectedQuizType == .all {
            return flashcardViewModel.flashcards.shuffled()
        }
        
        if let subject = selectedSubject {
            cards = cards.filter { $0.subject == subject }
        }
        
        if let difficulty = selectedDifficulty {
            cards = cards.filter { $0.difficulty == difficulty }
        }
        
        return cards.shuffled()
    }
    
    var body: some View {
        NavigationView {
            List {
              
                Section(header: Text("Quick Start")) {
                    Button(action: {
                        resetFilters()
                        selectedQuizType = .all
                        showingQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.green)
                            Text("Start Quiz with All Flashcards")
                            Spacer()
                            Text("\(flashcardViewModel.flashcards.count) cards")
                                .foregroundColor(.gray)
                        }
                    }
                    .disabled(flashcardViewModel.flashcards.isEmpty)
                }
                
          
                if !availableSubjects.isEmpty {
                    Section(header: Text("Quiz by Subject")) {
                        ForEach(availableSubjects, id: \.self) { subject in
                            let cards = flashcardViewModel.flashcards.filter { $0.subject == subject }
                            Button(action: {
                                resetFilters()
                                selectedQuizType = .bySubject
                                selectedSubject = subject
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showingQuiz = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)
                                    Text(subject)
                                    Spacer()
                                    Text("\(cards.count) cards")
                                        .foregroundColor(.gray)
                                }
                            }
                            .disabled(cards.isEmpty)
                        }
                    }
                }
                
             
                Section(header: Text("Quiz by Difficulty")) {
                    ForEach(Flashcard.Difficulty.allCases, id: \.self) { difficulty in
                        let cards = flashcardViewModel.flashcards.filter { $0.difficulty == difficulty }
                        Button(action: {
                            resetFilters()
                            selectedQuizType = .byDifficulty
                            selectedDifficulty = difficulty
                          
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingQuiz = true
                            }
                        }) {
                            HStack {
                                Image(systemName: difficultyIcon(for: difficulty))
                                    .foregroundColor(difficultyColor(for: difficulty))
                                Text(difficulty.rawValue.capitalized)
                                Spacer()
                                Text("\(cards.count) cards")
                                    .foregroundColor(.gray)
                            }
                        }
                        .disabled(cards.isEmpty)
                    }
                }
                
               
                Section(header: Text("Statistics")) {
                    HStack {
                        Text("Total Flashcards")
                        Spacer()
                        Text("\(flashcardViewModel.flashcards.count)")
                            .bold()
                    }
                    
                    HStack {
                        Text("Subjects")
                        Spacer()
                        Text("\(availableSubjects.count)")
                            .bold()
                    }
                }
            }
            .navigationTitle("Quiz")
            .fullScreenCover(isPresented: $showingQuiz, onDismiss: {
                resetFilters()
            }) {
                QuizView(flashcards: getFilteredFlashcards(), viewModel: flashcardViewModel)
            }
        }
    }
    
    private func difficultyIcon(for difficulty: Flashcard.Difficulty) -> String {
        switch difficulty {
        case .easy: return "star"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star.fill"
        }
    }
    
    private func difficultyColor(for difficulty: Flashcard.Difficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
