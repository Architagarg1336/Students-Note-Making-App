




import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteViewModel
    let note: Note
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(note.title)
                    .font(.title)
                    .padding(.bottom, 4)
                
                Text("Topic: \(note.mainTopic)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                if note.fileType == .pdf, let fileURL = note.fileURL {
                    Text("PDF Document")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text(note.content)
                        .padding(4)
                }
            }
            .padding()
        }
        .navigationBarItems(trailing: HStack {
            Button(action: { isEditing = true }) {
                Text("Edit")
            }
            Button(action: {
                viewModel.deleteNote(note)
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        })
        .sheet(isPresented: $isEditing) {
            EditNoteView(viewModel: viewModel, note: note)
        }
    }
}
