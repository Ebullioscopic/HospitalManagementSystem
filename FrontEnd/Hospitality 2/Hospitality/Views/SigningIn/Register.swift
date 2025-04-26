import SwiftUI
import Combine

struct Register: View {
    @StateObject private var viewModel = UserSignupViewModel()
    
    @State private var currentStep = 1
        @State private var name = ""
        @State private var phone = ""
        @State private var email = ""
        @State private var password = ""
        @State private var confirmPassword = ""
        @State private var otpCode = ""
        @State private var dob = Date()
        @State private var bloodGroup = ""
        @State private var gender: String?
        @State private var isLoading = false
        @State private var showError = false
        @State private var errorMessage = ""
        @State private var navigateToHome = false
        @State private var isPasswordVisible = false
        @State private var isConfirmPasswordVisible = false
        @FocusState private var focusedField: Field?
        @Environment(\.dismiss) var dismiss
    
    enum Field: Hashable {
        case name, phone, email,password,confirmPassword, otp
    }
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    BackgroundView()
                    StickyHeaderView(title: "Patient Registration")
                        .zIndex(1)
                    
                    ScrollView {
                        VStack(spacing: 40) {
                            Spacer().frame(height: 180)
                            HStack(spacing: 12) {
                                ForEach(1...3, id: \.self) { step in
                                    Circle()
                                        .fill(currentStep >= step ? Color(hex: "4A90E2") : Color.gray.opacity(0.2))
                                        .frame(width: 12, height: 12)
                                        .scaleEffect(currentStep == step ? 1.2 : 1)
                                        .animation(.spring(), value: currentStep)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Form Cards
                            VStack(spacing: 24) {
                                switch currentStep {
                                case 1:
                                    Step1Form()
                                case 2:
                                    Step2OTP()
                                case 3:
                                    Step3Details()
                                default:
                                    EmptyView()
                                }
                                
                                ContinueButton()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePatient()
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if !newValue.isEmpty {
                    showError(message: newValue)
                }
            }
            .onChange(of: viewModel.otpRequestSuccess) { success in
                if success {
                    currentStep = 2
                }
            }
            .onChange(of: viewModel.signupSuccess) { success in
                if success {
                    currentStep = 3
                }
            }
            .onChange(of: viewModel.profileUpdateSuccess) { success in
                if success {
                    navigateToHome = true
                    print("Profile updated successfully")
                }
            }
        }
    }
    
    // MARK: - Step Views
    @ViewBuilder
    private func Step1Form() -> some View {
        VStack(spacing: 24) {
            InfoField(title: "Full Name", text: $name)
                .focused($focusedField, equals: .name)
                .textContentType(.name)
                .submitLabel(.next)
            
            InfoField(title: "Phone Number", text: $phone)
                .focused($focusedField, equals: .phone)
                .keyboardType(.phonePad)
                .submitLabel(.next)
            
            InfoField(title: "Email Address", text: $email)
                .focused($focusedField, equals: .email)
                .onChange(of: email) { newValue in
                    email = newValue.lowercased()
                }
                .keyboardType(.emailAddress)
                .submitLabel(.done)
            
            // Password Field
                        PasswordField(
                            title: "Password",
                            text: $password,
                            isVisible: $isPasswordVisible
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        
                        // Confirm Password Field
                        PasswordField(
                            title: "Confirm Password",
                            text: $confirmPassword,
                            isVisible: $isConfirmPasswordVisible
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                        
                        // Password strength indicator
                        if !password.isEmpty {
                            PasswordStrengthView(password: password)
                        }
                        
                        // Password match indicator
                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                
                                Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                                    .font(.caption)
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                
                                Spacer()
                            }
                            .padding(.top, -12)
                            .padding(.leading, 4)
                        }
        }
    }
    
    @ViewBuilder
    private func Step2OTP() -> some View {
        VStack(spacing: 24) {
            Text("We've sent a 6-digit code to your email")
                .font(.subheadline)
                .foregroundColor(.gray)
                .transition(.opacity)
            
            OTPTextField(text: $otpCode)
        }
    }
    
    @ViewBuilder
    private func Step3Details() -> some View {
        VStack(spacing: 16) {
            // Date of Birth
            HStack(alignment: .center, spacing: 12) {
                Text("Date of Birth")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "4A5568"))
                
                Spacer()
                
                DatePicker("", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .frame(width: 150)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Gender
            HStack(alignment: .center, spacing: 12) {
                Text("Gender")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "4A5568"))
                
                Spacer()
                
                Picker("Gender", selection: $gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .pickerStyle(.segmented)
                .padding(4)
                .frame(width: 150)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Blood Group
            HStack(alignment: .center, spacing: 12) {
                Text("Blood Group")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "4A5568"))
                
                Spacer()
                
                BloodGroupPicker(selectedGroup: $bloodGroup)
                    .frame(width: 150)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Continue Button
    @ViewBuilder
    private func ContinueButton() -> some View {
        Button(action: handleContinue) {
            HStack {
                Text(currentStep == 3 ? "Complete Registration" : "Continue")
                    .font(.headline)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.leading, 8)
                } else {
                    Image(systemName: currentStep == 3 ? "checkmark.circle.fill" : "arrow.right")
                        .font(.system(size: 20))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color(hex: "5E5CE6"), Color(hex: "4A90E2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: Color(hex: "4A90E2").opacity(0.3), radius: 10, x: 0, y: 4)
            .opacity(viewModel.isLoading ? 0.8 : 1)
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(viewModel.isLoading)
    }
    
    // MARK: - Handlers
    private func handleContinue() {
        withAnimation {
            switch currentStep {
            case 1:
                validateStep1()
            case 2:
                validateStep2()
            case 3:
                completeRegistration()
            default: break
            }
        }
    }
    
    private func validateStep1() {
        guard !name.isEmpty else {
            showError(message: "Please enter your full name")
            return
        }
        guard !phone.isEmpty else {
            showError(message: "Please enter your phone number")
            return
        }
        guard !email.isEmpty else {
            showError(message: "Please enter your email address")
            return
        }
        print("Button pressed")
        viewModel.requestOTP(email: email)
    }
    
    private func validateStep2() {
        guard otpCode.count == 6 else {
            showError(message: "Please enter the 6-digit code")
            return
        }
        
        guard let phoneInt = Int(phone) else {
            showError(message: "Invalid phone number format")
            return
        }
        
        // Password validation - make sure passwords were entered and match
        guard !password.isEmpty else {
            showError(message: "Please enter a password")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "Passwords don't match")
            return
        }
        
        // Minimum password length check
        guard password.count >= 8 else {
            showError(message: "Password must be at least 8 characters")
            return
        }
        
        viewModel.completeSignup(
            email: email,
            otp: otpCode,
            patientName: name,
            patientPhone: phoneInt,
            patientPassword: password // Use the user input password instead of hardcoded value
        )
    }
    
    private func completeRegistration() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let dobYear = calendar.component(.year, from: dob)
        
        if currentYear - dobYear > 120 || dobYear > currentYear {
            showError(message: "Please select a valid date of birth")
            return
        }
        
        guard !bloodGroup.isEmpty else {
            showError(message: "Please select blood group")
            return
        }
        
        guard let genderString = gender, !genderString.isEmpty else {
            showError(message: "Please select gender")
            return
        }
        
        let genderBoolean = (genderString == "Male")
        
        viewModel.updatePatientProfile(
            patientDob: dob,
            patientGender: genderBoolean,
            patientBloodGroup: bloodGroup,
            patientAddress: "Default Address" // You might want to add an address field to your form
        )
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        triggerHaptic()
    }
    
    private func triggerHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Custom Components
struct StickyHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Top Bar
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color(hex: "101420").opacity(0.95) : Color(hex: "E8F5FF").opacity(0.95),
                            colorScheme == .dark ? Color(hex: "101420").opacity(0.9) : Color(hex: "E8F5FF").opacity(0.9)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(height: 30)

            HStack {
                Spacer() // Replace left arrow with spacer
                
                // Centered Title and logo
                VStack(spacing: 2) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "5E5CE6"),
                                        Color(hex: "4A90E2")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                    
                    Text("Create your account")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                }

                Spacer() // Balance the layout
            }
            .padding(.top, 40)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(hex: "101420").opacity(0.95) : Color(hex: "E8F5FF").opacity(0.95),
                        colorScheme == .dark ? Color(hex: "1A202C").opacity(0.9) : Color(hex: "F0F8FF").opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .background(
                TransparentBlurView(style: colorScheme == .dark ? .dark : .light)
                    .opacity(0.9)
            )
        }
    }
}

