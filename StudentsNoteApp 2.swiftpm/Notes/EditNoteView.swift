import SwiftUI

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    let note: Note
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var content: String
    @State private var mainTopic: String
    @State private var subTopic: String
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(viewModel: NoteViewModel, note: Note) {
        self.viewModel = viewModel
        self.note = note
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _mainTopic = State(initialValue: note.mainTopic)
        _subTopic = State(initialValue: note.subTopic)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Main Topic", text: $mainTopic)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Sub Topic", text: $subTopic)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                if note.fileURL != nil {
                    Section(header: Text("Attached File")) {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("File: \(note.fileURL?.lastPathComponent ?? "")")
                            Spacer()
                            Text(note.fileType.rawValue.uppercased())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.updateNote(
                        note,
                        newTitle: title,
                        newContent: content,
                        newMainTopic: mainTopic,
                        newSubTopic: subTopic
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || mainTopic.isEmpty || subTopic.isEmpty)
            )
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    EditNoteView(
        viewModel: NoteViewModel(),
        note: Note(
            title: "Sample Note",
            content: "Sample content",
            mainTopic: "DSA",
            subTopic: "Graphs"
        )
    )
}
