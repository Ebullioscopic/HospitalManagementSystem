import SwiftUI

struct SymptomQuestionnaire: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var answers: [String: Any] = [:]
    @State private var showResults = false
    @State private var recommendedSpecialties: [String] = []
    
    let questions: [Question] = [
        Question(
            id: "main_area",
            text: "Where is your main concern located?",
            type: .bodyPart,
            options: nil
        ),
        Question(
            id: "symptoms",
            text: "What symptoms are you experiencing?",
            type: .multiSelect,
            options: ["Fever", "Pain", "Swelling", "Rash", "Nausea", "Dizziness"]
        ),
        Question(
            id: "duration",
            text: "How long have you had these symptoms?",
            type: .singleSelect,
            options: ["Less than 24 hours", "1-3 days", "4-7 days", "1-2 weeks", "More than 2 weeks"]
        ),
        Question(
            id: "severity",
            text: "How severe is your discomfort?",
            type: .scale,
            options: Array(1...10).map { "\($0)" }
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if showResults {
                    SpecialtyRecommendationView(
                        specialties: recommendedSpecialties,
                        onRestart: restartQuestionnaire,
                        onClose: { dismiss() }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                } else if currentQuestionIndex < questions.count {
                    QuestionView(
                        question: questions[currentQuestionIndex],
                        answer: Binding(
                            get: { answers[questions[currentQuestionIndex].id] as? String ?? "" },
                            set: { answers[questions[currentQuestionIndex].id] = $0 }
                        ),
                        onNext: goToNextQuestion,
                        onSkip: goToNextQuestion
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
                )}
            }
            .navigationTitle("Symptom Checker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func goToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            evaluateResults()
        }
    }
    
    private func evaluateResults() {
        // This would be replaced with actual matching logic
        let specialties = DoctorSpecialtyMatch.matchSpecialty(
            bodyPart: answers["main_area"] as? String,
            symptoms: answers["symptoms"] as? [String],
            duration: answers["duration"] as? String,
            severity: answers["severity"] as? String
        )
        
        withAnimation {
            recommendedSpecialties = specialties
            showResults = true
        }
    }
    
    private func restartQuestionnaire() {
        withAnimation {
            currentQuestionIndex = 0
            answers = [:]
            showResults = false
        }
    }
}
