import SwiftUI

struct NotesHomeView: View {
    @ObservedObject var viewModel: NoteViewModel
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedMainTopic: String?
    @State private var showDeleteAlert = false
    @State private var topicToDelete: String?
    @State private var showSubtopicDeleteAlert = false
    @State private var subtopicToDelete: (mainTopic: String, subTopic: String)?
    
    private func topicCountView(for mainTopic: String) -> some View {
        Text("\(viewModel.getNotes(mainTopic: mainTopic).count)")
            .foregroundColor(.gray)
    }
    
    private var filteredMainTopics: [String] {
        let allMainTopics = Array(viewModel.mainTopics).sorted()
        
        guard !searchText.isEmpty else {
            return allMainTopics
        }
        
        return allMainTopics.filter { mainTopic in
            if mainTopic.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            
            let subtopics = viewModel.getSubTopics(for: mainTopic)
            let subtopicMatch = subtopics.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            let noteMatch = viewModel.getNotes(mainTopic: mainTopic)
                .contains { note in
                    note.title.localizedCaseInsensitiveContains(searchText) ||
                    note.content.localizedCaseInsensitiveContains(searchText)
                }
            
            return subtopicMatch || noteMatch
        }
    }
    
    private func deleteMainTopic(_ mainTopic: String) {
        let notesToDelete = viewModel.getNotes(mainTopic: mainTopic)
        notesToDelete.forEach { viewModel.deleteNote($0) }
    }
    
    private func deleteSubtopic(mainTopic: String, subTopic: String) {
        let notesToDelete = viewModel.getNotes(mainTopic: mainTopic, subTopic: subTopic)
        notesToDelete.forEach { viewModel.deleteNote($0) }
    }
    
    private func subtopicRow(mainTopic: String, subTopic: String) -> some View {
        NavigationLink(destination: SubTopicNotesView(viewModel: viewModel, mainTopic: mainTopic, subTopic: subTopic)) {
            HStack {
                Image(systemName: "doc.text")
                Text(subTopic)
                Spacer()
                Text("\(viewModel.getNotes(mainTopic: mainTopic, subTopic: subTopic).count)")
                    .foregroundColor(.gray)
            }
        }
        .padding(.leading)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                subtopicToDelete = (mainTopic: mainTopic, subTopic: subTopic)
                showSubtopicDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func addNoteButton(for mainTopic: String) -> some View {
        Button(action: {
            selectedMainTopic = mainTopic
            showingAddNote = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Note")
            }
        }
        .padding(.leading)
    }
    
    private func topicLabel(for mainTopic: String) -> some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundColor(.blue)
            Text(mainTopic)
            Spacer()
            topicCountView(for: mainTopic)
        }
    }
    
    private func topicContent(for mainTopic: String) -> some View {
        Group {
            ForEach(viewModel.getSubTopics(for: mainTopic), id: \.self) { subTopic in
                subtopicRow(mainTopic: mainTopic, subTopic: subTopic)
            }
            addNoteButton(for: mainTopic)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredMainTopics, id: \.self) { mainTopic in
                    DisclosureGroup(
                        content: { topicContent(for: mainTopic) },
                        label: { topicLabel(for: mainTopic) }
                    )
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let mainTopic = filteredMainTopics[index]
                        topicToDelete = mainTopic
                        showDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedMainTopic = nil
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel, preSelectedMainTopic: selectedMainTopic)
            }
            .alert("Delete Topic", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    topicToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let topic = topicToDelete {
                        deleteMainTopic(topic)
                        topicToDelete = nil
                    }
                }
            } message: {
                if let topic = topicToDelete {
                    Text("Are you sure you want to delete '\(topic)' and all its notes? This action cannot be undone.")
                }
            }
            .alert("Delete Subtopic", isPresented: $showSubtopicDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    subtopicToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let toDelete = subtopicToDelete {
                        deleteSubtopic(mainTopic: toDelete.mainTopic, subTopic: toDelete.subTopic)
                        subtopicToDelete = nil
                    }
                }
            } message: {
                if let toDelete = subtopicToDelete {
                    Text("Are you sure you want to delete '\(toDelete.subTopic)' and all its notes? This action cannot be undone.")
                }
            }
        }
    }
}
