import SwiftUI

struct ContentView: View {
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FilteredFlashcardListView(viewModel: flashcardViewModel)
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack.fill")
                }
                .tag(0)
            
            NotesHomeView(viewModel: noteViewModel)
                .tabItem {
                    Label("Notes", systemImage: "doc.text.fill")
                }
                .tag(1)
            
            QuizHomeView(flashcardViewModel: flashcardViewModel)
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
                .tag(2)
        }
    }
}
