import SwiftUI

// MARK: - Payment Method Enum
enum PaymentMethod: String, CaseIterable, Identifiable {
    case card = "Card"
    case upi = "UPI"
    case netbanking = "Netbanking"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .card:
            return "Visa, MasterCard, RuPay & More"
        case .upi:
            return "Instant payment using UPI App"
        case .netbanking:
            return "All Indian banks"
        }
    }
    
    var icon: String {
        switch self {
        case .card:
            return "creditcard"
        case .upi:
            return "arrow.triangle.2.circlepath"
        case .netbanking:
            return "building.columns"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .card:
            return Color.orange
        case .upi:
            return Color.red
        case .netbanking:
            return Color.blue
        }
    }
}

// MARK: - Bank Model
struct Bank: Identifiable {
    let id = UUID()
    let name: String
    let isPopular: Bool
    
    static let popularBanks = [
        Bank(name: "State Bank of India", isPopular: true),
        Bank(name: "HDFC Bank", isPopular: true),
        Bank(name: "ICICI Bank", isPopular: true),
        Bank(name: "Axis Bank", isPopular: true)
    ]
    
    static let otherBanks = [
        Bank(name: "Bank of Baroda", isPopular: false),
        Bank(name: "Punjab National Bank", isPopular: false),
        Bank(name: "Kotak Mahindra Bank", isPopular: false),
        Bank(name: "Yes Bank", isPopular: false),
        Bank(name: "Canara Bank", isPopular: false),
        Bank(name: "IndusInd Bank", isPopular: false),
        Bank(name: "Bank of India", isPopular: false),
        Bank(name: "Union Bank of India", isPopular: false)
    ]
}

