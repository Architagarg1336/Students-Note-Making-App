import SwiftUI

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var totalFlashcardsReviewed: Int = 0
    @Published var totalFlashcardsMastered: Int = 0
   

    init() {
        loadFlashcards()
        loadProgress()
       
    }
    
    func addFlashcard(_ flashcard: Flashcard) {
        flashcards.append(flashcard)
        saveFlashcards()
    }
    
    func removeFlashcard(_ flashcard: Flashcard) {
        flashcards.removeAll { $0.id == flashcard.id }
        saveFlashcards()
    }
    
    func updateFlashcard(_ updatedFlashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == updatedFlashcard.id }) {
            flashcards[index] = updatedFlashcard
            saveFlashcards()
        }
    }
    
    func getFlashcardsByDifficulty(_ difficulty: Flashcard.Difficulty) -> [Flashcard] {
        return flashcards.filter { $0.difficulty == difficulty }
    }
    
    func getFlashcardsForReview() -> [Flashcard] {
        let currentDate = Date()
        return flashcards.filter { flashcard in
            if let nextReviewDate = flashcard.nextReviewDate {
                return nextReviewDate <= currentDate
            }
            return false
        }
    }
    
    func getFlashcardsMarkedForReview() -> [Flashcard] {
        return flashcards.filter { $0.isMarkedForReview }
    }
    
    
    func markFlashcardForReview(_ flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isMarkedForReview = true
            saveFlashcards()
        }
    }
    
    func unmarkFlashcardForReview(_ flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isMarkedForReview = false
            saveFlashcards()
        }
    }
    
    
    func scheduleNextReview(for flashcard: Flashcard, performance: Int) {
        var updatedFlashcard = flashcard
        let easeFactor = updatedFlashcard.easeFactor
        let interval: Int
        
        if performance >= 3 {
            if updatedFlashcard.reviewCount == 0 {
                interval = 1
            } else if updatedFlashcard.reviewCount == 1 {
                interval = 6
            } else {
                interval = Int(Double(updatedFlashcard.reviewCount) * easeFactor)
            }
            updatedFlashcard.easeFactor = max(1.3, easeFactor + 0.1 - (5 - Double(performance)) * 0.08)
        } else {
            interval = 1
            updatedFlashcard.easeFactor = max(1.3, easeFactor - 0.2)
        }
        
        updatedFlashcard.nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())
        updatedFlashcard.reviewCount += 1
        updatedFlashcard.lastReviewed = Date()
        
        updateFlashcard(updatedFlashcard)
    }
    
    func markFlashcardAsReviewed(_ flashcard: Flashcard, performance: Int) {
        scheduleNextReview(for: flashcard, performance: performance)
        totalFlashcardsReviewed += 1
        if flashcard.reviewCount >= 5 {
            totalFlashcardsMastered += 1
        }
        saveProgress()
    }
    
    
    private func saveProgress() {
        let progressData = [
            "totalFlashcardsReviewed": totalFlashcardsReviewed,
            "totalFlashcardsMastered": totalFlashcardsMastered
        ]
        UserDefaults.standard.set(progressData, forKey: "studyProgress")
    }
    
    func loadProgress() {
        if let progressData = UserDefaults.standard.dictionary(forKey: "studyProgress") as? [String: Int] {
            totalFlashcardsReviewed = progressData["totalFlashcardsReviewed"] ?? 0
            totalFlashcardsMastered = progressData["totalFlashcardsMastered"] ?? 0
        }
    }
    
    
    private func saveFlashcards() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(flashcards) {
            UserDefaults.standard.set(encoded, forKey: "flashcards")
        }
    }
    
    func loadFlashcards() {
        if let savedFlashcards = UserDefaults.standard.object(forKey: "flashcards") as? Data {
            let decoder = JSONDecoder()
            if let loadedFlashcards = try? decoder.decode([Flashcard].self, from: savedFlashcards) {
                flashcards = loadedFlashcards
            }
        }
    }
}
