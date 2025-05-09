import SwiftUI

// MARK: - AppointmentsViewModel
class AppointmentsViewModel: ObservableObject {
    @Published var appointments: [DoctorResponse.DocAppointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortBy: AppointmentSortOrder = .dateDescending
    
    private let doctorServices = DoctorServices()
    
    func loadAppointments() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedAppointments = try await doctorServices.fetchDoctorAppointmentHistory()
                
                // Create a new array with updated appointment status based on date
                let updatedAppointments = fetchedAppointments.map { appointment -> DoctorResponse.DocAppointment in
                    var updatedStatus = appointment.status
                    
                    if appointment.status.lowercased() == "scheduled" {
                        let isBeforeToday = self.isBeforeToday(appointment.date)
                        if isBeforeToday {
                            updatedStatus = "Completed"
                        } else {
                            updatedStatus = "Upcoming"
                        }
                    }
                    
                    return DoctorResponse.DocAppointment(
                        appointmentId: appointment.appointmentId,
                        date: appointment.date,
                        slotId: appointment.slotId,
                        staffId: appointment.staffId,
                        patientId: appointment.patientId,
                        status: updatedStatus
                    )
                }
                
                DispatchQueue.main.async {
                    self.appointments = updatedAppointments
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
            let fetchedAppointments = try await doctorServices.fetchDoctorAppointmentHistory()
            
            // Create a new array with updated appointment status based on date
            let updatedAppointments = fetchedAppointments.map { appointment -> DoctorResponse.DocAppointment in
                var updatedStatus = appointment.status
                
                if appointment.status.lowercased() == "scheduled" {
                    let isBeforeToday = self.isBeforeToday(appointment.date)
                    if isBeforeToday {
                        updatedStatus = "Completed"
                    } else {
                        updatedStatus = "Upcoming"
                    }
                }
                
                return DoctorResponse.DocAppointment(
                    appointmentId: appointment.appointmentId,
                    date: appointment.date,
                    slotId: appointment.slotId,
                    staffId: appointment.staffId,
                    patientId: appointment.patientId,
                    status: updatedStatus
                )
            }
            
            DispatchQueue.main.async {
                self.appointments = updatedAppointments
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
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

struct DoctorAppointmentsView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var searchText = ""
    @State private var selectedAppointment: DoctorResponse.DocAppointment? = nil
    @State private var appointmentToReschedule: DoctorResponse.DocAppointment? = nil
    @State private var showRescheduleView = false
    @State private var showDetailView = false
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
                                    Button(action: {
                                        selectedAppointment = appointment
                                        showDetailView = true
                                    }) {
                                        AppointmentRow(appointment: appointment)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
            .sheet(isPresented: $showDetailView) {
                if let appointment = selectedAppointment {
                    AppointmentDetailView(appointment: appointment)
                }
            }
        }
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
    
    var filteredAppointments: [DoctorResponse.DocAppointment] {
        var filtered = viewModel.appointments
        
        // Filter by appointment status
        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            filtered = filtered.filter { appointment in
                appointment.status.lowercased() == "upcoming" ||
                (appointment.status.lowercased() == "scheduled" && !isBeforeToday(appointment.date))
            }
        case .completed:
            filtered = filtered.filter { appointment in
                appointment.status.lowercased() == "completed" ||
                (appointment.status.lowercased() == "scheduled" && isBeforeToday(appointment.date))
            }
        case .cancelled:
            filtered = filtered.filter { appointment in
                appointment.status.lowercased() == "cancelled"
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { appointment in
                let appointmentIdMatch = String(appointment.appointmentId).contains(searchText)
                let dateMatch = appointment.date.contains(searchText)
                let staffIdMatch = appointment.staffId.contains(searchText)
                let statusMatch = appointment.status.lowercased().contains(searchText.lowercased())
                
                return appointmentIdMatch || dateMatch || staffIdMatch || statusMatch
            }
        }
        
        // Apply sorting
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
                let order1 = statusSortOrder(appt1.status)
                let order2 = statusSortOrder(appt2.status)
                return order1 < order2
            }
        }
        
        return filtered
    }
    
    private func statusSortOrder(_ status: String) -> Int {
        switch status.lowercased() {
        case "upcoming", "scheduled":
            if status.lowercased() == "scheduled" {
                return 0
            } else {
                return 1
            }
        case "completed":
            return 2
        case "cancelled":
            return 3
        default:
            return 4
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

// MARK: - AppointmentFilter
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

// MARK: - AppointmentRow
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
    @State private var slotStartTime: String = "Loading..."
    @State private var isSlotLoading: Bool = false
    @State private var staffName: String = "Loading..."
    @State private var isStaffNameLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(staffName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("\(formatDate(appointment.date)) • \(slotStartTime)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: appointment.status)
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
                    Text("Appointment #\(appointment.appointmentId)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "calendar")
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
        .onAppear {
            loadSlotTime()
            loadStaffName()
        }
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
    
    private func loadSlotTime() {
        guard !isSlotLoading else { return }
        
        isSlotLoading = true
        
        Task {
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let appointmentDate = dateFormatter.date(from: String(appointment.date.prefix(10))) else {
                    throw NetworkError.unknownError
                }
                
                let dateString = dateFormatter.string(from: appointmentDate)
                let slots = try await DoctorServices().fetchDoctorSlots(doctorId: appointment.staffId, date: dateString)
                
                if let slot = slots.first(where: { $0.slot_id == appointment.slotId }) {
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    if let timeDate = timeFormatter.date(from: slot.slot_start_time) {
                        timeFormatter.dateFormat = "HH:mm"
                        DispatchQueue.main.async {
                            slotStartTime = timeFormatter.string(from: timeDate)
                            isSlotLoading = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            slotStartTime = "N/A"
                            isSlotLoading = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        slotStartTime = "N/A"
                        isSlotLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    slotStartTime = "N/A"
                    isSlotLoading = false
                }
            }
        }
    }
    
    private func loadStaffName() {
        guard !isStaffNameLoading else { return }
        
        isStaffNameLoading = true
        
        Task {
            do {
                guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(appointment.staffId)/") else {
                    throw NetworkError.invalidURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                
                let doctor = try JSONDecoder().decode(PatientSpecificDoctorResponse.self, from: data)
                
                DispatchQueue.main.async {
                    staffName = doctor.staff_name
                    isStaffNameLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    staffName = "Unknown Doctor"
                    isStaffNameLoading = false
                }
            }
        }
    }
}
// MARK: - StatusBadge
struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(getDisplayStatus())
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
    
    private func getDisplayStatus() -> String {
        switch status.lowercased() {
        case "cancelled":
            return "Cancelled"
        case "completed":
            return "Completed"
        case "upcoming":
            return "Upcoming"
        case "scheduled":
            return "Scheduled"
        case "confirmed":
            return "Confirmed"
        case "pending":
            return "Pending"
        default:
            return status.capitalized
        }
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

// MARK: - AppointmentSortOrder
enum AppointmentSortOrder {
    case dateAscending
    case dateDescending
    case statusOrder
}
