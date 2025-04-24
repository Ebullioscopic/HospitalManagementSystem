import SwiftUI
import Charts

struct AdminHomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var showProfile = false
    @State private var selectedGraphType = 0
    @State private var cardScale: CGFloat = 0.95
    @State private var cardOpacity: Double = 0
    @State private var iconPulse: CGFloat = 1.0
    
    // Sample analytics data
    let occupancyData = [
        AnalyticsData(month: "Jan", value: 75),
        AnalyticsData(month: "Feb", value: 82),
        AnalyticsData(month: "Mar", value: 88),
        AnalyticsData(month: "Apr", value: 92),
        AnalyticsData(month: "May", value: 86),
        AnalyticsData(month: "Jun", value: 79)
    ]
    
    let revenueData = [
        AnalyticsData(month: "Jan", value: 12500),
        AnalyticsData(month: "Feb", value: 14800),
        AnalyticsData(month: "Mar", value: 16300),
        AnalyticsData(month: "Apr", value: 18200),
        AnalyticsData(month: "May", value: 17100),
        AnalyticsData(month: "Jun", value: 14900)
    ]
    
    let feedbackData = [
        AnalyticsData(month: "Jan", value: 4.2),
        AnalyticsData(month: "Feb", value: 4.5),
        AnalyticsData(month: "Mar", value: 4.8),
        AnalyticsData(month: "Apr", value: 4.7),
        AnalyticsData(month: "May", value: 4.6),
        AnalyticsData(month: "Jun", value: 4.9)
    ]
    
    let bookingData = [
        AnalyticsData(month: "Jan", value: 142),
        AnalyticsData(month: "Feb", value: 156),
        AnalyticsData(month: "Mar", value: 178),
        AnalyticsData(month: "Apr", value: 195),
        AnalyticsData(month: "May", value: 183),
        AnalyticsData(month: "Jun", value: 165)
    ]
    
    let staffData = [
        AnalyticsData(month: "Jan", value: 32),
        AnalyticsData(month: "Feb", value: 34),
        AnalyticsData(month: "Mar", value: 36),
        AnalyticsData(month: "Apr", value: 35),
        AnalyticsData(month: "May", value: 38),
        AnalyticsData(month: "Jun", value: 40)
    ]
    
    let graphTypes = ["Occupancy", "Revenue", "Feedback", "Bookings", "Staff"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with gradient and circles - matching login/onboarding
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                            colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ForEach(0..<12) { _ in
                        Circle()
                            .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                            .frame(width: CGFloat.random(in: 50...200))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .blur(radius: 3)
                    }
                }
                
                // Content
                TabView(selection: $selectedTab) {
                    // Home Tab
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Header with welcome message and profile button
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome Back")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                    
                                    Text("Admin Dashboard")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                }
                                
                                Spacer()
                                
                                Button {
                                    triggerHaptic()
                                    showProfile.toggle()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color.blue.opacity(0.05))
                                            .frame(width: 50, height: 50)
                                            .scaleEffect(iconPulse)
                                        
                                        Image(systemName: "person.circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Analytics Summary Cards
                            AnalyticsSummaryView()
                                .scaleEffect(cardScale)
                                .opacity(cardOpacity)
                            
                            // Analytics Graph
                            AnalyticsGraphSection(
                                selectedGraphType: $selectedGraphType,
                                occupancyData: occupancyData,
                                revenueData: revenueData,
                                feedbackData: feedbackData,
                                bookingData: bookingData,
                                staffData: staffData,
                                graphTypes: graphTypes
                            )
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        }
                        .padding(.bottom, 100) // Extra padding at bottom for scroll area
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    // Reports Tab
                    ReportsContent()
                        .tabItem {
                            Image(systemName: "chart.bar.doc.horizontal")
                            Text("Reports")
                        }
                        .tag(1)
                    
                    // Bills Tab
                    BillsContent()
                        .tabItem {
                            Image(systemName: "dollarsign.circle")
                            Text("Bills")
                        }
                        .tag(2)
                }
                .accentColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .onAppear {
                // Animate card appearance
                withAnimation(.easeOut(duration: 0.8)) {
                    cardOpacity = 1.0
                }
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    cardScale = 1.0
                }
                
                // Animate pulsing effect for icons
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    iconPulse = 1.05
                }
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct AnalyticsSummaryView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Analytics Overview")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalyticCard(title: "Occupancy Rate", value: "88%", icon: "bed.double.fill", color: Color(hex: "4A90E2"))
                AnalyticCard(title: "Revenue", value: "$18,200", icon: "dollarsign.circle.fill", color: Color(hex: "5E5CE6"))
                AnalyticCard(title: "Customer Rating", value: "4.7/5", icon: "star.fill", color: Color(hex: "4A90E2"))
                AnalyticCard(title: "Bookings", value: "195", icon: "calendar.badge.clock", color: Color(hex: "5E5CE6"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "1A202C").opacity(0.7) : Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal)
    }
}

