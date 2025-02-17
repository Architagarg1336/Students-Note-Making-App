import SwiftUI

struct AddFlashcardView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    @Binding var isPresented: Bool
    
    @State private var question = ""
    @State private var answer = ""
    @State private var subject = ""
    @State private var difficulty: Flashcard.Difficulty = .medium
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Flashcard Details")) {
                    TextField("Question", text: $question)
                    
                    Section(header: Text("Details")) {
                        TextEditor(text: $answer)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    TextField("Subject", text: $subject)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Flashcard.Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                }
                
                Section {
                    Button("Save Flashcard") {
                        let newFlashcard = Flashcard(
                            question: question,
                            answer: answer,
                            subject: subject,
                            difficulty: difficulty
                        )
                        viewModel.addFlashcard(newFlashcard)
                        isPresented = false
                    }
                    .disabled(question.isEmpty || answer.isEmpty || subject.isEmpty)
                }
            }
            .navigationTitle("Add Flashcard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
