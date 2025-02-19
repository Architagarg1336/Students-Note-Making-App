import SwiftUI

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int
    @Environment(\.dismiss) var dismiss
    var onTryAgain: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    private var resultMessage: String {
        switch percentage {
        case 90...100:
            return "Excellent! You've mastered these flashcards!"
        case 70..<90:
            return "Great job! Keep up the good work!"
        case 50..<70:
            return "Good effort! Review the cards you missed."
        default:
            return "Keep practicing! You'll improve with more study."
        }
    }
    
    private var resultColor: Color {
        switch percentage {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                resultColor.opacity(0.2),
                resultColor.opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func returnToHome() {
        NotificationCenter.default.post(name: NSNotification.Name("DismissQuiz"), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                  
                    VStack(spacing: 15) {
                        Text("Quiz Complete!")
                            .font(.title)
                            .bold()
                            .padding(.top)
                        
                        ZStack {
                            Circle()
                                .stroke(
                                    resultColor.opacity(0.3),
                                    lineWidth: 15
                                )
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(percentage / 100))
                                .stroke(
                                    resultColor,
                                    style: StrokeStyle(
                                        lineWidth: 15,
                                        lineCap: .round
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.5), value: percentage)
                            
                            VStack(spacing: 5) {
                                Text("\(Int(percentage))%")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(resultColor)
                                
                                Text("\(score) / \(totalQuestions)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                   
                    Text(resultMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(resultColor.opacity(0.15))
                                .shadow(color: resultColor.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(resultColor.opacity(0.3), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                   
                    VStack(spacing: 15) {
                        Button(action: {
                            onTryAgain()
                        }) {
                            Text("Try Again")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.blue)
                                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                                )
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: returnToHome) {
                            Text("Return to Flashcards")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.15))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: returnToHome) {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .contentTransition(.symbolEffect(.replace))
                        } else {
                           
                        }
                    }
                }
            }
        }
    }
}