// MARK: - Payment Gateway View
struct PaymentGatewayView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var selectedBank: Bank?
    @State private var upiId = ""
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    @State private var showingFailureAlert = false
    @State private var transactionId = ""
    @State private var paymentAmount: Double = 1.00
    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var phoneNumber = "+917979983792"
    @State private var email = "a@a.com"
    @State private var showEditContactInfo = false
    @State private var timeoutSeconds = 2
    @State private var timer: Timer?
    @State private var showingSuccessView = false
    @Environment(\.colorScheme) var colorScheme

    
    // MARK: - Card Validation
    private var isCardFormValid: Bool {
        cardNumber.count == 16 && !cardholderName.isEmpty && expiryDate.count == 5 && cvv.count == 3
    }
    
    private var isUpiFormValid: Bool {
        upiId.contains("@") && upiId.count >= 3
    }
    
    private var isNetbankingFormValid: Bool {
        selectedBank != nil
    }
    
    private var isFormValid: Bool {
        switch selectedPaymentMethod {
        case .card:
            return isCardFormValid
        case .upi:
            return isUpiFormValid
        case .netbanking:
            return isNetbankingFormValid
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Payment Header
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                                colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                            .edgesIgnoringSafeArea(.top)
                        
                        HStack {
                            // Product/Service Image
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.blue, lineWidth: 1)
                                            .frame(width: 40, height: 40)
                                        
                                        Text("?")
                                            .font(.title)
                                            .foregroundColor(.blue)
                                    }
                                )
                            
                            // Amount
                            HStack {
                                Text("₹")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text("\(String(format: "%.2f", paymentAmount))")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            // Close Button
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 120)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Contact Info
                            contactInfoView
                            
                            // Payment Methods Section
                            paymentMethodsSection
                            
                            // Selected Payment Method Form
                            selectedPaymentMethodView
                            
                            // Pay Button
                            payButton
                                .padding(.horizontal)
                                .padding(.bottom)
                                
                            // Timeout indicator
                            timeoutView
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSuccessView) {
                PaymentSuccessView(transactionId: transactionId, paymentAmount: paymentAmount)
            }
            .sheet(isPresented: $showEditContactInfo) {
                ContactEditView(
                    phoneNumber: $phoneNumber,
                    email: $email,
                    onDismiss: {
                        showEditContactInfo = false
                    }
                )
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // MARK: - Component Views
    private var contactInfoView: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "4A90E2"))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phoneNumber)
                    .fontWeight(.medium)
                
                Text(email)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .padding(.leading, 4)
            
            Spacer()
            
            Button(action: {
                showEditContactInfo = true
            }) {
                Text("Edit")
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "4A90E2"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PREFERRED PAYMENT METHODS")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Popular banks for netbanking
            if selectedPaymentMethod == .netbanking {
                popularBanksView
            }
            
            Text("CARDS, UPI & MORE")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Payment method options
            VStack(spacing: 0) {
                ForEach(PaymentMethod.allCases) { method in
                    paymentMethodRow(method)
                }
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
    
    private var popularBanksView: some View {
        VStack(spacing: 0) {
            ForEach(Bank.popularBanks) { bank in
                Button(action: {
                    selectedBank = bank
                }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)
                            
                            Text(String(bank.name.prefix(1)))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        Text("Netbanking - \(bank.name)")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedBank?.name == bank.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
                
                if bank.id != Bank.popularBanks.last?.id {
                    Divider()
                        .padding(.leading, 50)
                }
            }
        }
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func paymentMethodRow(_ method: PaymentMethod) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedPaymentMethod = method
            }) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(method.iconColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: method.icon)
                            .foregroundColor(method.iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(method.rawValue)
                            .fontWeight(.medium)
                        
                        Text(method.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    if selectedPaymentMethod == method {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(selectedPaymentMethod == method ? Color(UIColor.systemGray6) : Color.white)
            }
            .buttonStyle(PlainButtonStyle())
            
            if method != PaymentMethod.allCases.last {
                Divider()
                    .padding(.leading, 50)
            }
        }
    }
    
    private var selectedPaymentMethodView: some View {
        Group {
            switch selectedPaymentMethod {
            case .card:
                cardFormView
            case .upi:
                upiFormView
            case .netbanking:
                netbankingFormView
            }
        }
    }
    
    private var cardFormView: some View {
        VStack(spacing: 16) {
            // Card Number Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Number")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("1234 5678 9012 3456", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .onChange(of: cardNumber) { newValue in
                        if newValue.count > 16 {
                            cardNumber = String(newValue.prefix(16))
                        }
                    }
            }
            
            // Cardholder Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Cardholder Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("John Doe", text: $cardholderName)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            
            // Expiry & CVV Fields
            HStack(spacing: 16) {
                // Expiry Date Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Expiry Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("MM/YY", text: $expiryDate)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: expiryDate) { newValue in
                            if newValue.count >= 2 && !newValue.contains("/") {
                                expiryDate = newValue.prefix(2) + "/" + newValue.dropFirst(2)
                            }
                            if newValue.count > 5 {
                                expiryDate = String(newValue.prefix(5))
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                
                // CVV Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("CVV")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SecureField("123", text: $cvv)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: cvv) { newValue in
                            if newValue.count > 3 {
                                cvv = String(newValue.prefix(3))
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var upiFormView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UPI ID")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("yourname@upi", text: $upiId)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var netbankingFormView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Banks")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Bank.otherBanks) { bank in
                        Button(action: {
                            selectedBank = bank
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 30, height: 30)
                                    
                                    Text(String(bank.name.prefix(1)))
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                
                                Text(bank.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedBank?.name == bank.name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(selectedBank?.name == bank.name ? Color(UIColor.systemGray6) : Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if bank.id != Bank.otherBanks.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
            }
            .frame(height: 250)
        }
        .padding(.horizontal)
    }
    
    private var payButton: some View {
        Button(action: processPayment) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 5)
                }
                
                Text(isProcessing ? "Processing..." : "PAY ₹\(String(format: "%.2f", paymentAmount))")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color(hex: "4A90E2") : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isProcessing)
    }
    
    private var timeoutView: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.gray)
            
            Text("This page will timeout in \(timeoutSeconds < 10 ? "0:0\(timeoutSeconds)" : "0:\(timeoutSeconds)") minutes")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "FFF9E0"))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    private func processPayment() {
        // Simulate payment processing
        isProcessing = true
        
        // Generate random transaction ID
        let randomID = String(format: "%08X", Int.random(in: 10000000...99999999))
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            transactionId = "TXN\(randomID)"
            showingSuccessView = true // Show success view instead of alert
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeoutSeconds > 0 {
                timeoutSeconds -= 1
            } else {
                // Handle timeout (would dismiss in real app)
                timer?.invalidate()
            }
        }
    }
}

// MARK: - Contact Edit View
struct ContactEditView: View {
    @Binding var phoneNumber: String
    @Binding var email: String
    var onDismiss: () -> Void
    
    @State private var tempPhone: String
    @State private var tempEmail: String
    
    init(phoneNumber: Binding<String>, email: Binding<String>, onDismiss: @escaping () -> Void) {
        self._phoneNumber = phoneNumber
        self._email = email
        self.onDismiss = onDismiss
        
        // Initialize temporary state with current values
        self._tempPhone = State(initialValue: phoneNumber.wrappedValue)
        self._tempEmail = State(initialValue: email.wrappedValue)
    }
    
    var body: some View {
        return NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Phone Number", text: $tempPhone)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationBarTitle("Edit Contact Info", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onDismiss()
                },
                trailing: Button("Save") {
                    phoneNumber = tempPhone
                    email = tempEmail
                    onDismiss()
                }
            )
        }
    }
}

// MARK: - Preview
struct PaymentGatewayView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentGatewayView()
    }
}