// MARK: - Password Field
struct PasswordField: View {
    var title: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
            
            HStack {
                if isVisible {
                    TextField("", text: $text)
                        .foregroundColor(.primary)
                } else {
                    SecureField("", text: $text)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(hex: "4A90E2"))
                }
                .padding(.trailing, 12)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(
                        colorScheme == .dark ? Color(hex: "1A202C").opacity(0.4) : Color.white.opacity(0.6)
                    ))
            )
        }
    }
}

// MARK: - Password Strength View
struct PasswordStrengthView: View {
    var password: String
    @Environment(\.colorScheme) var colorScheme
    
    private var strength: Int {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil { score += 1 }
        
        return score
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Password Strength:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(strengthLabel)
                    .font(.caption)
                    .foregroundColor(strengthColor)
                
                Spacer()
            }
            
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    Capsule()
                        .fill(index < strength ? strengthColor :
                            colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .animation(.spring(), value: strength)
                }
            }
        }
        .padding(.top, -4)
        .padding(.horizontal, 4)
    }
    
    private var strengthLabel: String {
        switch strength {
        case 0: return "Very Weak"
        case 1: return "Weak"
        case 2: return "Medium"
        case 3: return "Strong"
        case 4: return "Very Strong"
        default: return ""
        }
    }
    
    private var strengthColor: Color {
        switch strength {
        case 0, 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray
        }
    }
}




