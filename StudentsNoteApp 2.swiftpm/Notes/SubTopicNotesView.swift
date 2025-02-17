import SwiftUI

struct SubTopicNotesView: View {
    @ObservedObject var viewModel: NoteViewModel
    let mainTopic: String
    let subTopic: String
    
    var body: some View {
        List {
            ForEach(viewModel.getNotes(mainTopic: mainTopic, subTopic: subTopic)) { note in
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
                let notes = viewModel.getNotes(mainTopic: mainTopic, subTopic: subTopic)
                indexSet.forEach { index in
                    viewModel.deleteNote(notes[index])
                }
            }
        }
        .navigationTitle(subTopic)
    }
}
