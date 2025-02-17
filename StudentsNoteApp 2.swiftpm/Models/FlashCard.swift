
import Foundation

struct Flashcard: Identifiable, Codable {
    let id: UUID
    var question: String
    var answer: String
    var subject: String
    var difficulty: Difficulty
    var lastReviewed: Date?
    var reviewCount: Int
    var nextReviewDate: Date?
    var easeFactor: Double = 2.5
    var isMarkedForReview: Bool = false
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy
        case medium
        case hard
    }
    
    init(id: UUID = UUID(), question: String, answer: String, subject: String, difficulty: Difficulty = .medium, lastReviewed: Date? = nil, reviewCount: Int = 0, nextReviewDate: Date? = nil) {
        self.id = id
        self.question = question
        self.answer = answer
        self.subject = subject
        self.difficulty = difficulty
        self.lastReviewed = lastReviewed
        self.reviewCount = reviewCount
        self.nextReviewDate = nextReviewDate
    }
}
