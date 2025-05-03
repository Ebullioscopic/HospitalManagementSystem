import SwiftUI

enum QuestionType {
    case singleSelect
    case multiSelect
    case bodyPart
    case scale
    case text
}

struct Question {
    let id: String
    let text: String
    let type: QuestionType
    let options: [String]?
}

struct QuestionView: View {
    let question: Question
    @Binding var answer: String
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question Text
            Text(question.text)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 30)
            
            // Answer Area
            Group {
                switch question.type {
                case .singleSelect:
                    SingleSelectView(options: question.options ?? [], selection: $answer)
                case .multiSelect:
                    MultiSelectView(options: question.options ?? [], selections: Binding(
                        get: { answer.components(separatedBy: ",").filter { !$0.isEmpty } },
                        set: { answer = $0.joined(separator: ",") }
                    ))
                case .bodyPart:
                    BodyPartSelector(selectedPart: $answer)
                case .scale:
                    ScaleSelectionView(selection: $answer, options: question.options ?? [])
                case .text:
                    TextField("Enter your answer", text: $answer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack {
                Button("Skip") {
                    onSkip()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                Button("Next") {
                    onNext()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(question.type != .bodyPart && answer.isEmpty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct SingleSelectView: View {
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(selection == option ? .white : .primary)
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(selection == option ? Color.blue : Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct MultiSelectView: View {
    let options: [String]
    @Binding var selections: [String]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selections.contains(option) {
                        selections.removeAll { $0 == option }
                    } else {
                        selections.append(option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(selections.contains(option) ? .white : .primary)
                        Spacer()
                        if selections.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(selections.contains(option) ? Color.blue : Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct ScaleSelectionView: View {
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(options, id: \.self) { value in
                    Button(action: {
                        selection = value
                    }) {
                        Text(value)
                            .frame(width: 30, height: 30)
                            .background(selection == value ? Color.blue : Color(.secondarySystemBackground))
                            .foregroundColor(selection == value ? .white : .primary)
                            .clipShape(Circle())
                    }
                }
            }
            
            HStack {
                Text("Mild")
                Spacer()
                Text("Severe")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
