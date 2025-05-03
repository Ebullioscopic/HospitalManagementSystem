import SwiftUI

struct Invoice: Identifiable {
    let id = UUID()
    let invoiceNumber: String
    let customerName: String
    let amount: Double
    let date: Date
    let status: InvoiceStatus
    let items: [InvoiceItem]
}

struct InvoiceItem: Identifiable {
    let id = UUID()
    let description: String
    let quantity: Int
    let unitPrice: Double
    
    var total: Double {
        return Double(quantity) * unitPrice
    }
}

enum InvoiceStatus: String, CaseIterable {
    case paid = "Paid"
}

struct CustomSegmentedControl: View {
    @Binding var selectedSegment: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Picker("View", selection: $selectedSegment) {
            Text("Recents").tag("Recents")
            Text("Monthly").tag("Monthly")
            Text("Yearly").tag("Yearly")
        }
        .pickerStyle(SegmentedPickerStyle())
        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "4A90E2").opacity(0.5), lineWidth: 1.5)
        )
        .background(
            CustomSegmentBackground(selectedSegment: $selectedSegment, colorScheme: colorScheme)
        )
        .padding(.vertical, 6)
    }
}

struct CustomSegmentBackground: View {
    @Binding var selectedSegment: String
    let colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if selectedSegment == "Recents" {
                    Color.white.opacity(colorScheme == .dark ? 0.2 : 0.1)
                        .frame(width: geo.size.width / 3)
                } else if selectedSegment == "Monthly" {
                    Color.white.opacity(colorScheme == .dark ? 0.2 : 0.1)
                        .frame(width: geo.size.width / 3)
                } else if selectedSegment == "Yearly" {
                    Color.white.opacity(colorScheme == .dark ? 0.2 : 0.1)
                        .frame(width: geo.size.width / 3)
                }
            }
            .cornerRadius(10)
        }
        .frame(height: 30)
    }
}


struct InvoiceView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var opacity: Double = 0.0
    @State private var searchText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var iconScale: CGFloat = 0.8
    @State private var isDateFilterActive: Bool = false
    @State private var selectedInvoice: Invoice? = nil
    @State private var selectedSegment: String = "Recents"
    
    @State private var invoices: [Invoice] = [
        Invoice(
            invoiceNumber: "INV-2025-001",
            customerName: "Alex Johnson",
            amount: 1250.00,
            date: Date(),
            status: .paid,
            items: [
                InvoiceItem(description: "Web Design", quantity: 1, unitPrice: 1000.00),
                InvoiceItem(description: "Domain Registration", quantity: 1, unitPrice: 250.00)
            ]
        ),
        Invoice(
            invoiceNumber: "INV-2025-002",
            customerName: "Tech Solutions Inc.",
            amount: 3750.00,
            date: Date().addingTimeInterval(-86400 * 2),
            status: .paid,
            items: [
                InvoiceItem(description: "Software Development", quantity: 15, unitPrice: 250.00)
            ]
        ),
        Invoice(
            invoiceNumber: "INV-2025-003",
            customerName: "Creative Studios",
            amount: 850.00,
            date: Date().addingTimeInterval(-86400 * 5),
            status: .paid,
            items: [
                InvoiceItem(description: "Logo Design", quantity: 1, unitPrice: 500.00),
                InvoiceItem(description: "Business Card Design", quantity: 1, unitPrice: 350.00)
            ]
        ),
        Invoice(
            invoiceNumber: "INV-2025-004",
            customerName: "Retail Partners Ltd.",
            amount: 2100.00,
            date: Date().addingTimeInterval(-86400 * 3),
            status: .paid,
            items: [
                InvoiceItem(description: "E-commerce Setup", quantity: 1, unitPrice: 1500.00),
                InvoiceItem(description: "Product Photography", quantity: 20, unitPrice: 30.00)
            ]
        )
    ]
    
    private var filteredInvoices: [Invoice] {
        switch selectedSegment {
        case "Monthly":
            return generateMonthlyInvoice()
        case "Yearly":
            return generateYearlyInvoice()
        default: // Recents
            return invoices.filter { invoice in
                let matchesSearch = searchText.isEmpty ||
                    invoice.customerName.lowercased().contains(searchText.lowercased()) ||
                    invoice.invoiceNumber.lowercased().contains(searchText.lowercased())
                
                let matchesDate = !isDateFilterActive || Calendar.current.isDate(invoice.date, inSameDayAs: selectedDate)
                
                return matchesSearch && matchesDate
            }
        }
    }
    
    private func generateMonthlyInvoice() -> [Invoice] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }
        
        let monthlyInvoices = invoices.filter { invoice in
            invoice.date >= startOfMonth && invoice.date < endOfMonth
        }
        
        let totalAmount = monthlyInvoices.reduce(0.0) { $0 + $1.amount }
        let allItems = monthlyInvoices.flatMap { $0.items }
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let monthString = monthFormatter.string(from: selectedDate)
        
        return [Invoice(
            invoiceNumber: "INV-MONTHLY-\(monthString.replacingOccurrences(of: " ", with: "-"))",
            customerName: "Monthly Summary",
            amount: totalAmount,
            date: startOfMonth,
            status: .paid,
            items: allItems
        )]
    }
    
    private func generateYearlyInvoice() -> [Invoice] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: selectedDate)
        guard let startOfYear = calendar.date(from: components),
              let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) else {
            return []
        }
        
        let yearlyInvoices = invoices.filter { invoice in
            invoice.date >= startOfYear && invoice.date < endOfYear
        }
        
        let totalAmount = yearlyInvoices.reduce(0.0) { $0 + $1.amount }
        let allItems = yearlyInvoices.flatMap { $0.items }
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let yearString = yearFormatter.string(from: selectedDate)
        
        return [Invoice(
            invoiceNumber: "INV-YEARLY-\(yearString)",
            customerName: "Yearly Summary",
            amount: totalAmount,
            date: startOfYear,
            status: .paid,
            items: allItems
        )]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "F0F7FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F8FBFF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Invoices")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("Manage and track your invoices")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search invoices...", text: $searchText)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    
                    // Segmented Control and Date Picker
                    HStack(spacing: 12) {
                        CustomSegmentedControl(selectedSegment: $selectedSegment)
                        
                        DatePicker(
                            "",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .accentColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                        .opacity(isDateFilterActive ? 1.0 : 0.5)
                    }
                    .padding(.horizontal)
                    
                    // Invoices List
                    LazyVStack(spacing: 12) {
                        if filteredInvoices.isEmpty {
                            Text("No invoices found")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredInvoices) { invoice in
                                InvoiceCard(invoice: invoice) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedInvoice = invoice
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.vertical)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1.0
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                    iconScale = 1.0
                }
            }
            
            // Invoice Detail Popup
            if let invoice = selectedInvoice {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedInvoice = nil
                        }
                    }
                
                InvoiceDetailView(invoice: invoice, isPresented: Binding(
                    get: { selectedInvoice != nil },
                    set: { if !$0 { selectedInvoice = nil } }
                ))
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Invoice Card Component
struct InvoiceCard: View {
    let invoice: Invoice
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(getStatusColor().opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: getStatusIcon())
                        .font(.system(size: 22))
                        .foregroundColor(getStatusColor())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(invoice.invoiceNumber)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                        
                        Spacer()
                        