struct AnalyticCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var iconPulse: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .scaleEffect(iconPulse)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18))
                }
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
            
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "101420").opacity(0.4) : Color.white.opacity(0.5))
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(Double.random(in: 0...0.5))) {
                iconPulse = 1.08
            }
        }
    }
}

struct AnalyticsGraphSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedGraphType: Int
    let occupancyData: [AnalyticsData]
    let revenueData: [AnalyticsData]
    let feedbackData: [AnalyticsData]
    let bookingData: [AnalyticsData]
    let staffData: [AnalyticsData]
    let graphTypes: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Performance Graphs")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Graph type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<graphTypes.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedGraphType = index
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Text(graphTypes[index])
                                .font(.system(size: 15, weight: selectedGraphType == index ? .semibold : .medium, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedGraphType == index ?
                                              (colorScheme == .dark ? Color.blue.opacity(0.2) : Color(hex: "4A90E2").opacity(0.15)) :
                                              (colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1)))
                                )
                                .foregroundColor(selectedGraphType == index ?
                                                 (colorScheme == .dark ? .blue : Color(hex: "4A90E2")) :
                                                 (colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568")))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Graph view
            GraphView(
                selectedGraphType: selectedGraphType,
                occupancyData: occupancyData,
                revenueData: revenueData,
                feedbackData: feedbackData,
                bookingData: bookingData,
                staffData: staffData
            )
            .frame(height: 300)
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "1A202C").opacity(0.7) : Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal)
    }
}

struct GraphView: View {
    @Environment(\.colorScheme) var colorScheme
    let selectedGraphType: Int
    let occupancyData: [AnalyticsData]
    let revenueData: [AnalyticsData]
    let feedbackData: [AnalyticsData]
    let bookingData: [AnalyticsData]
    let staffData: [AnalyticsData]
    
    var graphTitle: String {
        switch selectedGraphType {
        case 0: return "Monthly Occupancy Rate (%)"
        case 1: return "Monthly Revenue ($)"
        case 2: return "Customer Satisfaction (1-5)"
        case 3: return "Monthly Bookings"
        case 4: return "Staff Count"
        default: return ""
        }
    }
    
    var currentData: [AnalyticsData] {
        switch selectedGraphType {
        case 0: return occupancyData
        case 1: return revenueData
        case 2: return feedbackData
        case 3: return bookingData
        case 4: return staffData
        default: return []
        }
    }
    
    var graphColor: Color {
        switch selectedGraphType {
        case 0, 2, 4: return Color(hex: "4A90E2")
        case 1, 3: return Color(hex: "5E5CE6")
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(graphTitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(currentData) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [graphColor, graphColor.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: .automatic(includesZero: true))
            } else {
                // Fallback for iOS 15 and earlier
                LegacyGraphView(data: currentData, color: graphColor)
                    .frame(height: 200)
            }
            
            // Statistics row
            HStack {
                StatView(title: "Average", value: String(format: "%.1f", currentData.map { $0.value }.reduce(0, +) / Double(currentData.count)))
                Spacer()
                StatView(title: "Min", value: String(format: "%.1f", currentData.map { $0.value }.min() ?? 0))
                Spacer()
                StatView(title: "Max", value: String(format: "%.1f", currentData.map { $0.value }.max() ?? 0))
            }
            .padding(.top, 10)
            .padding(.horizontal, 5)
        }
    }
}

struct StatView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(hex: "4A5568"))
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(hex: "101420").opacity(0.4) : Color.white.opacity(0.5))
        )
    }
}

struct LegacyGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    let data: [AnalyticsData]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(data) { item in
                    VStack {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: (geometry.size.width / CGFloat(data.count)) - 8,
                                   height: calculateHeight(geometry: geometry, value: item.value))
                            .shadow(color: color.opacity(0.2), radius: 2, x: 0, y: 2)
                        
                        Text(item.month)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                            .padding(.top, 5)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    func calculateHeight(geometry: GeometryProxy, value: Double) -> CGFloat {
        let maxValue = data.map { $0.value }.max() ?? 1
        let availableHeight = geometry.size.height - 25  // Reserve space for labels
        return CGFloat(value / maxValue) * availableHeight
    }
}

struct QuickActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(hex: "2C5282"))
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? Color(hex: "101420").opacity(0.4) : Color.white.opacity(0.5))
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnalyticsData: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}

struct AdminHomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdminHomeView().preferredColorScheme(.light)
            AdminHomeView().preferredColorScheme(.dark)
        }
    }
}
