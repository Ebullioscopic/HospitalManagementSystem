import SwiftUI

struct SpecialtyRecommendationView: View {
    let specialties: [String]
    let onRestart: () -> Void
    let onClose: () -> Void
    
    @State private var showDoctorList = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text("Recommended Specialties")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Based on your symptoms, we recommend consulting with:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    ForEach(specialties, id: \.self) { specialty in
                        SpecialtyCard(specialty: specialty)
                    }
                }
                .padding(.top)
                
                VStack(spacing: 15) {
                    Button(action: onRestart) {
                        Text("Start Over")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Book Appointment") {
                        showDoctorList = true
                    }
                    .padding()
                    
                    // Hidden navigation trigger
                    NavigationLink(destination: PatientDoctorListView(), isActive: $showDoctorList) {
                        EmptyView()
                            .buttonStyle(.borderedProminent)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
    }
    
    struct SpecialtyCard: View {
        let specialty: String
        
        var body: some View {
            HStack {
                Image(systemName: iconForSpecialty(specialty))
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(specialty)
                        .font(.headline)
                    Text(descriptionForSpecialty(specialty))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        
        private func iconForSpecialty(_ specialty: String) -> String {
            switch specialty {
            case "Cardiologist": return "heart.fill"
            case "Neurologist": return "brain.head.profile"
            case "Orthopedist": return "bone.fill"
            case "Dermatologist": return "bandage.fill"
            case "Gastroenterologist": return "mouth.fill"
            default: return "stethoscope"
            }
        }
        
        private func descriptionForSpecialty(_ specialty: String) -> String {
            switch specialty {
            case "Cardiologist": return "Heart and cardiovascular system specialist"
            case "Neurologist": return "Brain and nervous system specialist"
            case "Orthopedist": return "Bones and joints specialist"
            case "Dermatologist": return "Skin, hair and nails specialist"
            case "Gastroenterologist": return "Digestive system specialist"
            default: return "Medical specialist"
            }
        }
    }
}
