//
//  Note.swift
//  StudentsNoteApp
//
//  Created by Archita Garg on 02/02/25.
//


import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var mainTopic: String
    var subTopic: String
    var fileURL: URL?
    var fileType: NoteFileType
    
    enum NoteFileType: String, Codable {
        case text
        case pdf
        case plainNote
    }
    
    init(id: UUID = UUID(), title: String, content: String, date: Date = Date(), mainTopic: String, subTopic: String, fileURL: URL? = nil, fileType: NoteFileType = .plainNote) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.mainTopic = mainTopic
        self.subTopic = subTopic
        self.fileURL = fileURL
        self.fileType = fileType
    }
}

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var mainTopics: Set<String> = []
    
    init() {
        loadNotes()
    }
    
  
    
    func addNote(title: String, content: String, mainTopic: String, subTopic: String) {
        let note = Note(title: title, content: content, mainTopic: mainTopic, subTopic: subTopic)
        notes.append(note)
        mainTopics.insert(mainTopic)
        saveNotes()
    }
    
    func addNoteFromFile(fileURL: URL, title: String, mainTopic: String, subTopic: String) throws {
        let fileType: Note.NoteFileType
        var content = ""
        
       
        switch fileURL.pathExtension.lowercased() {
        case "txt":
            fileType = .text
            content = try String(contentsOf: fileURL, encoding: .utf8)
            
        case "pdf":
            fileType = .pdf
          
            content = "PDF Document"
            
        default:
            throw NSError(domain: "NoteError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file type"])
        }
        
     
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedFileURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)
        
        try FileManager.default.copyItem(at: fileURL, to: savedFileURL)
        
        let note = Note(title: title, content: content, mainTopic: mainTopic, subTopic: subTopic, fileURL: savedFileURL, fileType: fileType)
        notes.append(note)
        mainTopics.insert(mainTopic)
        saveNotes()
    }
    
    func updateNote(_ note: Note, newTitle: String, newContent: String, newMainTopic: String, newSubTopic: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.title = newTitle
            updatedNote.content = newContent
            updatedNote.mainTopic = newMainTopic
            updatedNote.subTopic = newSubTopic
            notes[index] = updatedNote
            mainTopics.insert(newMainTopic)
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        if let fileURL = note.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        notes.removeAll { $0.id == note.id }
        updateMainTopics()
        saveNotes()
    }
    
 
    
    private func updateMainTopics() {
        mainTopics = Set(notes.map { $0.mainTopic })
    }
    
    func getSubTopics(for mainTopic: String) -> [String] {
        let subtopics = notes
            .filter { $0.mainTopic == mainTopic }
            .map { $0.subTopic }
        return Array(Set(subtopics)).sorted()
    }
    
    func getNotes(mainTopic: String, subTopic: String) -> [Note] {
        return notes.filter { $0.mainTopic == mainTopic && $0.subTopic == subTopic }
    }
    
    func getNotes(mainTopic: String) -> [Note] {
        return notes.filter { $0.mainTopic == mainTopic }
    }
    
    
    
    private func saveNotes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
    
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.object(forKey: "notes") as? Data {
            let decoder = JSONDecoder()
            if let loadedNotes = try? decoder.decode([Note].self, from: savedNotes) {
                notes = loadedNotes
                updateMainTopics()
            }
        }
    }
    

    
    func searchNotes(query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.content.localizedCaseInsensitiveContains(query) ||
            $0.mainTopic.localizedCaseInsensitiveContains(query) ||
            $0.subTopic.localizedCaseInsensitiveContains(query)
        }
    }
    
    func searchMainTopics(query: String) -> Set<String> {
        guard !query.isEmpty else { return mainTopics }
        return Set(mainTopics.filter { $0.localizedCaseInsensitiveContains(query) })
    }
    
    func searchSubTopics(in mainTopic: String, query: String) -> [String] {
        let allSubTopics = getSubTopics(for: mainTopic)
        guard !query.isEmpty else { return allSubTopics }
        return allSubTopics.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}
