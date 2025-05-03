import SwiftUI

struct Report: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let type: String
}

struct ReportsContent: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var opacity: Double = 0.0
    @State private var searchText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedFilter: String = "All"
    @State private var iconScale: CGFloat = 0.8
    @State private var isDateFilterActive: Bool = false // Track if date filter is active
    
    // Sample reports data with dates including today and recent past
    @State private var reports: [Report] = [
        Report(title: "Blood Test Results", date: Date(), type: "Lab"), // Today
        Report(title: "X-Ray Report", date: Date().addingTimeInterval(-86400 * 1), type: "Imaging"), // Yesterday
        Report(title: "Cardiology Consultation", date: Date().addingTimeInterval(-86400 * 2), type: "Consultation"), // 2 days ago
        Report(title: "MRI Scan Results", date: Date().addingTimeInterval(-86400 * 3), type: "Imaging") // 3 days ago
    ]
    
    private var filteredReports: [Report] {
        reports.filter { report in
            // Search text filter
            let matchesSearch = searchText.isEmpty || report.title.lowercased().contains(searchText.lowercased())
            // Type filter
            let matchesType = selectedFilter == "All" || report.type == selectedFilter
            // Date filter (only applied if isDateFilterActive is true)
            let matchesDate = !isDateFilterActive || Calendar.current.isDate(report.date, inSameDayAs: selectedDate)
            
            return matchesSearch && matchesType && matchesDate
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background circles
            ForEach(0..<8) { _ in
                Circle()
                    .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                    .frame(width: CGFloat.random(in: 50...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 3)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Medical Reports")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("View and manage your medical reports")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isDateFilterActive.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A90E2"))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                                )
                                .scaleEffect(iconScale)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search reports...", text: $searchText)
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
                    
                    // Filter and Date Picker
                    HStack(spacing: 12) {
                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag("All")
                            Text("Lab").tag("Lab")
                            Text("Imaging").tag("Imaging")
                            Text("Consultation").tag("Consultation")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                        )
                        
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
                    
                    // Reports List
                    LazyVStack(spacing: 12) {
                        if filteredReports.isEmpty {
                            Text("No reports found")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredReports) { report in
                                ReportCard(report: report)
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
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Report Card Component
struct ReportCard: View {
    let report: Report
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
                // Add navigation to report details
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon with colored background
                ZStack {
                    Circle()
                        .fill(getReportColor().opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: getReportIcon())
                        .font(.system(size: 24))
                        .foregroundColor(getReportColor())
                }
                .padding(.bottom, 4)
                
                // Title
                Text(report.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                
                // Type and Date
                HStack {
                    Text(report.type)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                    
                    Spacer()
                    
                    Text(report.date, style: .date)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(getReportColor().opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getReportIcon() -> String {
        switch report.type {
        case "Lab":
            return "testtube.2"
        case "Imaging":
            // Use "lungs" for X-Ray and "waveform.path.ecg" for MRI/CT
            return report.title.contains("X-Ray") ? "lungs" : "waveform.path.ecg"
        case "Consultation":
            return "stethoscope"
        default:
            return "doc.text"
        }
    }
    
    private func getReportColor() -> Color {
        switch report.type {
        case "Lab":
            return colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "2196F3")
        case "Imaging":
            return colorScheme == .dark ? Color(hex: "26A69A") : Color(hex: "009688")
        case "Consultation":
            return colorScheme == .dark ? Color(hex: "EF5350") : Color(hex: "F44336")
        default:
            return colorScheme == .dark ? .blue : Color(hex: "4A90E2")
        }
    }
}


struct ReportsContent_Previews: PreviewProvider {
    static var previews: some View {
        ReportsContent()
            .preferredColorScheme(.light)
        ReportsContent()
            .preferredColorScheme(.dark)
    }
}
