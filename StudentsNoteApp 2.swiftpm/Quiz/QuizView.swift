import SwiftUI

struct QuizView: View {
    let flashcards: [Flashcard]
    @ObservedObject var viewModel: FlashcardViewModel
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showingAnswer = false
    @State private var showingResult = false
    @State private var selectedAnswer: String?
    @Environment(\.dismiss) var dismiss
    @State private var showingExitAlert = false
    @State private var animateProgress = false
    @State private var optionsOpacity: Double = 1
    @State private var shouldDismiss = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Function to reset the quiz state
    private func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        showingAnswer = false
        selectedAnswer = nil
        showingResult = false
    }
    
    // Generate options code remains unchanged...
    private func generateOptions(for currentCard: Flashcard) -> [String] {
        var options = [currentCard.answer]
        
        // Try to parse the answer as a number
        if let numericAnswer = Double(currentCard.answer.replacingOccurrences(of: ",", with: "")) {
            // Generate similar numeric options
            options.append(contentsOf: generateNumericOptions(for: numericAnswer))
        }
        // Check if the answer is a date
        else if currentCard.answer.contains("/") || currentCard.answer.contains("-") {
            options.append(contentsOf: generateDateOptions(for: currentCard.answer))
        }
        // Handle string answers
        else {
            options.append(contentsOf: generateStringOptions(for: currentCard))
        }
        
        // If we still don't have enough options, add from other flashcards
        if options.count < 4 {
            let remainingOptions = flashcards
                .filter { $0.id != currentCard.id }
                .map { $0.answer }
                .filter { !options.contains($0) }
                .filter { isAnswerSimilarType($0, to: currentCard.answer) }
                .shuffled()
                .prefix(4 - options.count)
            
            options.append(contentsOf: remainingOptions)
        }
        
        return Array(options.prefix(4)).shuffled()
    }
    
    private func generateStringOptions(for currentCard: Flashcard) -> [String] {
        let answer = currentCard.answer.lowercased()
        
        // Get all other string answers from flashcards
        let otherAnswers = flashcards
            .filter { $0.id != currentCard.id }
            .map { $0.answer }
            .filter { Double($0.replacingOccurrences(of: ",", with: "")) == nil } // Ensure it's not a number
            .filter { !$0.contains("/") && !$0.contains("-") } // Ensure it's not a date
        
        // Score each answer based on similarity to create more relevant options
        let scoredAnswers = otherAnswers.map { answer -> (String, Int) in
            var score = 0
            let otherAnswer = answer.lowercased()
            
            // Higher score for similar length
            if abs(answer.count - otherAnswer.count) <= 3 {
                score += 3
            }
            
            // Higher score for answers in the same category/context
            if answer.split(separator: " ").first == otherAnswer.split(separator: " ").first {
                score += 2
            }
            
            // Higher score for answers with similar words
            let answerWords = Set(answer.split(separator: " "))
            let otherWords = Set(otherAnswer.split(separator: " "))
            let commonWords = answerWords.intersection(otherWords)
            score += commonWords.count
            
            return (answer, score)
        }
        
        // Sort by similarity score and take the top 3
        let similarOptions = scoredAnswers
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
        
        return Array(similarOptions)
    }
    
    // Other helper methods remain unchanged...
    private func generateNumericOptions(for answer: Double) -> [String] {
        var options: [String] = []
        let originalString = currentCard.answer
        
        // Determine if the original answer is an integer or decimal
        let isInteger = !originalString.contains(".")
        
        // Determine the magnitude of the number
        let magnitude = pow(10, floor(log10(abs(answer))))
        
        // Generate variations based on the number type
        var variations: [Double] = []
        if isInteger {
            // For integers, generate whole number variations
            variations = [
                round(answer * 0.9),    // 90% rounded
                round(answer * 1.1),    // 110% rounded
                answer + magnitude,      // Add magnitude
                answer - magnitude,      // Subtract magnitude
                round(answer * 2),      // Double
                round(answer / 2)       // Half
            ]
        } else {
            // For decimals, keep decimal variations
            let decimalPlaces = originalString.split(separator: ".").last?.count ?? 2
            let multiplier = pow(10.0, Double(decimalPlaces))
            
            variations = [
                round(answer * 0.9 * multiplier) / multiplier,
                round(answer * 1.1 * multiplier) / multiplier,
                round((answer + magnitude) * multiplier) / multiplier,
                round((answer - magnitude) * multiplier) / multiplier,
                round(answer * 2 * multiplier) / multiplier,
                round(answer / 2 * multiplier) / multiplier
            ]
        }
        
        // Format numbers based on the original format
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if isInteger {
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
        } else {
            let decimalPlaces = originalString.split(separator: ".").last?.count ?? 2
            formatter.maximumFractionDigits = decimalPlaces
            formatter.minimumFractionDigits = decimalPlaces
        }
        
        // Add formatted variations
        options = variations
            .map { abs($0) } // Ensure positive numbers
            .filter { $0 != answer } // Remove the correct answer if it appears in variations
            .compactMap { formatter.string(from: NSNumber(value: $0)) ?? "" }
        
        // Remove duplicates and ensure they're different from the original answer
        options = Array(Set(options)).filter { $0 != originalString }
        
        // Shuffle and take only what we need
        return Array(options.prefix(3))
    }
    
    private func generateDateOptions(for answer: String) -> [String] {
        var options: [String] = []
        
        // Try to parse the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = answer.contains("/") ? "MM/dd/yyyy" : "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: answer) {
            // Generate dates around the correct answer
            let calendar = Calendar.current
            let variations: [Date] = [
                calendar.date(byAdding: .day, value: 1, to: date)!,
                calendar.date(byAdding: .day, value: -1, to: date)!,
                calendar.date(byAdding: .month, value: 1, to: date)!,
                calendar.date(byAdding: .month, value: -1, to: date)!,
                calendar.date(byAdding: .year, value: 1, to: date)!,
                calendar.date(byAdding: .year, value: -1, to: date)!
            ]
            
            // Format dates in the same format as the answer
            options = variations.map { dateFormatter.string(from: $0) }
        }
        
        return Array(Set(options)).shuffled().prefix(3).map { String($0) }
    }
    
    private func isAnswerSimilarType(_ answer: String, to reference: String) -> Bool {
        // Helper function to check if two answers are of similar type
        let isReferenceNumeric = Double(reference.replacingOccurrences(of: ",", with: "")) != nil
        let isAnswerNumeric = Double(answer.replacingOccurrences(of: ",", with: "")) != nil
        
        let isReferenceDate = reference.contains("/") || reference.contains("-")
        let isAnswerDate = answer.contains("/") || answer.contains("-")
        
        return (isReferenceNumeric && isAnswerNumeric) ||
               (isReferenceDate && isAnswerDate) ||
               (!isReferenceNumeric && !isReferenceDate && !isAnswerNumeric && !isAnswerDate)
    }
    
    private var currentCard: Flashcard {
        flashcards[currentQuestionIndex]
    }
    
    private var options: [String] {
        generateOptions(for: currentCard)
    }
    
    private var progressValue: CGFloat {
        CGFloat(currentQuestionIndex) / CGFloat(flashcards.count - 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Progress and Score Bar
                    HStack(spacing: 12) {
                        // Progress bar
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: animateProgress ? max(10, UIScreen.main.bounds.width * 0.85 * progressValue) : 0, height: 6)
                                .animation(.easeInOut(duration: 0.5), value: animateProgress)
                        }
                        
                        // Score Chip
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            
                            Text("\(score)")
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Question Counter
                    Text("Question \(currentQuestionIndex + 1) of \(flashcards.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Question Card - No 3D rotation effect
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // Question Header
                            HStack {
                                Text("Question:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if showingAnswer {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            // Question Text
                            Text(currentCard.question)
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.medium)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                    
                    // Answer Options
                    VStack(spacing: 12) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedAnswer = option
                                    checkAnswer(option)
                                }
                            }) {
                                Text(option)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(backgroundGradient(for: option))
                                            .shadow(color: shadowColor(for: option), radius: 3, x: 0, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(borderColor(for: option), lineWidth: 1)
                                    )
                                    .foregroundColor(textColor(for: option))
                            }
                            .disabled(showingAnswer)
                            .animation(.easeInOut(duration: 0.3), value: showingAnswer)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Next Button
                    if showingAnswer {
                        Button(action: nextQuestion) {
                            HStack {
                                Text(currentQuestionIndex == flashcards.count - 1 ? "See Results" : "Next Question")
                                    .font(.headline)
                                
                                if currentQuestionIndex < flashcards.count - 1 {
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .navigationTitle("Quiz")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingExitAlert = true }) {
                            HStack(spacing: 3) {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                                    .font(.headline)
                                
                                Text("Exit")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert(isPresented: $showingExitAlert) {
            Alert(
                title: Text("Exit Quiz?"),
                message: Text("Your progress will be lost. Are you sure you want to exit?"),
                primaryButton: .destructive(Text("Exit")) {
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .fullScreenCover(isPresented: $showingResult) {
            QuizResultView(score: score, totalQuestions: flashcards.count, onTryAgain: {
                resetQuiz() // Reset the quiz state when "Try Again" is pressed
                showingResult = false // Dismiss the result view
            })
        }
        .onChange(of: shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissQuiz"))) { _ in
            shouldDismiss = true
        }
        .onAppear {
            // Initialize animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateProgress = true
            }
        }
    }
    
    // Enhanced styling methods for better visual feedback
    
    private func backgroundGradient(for option: String) -> LinearGradient {
        if !showingAnswer {
            return selectedAnswer == option ?
                LinearGradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [colorScheme == .dark ? Color(.systemGray5) : .white], startPoint: .leading, endPoint: .trailing)
        }
        
        if option == currentCard.answer {
            return LinearGradient(colors: [.green.opacity(0.7), .green.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
        }
        
        return selectedAnswer == option ?
            LinearGradient(colors: [.red.opacity(0.7), .red.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
            LinearGradient(colors: [colorScheme == .dark ? Color(.systemGray5) : .white], startPoint: .leading, endPoint: .trailing)
    }
    
    private func borderColor(for option: String) -> Color {
        if !showingAnswer {
            return selectedAnswer == option ? .blue : .gray.opacity(0.3)
        }
        
        if option == currentCard.answer {
            return .green
        }
        
        return selectedAnswer == option ? .red : .gray.opacity(0.3)
    }
    
    private func textColor(for option: String) -> Color {
        if !showingAnswer {
            return selectedAnswer == option ? .white : .primary
        }
        
        if option == currentCard.answer || (selectedAnswer == option && option != currentCard.answer) {
            return .white
        }
        
        return .primary
    }
    
    private func shadowColor(for option: String) -> Color {
        if !showingAnswer {
            return selectedAnswer == option ? .blue.opacity(0.3) : .black.opacity(0.05)
        }
        
        if option == currentCard.answer {
            return .green.opacity(0.3)
        }
        
        return selectedAnswer == option ? .red.opacity(0.3) : .black.opacity(0.05)
    }
    
    private func checkAnswer(_ answer: String) {
        showingAnswer = true
        if answer == currentCard.answer {
            score += 1
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex == flashcards.count - 1 {
            showingResult = true
        } else {
            withAnimation {
                currentQuestionIndex += 1
                showingAnswer = false
                selectedAnswer = nil
            }
        }
    }
}