                        Text("₹\(invoice.amount, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                    }
                    
                    Text(invoice.customerName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                    
                    HStack {
                        Text(invoice.date, style: .date)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        
                        Spacer()
                        
                        Text(invoice.status.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(getStatusColor())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(getStatusColor().opacity(0.1))
                            )
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(getStatusColor().opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getStatusIcon() -> String {
        switch invoice.status {
        case .paid:
            return "checkmark.circle"
        }
    }
    
    private func getStatusColor() -> Color {
        switch invoice.status {
        case .paid:
            return colorScheme == .dark ? Color(hex: "4CAF50") : Color(hex: "43A047")
        }
    }
}

// Invoice Detail View
struct InvoiceDetailView: View {
    let invoice: Invoice
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Invoice Details")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                }
            }
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invoice Number")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        
                        Text(invoice.invoiceNumber)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                    }
                    
                    Spacer()
                    
                    Text(invoice.status.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(getStatusColor(for: invoice.status))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(getStatusColor(for: invoice.status).opacity(0.1))
                        )
                }
                
                Divider()
                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color(hex: "E2E8F0"))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Customer")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        
                        Text(invoice.customerName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Date")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        
                        Text(invoice.date, style: .date)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                    }
                }
                
                Divider()
                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color(hex: "E2E8F0"))
                
                HStack {
                    Text("Description")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                    
                    Spacer()
                    
                    Text("Qty")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        .frame(width: 40)
                    
                    Text("Price")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        .frame(width: 70)
                    
                    Text("Total")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                        .frame(width: 70)
                }
                
                ForEach(invoice.items) { item in
                    HStack {
                        Text(item.description)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                            .frame(width: 40)
                        
                        Text("₹\(item.unitPrice, specifier: "%.2f")")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                            .frame(width: 70)
                        
                        Text("₹\(item.total, specifier: "%.2f")")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                            .frame(width: 70)
                    }
                    
                    Divider()
                        .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color(hex: "EDF2F7"))
                }
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack {
                            Text("Total:")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                            
                            Text("₹\(invoice.amount, specifier: "%.2f")")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color(hex: "4CAF50") : Color(hex: "43A047"))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
            )
            
            HStack {
                Button(action: {
                    // Download invoice
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Download")
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "4A90E2"))
                    .cornerRadius(10)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "101420") : .white)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .frame(width: 360)
        .frame(maxHeight: 600)
    }
    
    private func getStatusColor(for status: InvoiceStatus) -> Color {
        switch status {
        case .paid:
            return colorScheme == .dark ? Color(hex: "4CAF50") : Color(hex: "43A047")
        }
    }
}

struct InvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceView()
            .preferredColorScheme(.light)
        InvoiceView()
            .preferredColorScheme(.dark)
    }
}

