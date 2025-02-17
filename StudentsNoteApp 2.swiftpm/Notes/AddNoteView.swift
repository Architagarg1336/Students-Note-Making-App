//
//  AddNoteView.swift
//  StudentsNoteApp
//
//  Created by Archita Garg on 02/02/25.
//


import SwiftUI
import UniformTypeIdentifiers

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    let preSelectedMainTopic: String?
    
    @State private var title = ""
    @State private var content = ""
    @State private var mainTopic = ""
    @State private var subTopic = ""
    @State private var showingFilePicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(viewModel: NoteViewModel, preSelectedMainTopic: String? = nil) {
        self.viewModel = viewModel
        self.preSelectedMainTopic = preSelectedMainTopic
        _mainTopic = State(initialValue: preSelectedMainTopic ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    if preSelectedMainTopic == nil {
                        TextField("Main Topic (e.g., DSA)", text: $mainTopic)
                            .textInputAutocapitalization(.words)
                    }
                    
                    TextField("Sub Topic (e.g., Graphs)", text: $subTopic)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section(header: Text("Import")) {
                    Button(action: {
                        if !title.isEmpty && (!mainTopic.isEmpty || preSelectedMainTopic != nil) && !subTopic.isEmpty {
                            showingFilePicker = true
                        } else {
                            errorMessage = "Please fill in all required fields before importing a file"
                            showError = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("Import File")
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.addNote(
                        title: title,
                        content: content,
                        mainTopic: preSelectedMainTopic ?? mainTopic,
                        subTopic: subTopic
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || (preSelectedMainTopic == nil && mainTopic.isEmpty) || subTopic.isEmpty)
            )
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.text, .pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    try viewModel.addNoteFromFile(
                        fileURL: url,
                        title: title,
                        mainTopic: preSelectedMainTopic ?? mainTopic,
                        subTopic: subTopic
                    )
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    errorMessage = "Error importing file: \(error.localizedDescription)"
                    showError = true
                }
            case .failure(let error):
                errorMessage = "Error selecting file: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}