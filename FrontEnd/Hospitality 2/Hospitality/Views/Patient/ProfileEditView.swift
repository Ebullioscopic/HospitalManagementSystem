import SwiftUI

struct ProfileEditView: View {
    let patient: PatientProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: – State
    @State private var name: String
    @State private var mobile: String
    @State private var address: String
    @State private var dob: Date
    @State private var gender: Bool
    @State private var bloodGroup: String

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // MARK: – Constants
    private let primaryColor = Color(hex: "4A90E2")
    private let bgGradient: LinearGradient

    init(patient: PatientProfile) {
        self.patient = patient

        // Initialize state from model
        _name = State(initialValue: patient.patient_name)
        _mobile = State(initialValue: patient.patient_mobile ?? "")
        _address = State(initialValue: patient.patient_address ?? "")

        // Parse DOB string → Date
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: patient.patient_dob) {
            _dob = State(initialValue: date)
        } else {
            _dob = State(initialValue: Date())
        }

        _gender = State(initialValue: patient.patient_gender)
        _bloodGroup = State(initialValue: patient.patient_blood_group ?? "")

        // Gradient depends on color scheme—placeholder, will be overwritten in body
        bgGradient = LinearGradient(
            gradient: Gradient(colors: [.white, .white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // MARK: – Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // MARK: – Form
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                        .autocapitalization(.words)

                    TextField("Mobile Number", text: $mobile)
                        .keyboardType(.numberPad)
                        .onChange(of: mobile) { newValue in
                            mobile = newValue.filter { $0.isNumber }
                            if mobile.count > 10 {
                                mobile = String(mobile.prefix(10))
                            }
                        }

                    TextField("Address", text: $address)
                }

                Section(header: Text("Additional Information")) {
                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Picker("Blood Group", selection: $bloodGroup) {
                        ForEach(["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"], id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                // Add direct save button in the form as a fallback
                Section {
                    Button(action: updateProfile) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(primaryColor)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                }
                
                // Using different toolbar placement for better compatibility
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateProfile()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(primaryColor)
                }
           

}
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: – Networking
    private func updateProfile() {
        guard let url = URL(string: "\(Constants.baseURL)/accounts/patient/update-profile/") else {
            return showError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !UserDefaults.accessToken.isEmpty {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }

        // Prepare form data
        var body = Data()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let params: [String: String] = [
            "patient_name": name,
            "patient_mobile": mobile,
            "patient_dob": formatter.string(from: dob),
            "patient_gender": gender ? "true" : "false",
            "patient_blood_group": bloodGroup,
            "patient_address": address
        ]

        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Log request body
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request body: \(bodyString)")
        }

        // Send
        URLSession.shared.dataTask(with: request) { data, resp, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return showError(error.localizedDescription)
                }
                guard let http = resp as? HTTPURLResponse else {
                    print("Invalid response")
                    return showError("Invalid server response")
                }
                
                print("Status code: \(http.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }

                if (200..<300).contains(http.statusCode) {
                    // Parse response to check 'created' field (optional)
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                            let created = json?["created"] as? Bool ?? false
                            alertTitle = "Success"
                            alertMessage = created ? "New profile details created." : "Profile updated successfully."
                        } catch {
                            alertTitle = "Success"
                            alertMessage = "Profile updated successfully."
                        }
                    } else {
                        alertTitle = "Success"
                        alertMessage = "Profile updated successfully."
                    }
                    showAlert = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                } else {
                    // Parse error message
                    var errorMessage = "Server returned status code \(http.statusCode)"
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                       let error = json["error"] {
                        errorMessage = error
                    }
                    showError(errorMessage)
                }
            }
        }.resume()
    }

    private func showError(_ message: String) {
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
    }
}

// MARK: – Preview
struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileEditView(patient: PatientProfile(
                patient_id: 1,
                patient_name: "Jane Doe",
                patient_email: "jane@example.com",
                patient_mobile: "9876543210",
                patient_remark: nil,
                patient_dob: "1985-06-15",
                patient_gender: true,
                patient_blood_group: "A+",
                patient_address: "456 New Ave",
                profile_photo: nil
            ))
        }
    }
}