struct DatePickerField: View {
    @Binding var selectedDate: Date
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date of Birth")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .padding(.leading, 12)
                
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.primary)
                    .padding(.vertical, 15)
                
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
            )
            .onTapGesture { showDatePicker.toggle() }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .padding()
                    
                    Button("Done") { showDatePicker = false }
                        .padding()
                }
            }
        }
    }
}

struct BloodGroupPicker: View {
    @Binding var selectedGroup: String
    let bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var body: some View {
        Menu {
            ForEach(bloodGroups, id: \.self) { group in
                Button(group) { selectedGroup = group }
            }
        } label: {
            HStack {
                Text(selectedGroup.isEmpty ? "Select" : selectedGroup)
                    .foregroundColor(selectedGroup.isEmpty ? .gray : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
            )
        }
    }
}

struct GenderSelector: View {
    @Binding var selectedGender: String?
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                ForEach(genders, id: \.self) { gender in
                    Button(action: { selectedGender = gender }) {
                        HStack {
                            Image(systemName: iconForGender(gender))
                            Text(gender)
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedGender == gender ? Color(hex: "4A90E2").opacity(0.2) : Color.gray.opacity(0.1))
                                .strokeBorder(selectedGender == gender ? Color(hex: "4A90E2") : Color.clear, lineWidth: 1.5)
                        )
                        .foregroundColor(selectedGender == gender ? Color(hex: "4A90E2") : .gray)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
    }
    
    private func iconForGender(_ gender: String) -> String {
        switch gender {
        case "Male": return "mustache.fill"
        case "Female": return "eyelashes.fill"
        default: return "person.fill.questionmark"
        }
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                Register()
            }
            .preferredColorScheme(.light)
            
            NavigationStack {
                Register()
            }
            .preferredColorScheme(.dark)
        }
    }
}
