import SwiftUI

struct TabPatient: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    private var tabColor: Color {
        colorScheme == .dark ? .blue : Color(hex: "4A90E2")
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1A202C") : .white
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
            
            TabView(selection: $selectedTab) {
                // Home Tab
                HomePatient()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // Reports Tab
                ReportsView()
                    .tabItem {
                        Label("Reports", systemImage: "chart.bar.doc.horizontal")
                    }
                    .tag(1)
                
                // Bills Tab
                BillsView()
                    .tabItem {
                        Label("Bills", systemImage: "dollarsign.circle")
                    }
                    .tag(2)
            }
            .accentColor(tabColor)
        }
    }
}



struct ReportsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background circles similar to onboarding
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
            
            VStack {
                Text("Reports")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Text("View your medical reports")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
        }
    }
}

struct BillsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background circles similar to onboarding
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
            
            VStack {
                Text("Bills")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Text("Track your medical expenses")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
        }
    }
}



// Preview
struct TabPatient_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabPatient().preferredColorScheme(.light)
            TabPatient().preferredColorScheme(.dark)
        }
    }
}
