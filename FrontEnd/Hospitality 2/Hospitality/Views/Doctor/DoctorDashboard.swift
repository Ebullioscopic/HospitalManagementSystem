import SwiftUI

struct DoctorDashboardView: View {
    @StateObject private var viewModel = DoctorViewModel()
    @State private var selectedTab = 0
    @State private var showProfileDetail = false // Added to control profile navigation
    @Environment(\.colorScheme) var colorScheme
    let doctorId: String

    var body: some View {
        ZStack {
            // Background gradient
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
                // Appointments Tab (includes profile)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header with Profile Button
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome Back")
                                    .font(.title)
                                    .fontWeight(.bold)

                                Text("Manage your appointments")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Profile Button
                            Button(action: {
                                showProfileDetail = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $showProfileDetail) {
                                DoctorProfileView()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        // Today's Appointments
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)

                            Text("Appointment Overview")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal)

                        // Appointments Content
                        contentView(for: 0)
                            .padding(.horizontal)

                        Divider()
                            .padding(.vertical, 10)

                        // Profile Section - Keeping this as it was in the original
                        VStack(alignment: .leading, spacing: 8) {
                           // DocProfile()
                               
                        }
                        .padding(.bottom)
                    }
                }
                .tag(0)
                .tabItem {
                    Label("Appointments", systemImage: "list.bullet.clipboard")
                }

                // Shifts Tab
                VStack(spacing: 0) {
                  
                    // Shifts Content
                    contentView(for: 1)
                        .padding(.top, 8)
                }
                .tag(1)
                .tabItem {
                    Label("Shifts", systemImage: "calendar")
                }
            }
            .accentColor(.blue)
        }
        .onAppear {
            viewModel.fetchDoctorShifts(doctorId: doctorId)
            viewModel.fetchDoctorAppointments()

            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }

    @ViewBuilder
    private func contentView(for tab: Int) -> some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
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

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: retryAction) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding()
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
