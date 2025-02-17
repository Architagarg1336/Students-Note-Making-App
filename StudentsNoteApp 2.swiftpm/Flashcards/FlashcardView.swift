import SwiftUI

struct FlashcardView: View {
    let flashcard: Flashcard
    @Binding var isFlipped: Bool

    var body: some View {
        VStack {
            Text(isFlipped ? flashcard.answer : flashcard.question)
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isFlipped ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                .cornerRadius(10)
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
        }
        .padding()
    }
}
