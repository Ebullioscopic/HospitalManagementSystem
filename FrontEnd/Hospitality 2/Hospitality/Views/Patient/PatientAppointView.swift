import SwiftUI

struct DoctorAppointmentsView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var searchText = ""
    @State private var selectedAppointment: DoctorResponse.DocAppointment? = nil
    @State private var appointmentToReschedule: DoctorResponse.DocAppointment? = nil
    @State private var showRescheduleView = false
    @State private var opacity: Double = 0.0
    @State private var iconScale: CGFloat = 0.8
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                                FilterPill1(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedFilter = filter
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search appointments", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading appointments...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                            .foregroundColor(.primary)
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Error loading appointments")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Text(errorMessage)
                                .font(.system(size: 16, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                viewModel.loadAppointments()
                            }) {
                                Text("Try Again")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        Spacer()
                    } else if filteredAppointments.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Appointments")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            if !searchText.isEmpty || selectedFilter != .all {
                                Text("Try adjusting your filters or search terms")
                                    .font(.system(size: 16, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    searchText = ""
                                    selectedFilter = .all
                                }) {
                                    Text("Clear Filters")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Text("You don't have any scheduled appointments at the moment.")
                                    .font(.system(size: 16, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        Spacer()
                    } else {
                        // Appointment counts and stats
                        HStack {
                            Text("\(filteredAppointments.count) appointment\(filteredAppointments.count != 1 ? "s" : "")")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    viewModel.sortBy = .dateAscending
                                }) {
                                    Label("Oldest First", systemImage: "arrow.up")
                                }
                                Button(action: {
                                    viewModel.sortBy = .dateDescending
                                }) {
                                    Label("Newest First", systemImage: "arrow.down")
                                }
                                Button(action: {
                                    viewModel.sortBy = .statusOrder
                                }) {
                                    Label("By Status", systemImage: "tag")
                                }
                            } label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAppointments) { appointment in
                                    AppointmentRow(appointment: appointment)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedAppointment = appointment
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                        .refreshable {
                            await viewModel.refreshAppointments()
                        }
                    }
                }
            }
            .navigationTitle("My Appointments")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.loadAppointments()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        Menu("Filter") {
                            ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                                Button(action: {
                                    selectedFilter = filter
                                }) {
                                    Label(filter.title, systemImage: filter.iconName)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            searchText = ""
                            selectedFilter = .all
                        }) {
                            Label("Clear Filters", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1.0
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                    iconScale = 1.0
                }
                viewModel.loadAppointments()
            }
        }
        .overlay(
            ZStack {
                if let appointment = selectedAppointment {
                    let appointmentData = AppointmentData(
                        doctorName: "Dr. Staff ID: \(appointment.staffId)",
                        specialty: "Primary Care",
                        date: appointment.date,
                        time: "Slot \(appointment.slotId)",
                        notes: ""
                    )
                    
                    AppointmentDetailOverlay(
                        appointment: appointmentData,
                        onManageAppointment: {
                            if !isBeforeToday(appointment.date) && appointment.status.lowercased() != "cancelled" {
                                self.appointmentToReschedule = appointment
                                withAnimation {
                                    selectedAppointment = nil
                                    showRescheduleView = true
                                }
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                selectedAppointment = nil
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }
        )
        .sheet(isPresented: $showRescheduleView) {
            if let appointment = appointmentToReschedule {
                AppointmentRescheduleView(
                    appointmentId: appointment.appointmentId,
                    doctorId: appointment.staffId,
                    currentDate: appointment.date,
                    currentSlotId: appointment.slotId,
                    reason: "",
                    onRescheduleComplete: {
                        showRescheduleView = false
                        viewModel.loadAppointments()
                    }
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGroupedBackground)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var filteredAppointments: [DoctorResponse.DocAppointment] {
        var filtered = viewModel.appointments
        
        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            filtered = filtered.filter { appointment in
                !isBeforeToday(appointment.date) && appointment.status.lowercased() != "cancelled"
            }
        case .completed:
            filtered = filtered.filter { appointment in
                isBeforeToday(appointment.date) && appointment.status.lowercased() != "cancelled"
            }
        case .cancelled:
            filtered = filtered.filter { appointment in
                appointment.status.lowercased() == "cancelled"
            }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { appointment in
                let appointmentIdMatch = String(appointment.appointmentId).contains(searchText)
                let dateMatch = appointment.date.contains(searchText)
                let staffIdMatch = appointment.staffId.contains(searchText)
                let statusMatch = getDisplayStatus(appointment).lowercased().contains(searchText.lowercased())
                
                return appointmentIdMatch || dateMatch || staffIdMatch || statusMatch
            }
        }
        
        switch viewModel.sortBy {
        case .dateAscending:
            filtered.sort { appt1, appt2 in
                return appt1.date < appt2.date
            }
        case .dateDescending:
            filtered.sort { appt1, appt2 in
                return appt1.date > appt2.date
            }
        case .statusOrder:
            filtered.sort { appt1, appt2 in
                let order1 = statusSortOrder(getDisplayStatus(appt1))
                let order2 = statusSortOrder(getDisplayStatus(appt2))
                return order1 < order2
            }
        }
        
        return filtered
    }
    
    private func statusSortOrder(_ status: String) -> Int {
        switch status.lowercased() {
        case "upcoming": return 0
        case "completed": return 1
        case "cancelled": return 2
        default: return 3
        }
    }
    
    private func getDisplayStatus(_ appointment: DoctorResponse.DocAppointment) -> String {
        if appointment.status.lowercased() == "cancelled" {
            return "Cancelled"
        }
        
        if isBeforeToday(appointment.date) {
            return "Completed"
        } else {
            return "Upcoming"
        }
    }
    
    private func isBeforeToday(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let appointmentDate = dateFormatter.date(from: dateString) else {
            return false
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return appointmentDate < today
    }
}

enum AppointmentFilter: String, CaseIterable {
    case all
    case upcoming
    case completed
    case cancelled
    
    var title: String {
        switch self {
        case .all: return "All"
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "list.bullet"
        case .upcoming: return "calendar"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
}

enum AppointmentSortOrder {
    case dateAscending
    case dateDescending
    case statusOrder
}

struct FilterPill1: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppointmentRow: View {
    let appointment: DoctorResponse.DocAppointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appointment #\(appointment.appointmentId)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("\(formatDate(appointment.date)) • Slot \(appointment.slotId)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: displayStatus)
            }
            
            Divider()
            
            HStack {
                Label {
                    Text("Staff ID: \(appointment.staffId)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "person.crop.rectangle")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Label {
                    Text("Patient #\(appointment.patientId)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "person")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var displayStatus: String {
        if appointment.status.lowercased() == "cancelled" {
            return "Cancelled"
        }
        
        if isBeforeToday(appointment.date) {
            return "Completed"
        } else {
            return "Upcoming"
        }
    }
    
    private func isBeforeToday(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let appointmentDate = dateFormatter.date(from: dateString) else {
            return false
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return appointmentDate < today
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "completed":
            return Color.green
        case "upcoming", "scheduled", "confirmed":
            return Color.blue
        case "cancelled":
            return Color.red
        case "pending":
            return Color.orange
        default:
            return Color.gray
        }
    }
}



class AppointmentsViewModel: ObservableObject {
    @Published var appointments: [DoctorResponse.DocAppointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortBy: AppointmentSortOrder = .dateDescending
    
    func loadAppointments() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedAppointments = try await DoctorServices().fetchDoctorAppointmentHistory()
                DispatchQueue.main.async {
                    self.appointments = fetchedAppointments
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshAppointments() async {
        do {
            let fetchedAppointments = try await DoctorServices().fetchDoctorAppointmentHistory()
            DispatchQueue.main.async {
                self.appointments = fetchedAppointments
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
