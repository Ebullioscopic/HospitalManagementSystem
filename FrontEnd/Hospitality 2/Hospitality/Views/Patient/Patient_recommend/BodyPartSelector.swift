import SwiftUI

struct BodyPartSelector: View {
    @Binding var selectedPart: String
    
    let bodyParts = [
        "Head", "Neck", "Shoulder", "Arm", "Elbow", "Hand",
        "Chest", "Abdomen", "Back", "Hip", "Leg", "Knee", "Foot"
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                ForEach(bodyParts, id: \.self) { part in
                    Button(action: {
                        selectedPart = part
                    }) {
                        VStack {
                            Image(systemName: iconForBodyPart(part))
                                .font(.system(size: 30))
                                .padding()
                                .frame(width: 70, height: 70)
                                .background(
                                    selectedPart == part ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground)
                                )
                                .cornerRadius(35)
                            
                            Text(part)
                                .font(.caption)
                        }
                        .foregroundColor(selectedPart == part ? .blue : .primary)
                    }
                }
            }
            .padding()
        }
    }
    
    private func iconForBodyPart(_ part: String) -> String {
        switch part.lowercased() {
        case "head": return "brain.head.profile"
        case "neck": return "figure.stand"
        case "shoulder": return "figure.arms.open"
        case "arm": return "figure.wave"
        case "elbow": return "figure.curling"
        case "hand": return "hand.raised.fill"
        case "chest": return "heart.fill"
        case "abdomen": return "figure.core.training"
        case "back": return "figure.strengthtraining.traditional"
        case "hip": return "figure.dance"
        case "leg": return "figure.walk"
        case "knee": return "figure.step.training"
        case "foot": return "figure.fall"
        default: return "questionmark.circle"
        }
    }
}
