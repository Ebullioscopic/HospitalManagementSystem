import SwiftUI

struct DoctorDashboardView: View {
    @StateObject private var viewModel = DoctorViewModel()
    @State private var selectedTab = 0
    @State private var showProfileDetail = false
    @State private var iconScale: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme
    let doctorId: String
    
    private let accentBlue = Color(hex: "0077CC")
    private let lightBlue = Color(hex: "E6F0FA")
    private let darkBlue = Color(hex: "005599")

    var body: some View {
        ZStack {
            // Background gradient with blue tones
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "0A1B2F") : lightBlue,
                    colorScheme == .dark ? Color(hex: "14243D") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Appointments Tab
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            contentView(for: 0)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .tag(0)
                .tabItem {
                    Label("Appointments", systemImage: "list.bullet.clipboard")
                        .foregroundColor(accentBlue)
                }

                // Shifts Tab
                ShiftsView(shifts: viewModel.doctorShifts)
                    .tag(1)
                    .tabItem {
                        Label("Shifts", systemImage: "calendar")
                            .foregroundColor(accentBlue)
                    }
            }
            .accentColor(accentBlue)
            .tint(accentBlue)
        }
        .onAppear {
            viewModel.fetchDoctorShifts(doctorId: doctorId)
            viewModel.fetchDoctorAppointments()

            // Set tab bar appearance with blue theme
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colorScheme == .dark ? UIColor(Color(hex: "0A1B2F")) : UIColor(lightBlue)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(accentBlue)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(accentBlue)]
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : darkBlue)
                    
                    Text("Manage your appointments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    showProfileDetail = true
                }) {
                    ZStack {
                        Circle()
                            .fill(accentBlue.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(accentBlue)
                    }
                }
                .sheet(isPresented: $showProfileDetail) {
                    DoctorProfileView()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(
            colorScheme == .dark ?
                Color(hex: "0A1B2F").opacity(0.9) :
                lightBlue.opacity(0.9)
        )
        .shadow(color: accentBlue.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Content View
    @ViewBuilder
    private func contentView(for tab: Int) -> some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accentBlue))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            DocErrorView(message: errorMessage, retryAction: {
                viewModel.fetchDoctorShifts(doctorId: doctorId)
                viewModel.fetchDoctorAppointments()
            })
        } else {
            switch tab {
            case 0:
                AppointmentsListView()
            case 1:
                ShiftsView(shifts: viewModel.doctorShifts)
            default:
                EmptyView()
            }
        }
    }
}

// Error view
struct DocErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    private let accentBlue = Color(hex: "0077CC")
    private let lightBlue = Color(hex: "E6F0FA")

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(accentBlue)

            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(accentBlue)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: retryAction) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accentBlue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(lightBlue.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: accentBlue.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// Preview
struct DoctorDashboardView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            DoctorDashboardView(doctorId: "DOC735A4911")
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            DoctorDashboardView(doctorId: "DOC735A4911")
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
