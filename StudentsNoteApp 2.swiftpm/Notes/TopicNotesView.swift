import SwiftUI

struct TopicNotesView: View {
    @ObservedObject var viewModel: NoteViewModel
    let topic: String
    
    var body: some View {
        List {
            ForEach(viewModel.getNotes(mainTopic: topic)) { note in
                NavigationLink(destination: NoteDetailView(viewModel: viewModel, note: note)) {
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete { indexSet in
                let notes = viewModel.getNotes(mainTopic: topic)
                indexSet.forEach { index in
                    viewModel.deleteNote(notes[index])
                }
            }
        }
        .navigationTitle(topic)
    }
}
