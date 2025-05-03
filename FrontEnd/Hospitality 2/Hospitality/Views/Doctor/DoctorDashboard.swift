import SwiftUI

struct DoctorDashboardView: View {
    @StateObject private var viewModel = DoctorViewModel()
    @State private var selectedTab = 0
    let doctorId: String

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                contentView(for: 0)
                    .navigationTitle("My Shifts")
            }
            .tabItem {
                Label("Shifts", systemImage: "calendar")
            }
            .tag(0)
            
            NavigationView {
                contentView(for: 1)
                    .navigationTitle("Appointments")
            }
            .tabItem {
                Label("Appointments", systemImage: "list.bullet.clipboard")
            }
            .tag(1)
            
            NavigationView {
                DocProfile()
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            .tag(2)
        }
        .onAppear {
            viewModel.fetchDoctorShifts(doctorId: doctorId)
            viewModel.fetchDoctorAppointments()
        }
    }

    @ViewBuilder
    private func contentView(for tab: Int) -> some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            DocErrorView(message: errorMessage) {
                viewModel.fetchDoctorShifts(doctorId: doctorId)
                viewModel.fetchDoctorAppointments()
            }
        } else {
            switch tab {
            case 0:
                ShiftsListView(shifts: viewModel.doctorShifts)
            case 1:
                AppointmentsListView(appointments: viewModel.doctorAppointments)
            default:
                EmptyView()
            }
        }
    }
}

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
    }
}

struct ShiftsListView: View {
    let shifts: [DoctorResponse.PatientDoctorSlotResponse]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if shifts.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        title: "No Shifts Available",
                        message: "You don't have any shifts scheduled at this time."
                    )
                } else {
                    ForEach(shifts, id: \.slot_id) { shift in
                        ShiftCardView(shift: shift)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("My Shifts")
    }
}

struct ShiftCardView: View {
    let shift: DoctorResponse.PatientDoctorSlotResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(formatTime(shift.slot_start_time))
                    .font(.headline)
                Spacer()
                Text(shift.is_booked ? "Booked" : "Available")
                    .font(.subheadline)
                    .foregroundColor(shift.is_booked ? .blue : .green)
            }

            HStack(spacing: 12) {
                Label("Slot #\(shift.slot_id)", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(shift.is_booked ? Color.blue : Color.green)
                    .frame(width: 10, height: 10)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatTime(_ timeString: String) -> String {
        return timeString // You can format properly using `DateFormatter`
    }
}


struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}

struct DoctorProfileView: View {
    @State private var name = "Dr. Swati Swapna"
    @State private var specialty = "General Medicine"
    @State private var email = "swati@hospital.com"
    @State private var phone = "+1234567890"
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(specialty)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Contact information
                GroupBox(label: Label("Contact Information", systemImage: "envelope.fill").font(.headline)) {
                    ProfileDetailRow(icon: "envelope", label: "Email", value: email)
                    
                    ProfileDetailRow(icon: "phone", label: "Phone", value: phone)
                }
                
                // Settings
                GroupBox(label: Label("Settings", systemImage: "gearshape.fill").font(.headline)) {
                    NavigationLink(destination: Text("Working Hours Settings")) {
                        ProfileSettingRow(icon: "clock", title: "Working Hours")
                    }
                    
                    NavigationLink(destination: Text("Availability Settings")) {
                        ProfileSettingRow(icon: "calendar", title: "Set Availability")
                    }
                    
                    NavigationLink(destination: Text("Notifications Settings")) {
                        ProfileSettingRow(icon: "bell", title: "Notifications")
                    }
                    
                    NavigationLink(destination: Text("Security Settings")) {
                        ProfileSettingRow(icon: "lock.shield", title: "Security & Privacy")
                    }
                }
                
                // Log out button
                Button(action: {
                    showingLogoutConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding(.trailing, 10)
                        Text("Log Out")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)
                .alert("Confirm Logout", isPresented: $showingLogoutConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Log Out", role: .destructive) {
                        // Handle logout
                    }
                } message: {
                    Text("Are you sure you want to log out?")
                }
            }
            .padding()
        }
        .navigationTitle("My Profile")
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
    }
}

struct ProfileSettingRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
struct DoctorDashboardView_pREVIEW: PreviewProvider {
    static var previews: some View {
        DoctorDashboardView(doctorId: "DOC735A4911")
    }
}
