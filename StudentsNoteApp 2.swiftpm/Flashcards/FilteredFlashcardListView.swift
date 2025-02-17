import SwiftUI

struct FilteredFlashcardListView: View {
    @ObservedObject var viewModel: FlashcardViewModel 
    @State private var isAddingFlashcard = false
    @State private var searchText = ""
    @State private var selectedDifficulty: Flashcard.Difficulty?
    @State private var selectedSubject: String?
    @State private var showingStudyMode = false
    
    var availableSubjects: [String] {
        Array(Set(viewModel.flashcards.map { $0.subject })).sorted()
    }
    
    var filteredFlashcards: [Flashcard] {
        var filtered = viewModel.flashcards
        
        if !searchText.isEmpty {
            filtered = filtered.filter { flashcard in
                flashcard.question.localizedCaseInsensitiveContains(searchText) ||
                flashcard.answer.localizedCaseInsensitiveContains(searchText) ||
                flashcard.subject.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        if let subject = selectedSubject {
            filtered = filtered.filter { $0.subject == subject }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack(spacing: 8) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Flashcard.Difficulty.allCases, id: \.self) { difficulty in
                                FilterTag(
                                    title: difficulty.rawValue.capitalized,
                                    isSelected: selectedDifficulty == difficulty,
                                    color: difficultyColor(for: difficulty)
                                ) {
                                    if selectedDifficulty == difficulty {
                                        selectedDifficulty = nil
                                    } else {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            }
                            
                            Divider()
                                .frame(height: 20)
                                .padding(.horizontal)
                            
                            ForEach(availableSubjects, id: \.self) { subject in
                                FilterTag(
                                    title: subject,
                                    isSelected: selectedSubject == subject,
                                    color: .blue
                                ) {
                                    if selectedSubject == subject {
                                        selectedSubject = nil
                                    } else {
                                        selectedSubject = subject
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                List {
                    Section(header: Text("Marked for Review")) {
                        let markedFlashcards = filteredFlashcards.filter { $0.isMarkedForReview }
                        
                        if markedFlashcards.isEmpty {
                            Text("No flashcards marked for review.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(markedFlashcards) { flashcard in
                                NavigationLink(destination: FlashcardDetailView(flashcard: flashcard, viewModel: viewModel)) {
                                    FlashcardRowView(flashcard: flashcard)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("All Flashcards")) {
                        if filteredFlashcards.isEmpty {
                            Text("No flashcards match the current filters.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(filteredFlashcards) { flashcard in
                                NavigationLink(destination: FlashcardDetailView(flashcard: flashcard, viewModel: viewModel)) {
                                    FlashcardRowView(flashcard: flashcard)
                                }
                            }
                            .onDelete(perform: deleteFlashcards)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingStudyMode = true }) {
                            Image(systemName: "book.fill")
                        }
                        .disabled(filteredFlashcards.isEmpty)
                        
                        Button(action: { isAddingFlashcard = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: clearFilters) {
                        Text("Clear Filters")
                            .opacity((selectedDifficulty != nil || selectedSubject != nil) ? 1 : 0)
                    }
                }
            }
            .sheet(isPresented: $isAddingFlashcard) {
                AddFlashcardView(viewModel: viewModel, isPresented: $isAddingFlashcard)
            }
            .background(
                NavigationLink(
                    destination: StudyModeView(flashcards: filteredFlashcards, viewModel: viewModel),
                    isActive: $showingStudyMode
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private func clearFilters() {
        selectedDifficulty = nil
        selectedSubject = nil
    }
    
    private func deleteFlashcards(at offsets: IndexSet) {
        let flashcardsToDelete = offsets.map { filteredFlashcards[$0] }
        flashcardsToDelete.forEach { viewModel.removeFlashcard($0) }
    }
    
    private func difficultyColor(for difficulty: Flashcard.Difficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .red
        }
    }
}
