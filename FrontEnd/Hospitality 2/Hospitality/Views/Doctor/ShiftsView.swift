import SwiftUI

struct ShiftsView: View {
    let shifts: [DoctorResponse.PatientDoctorSlotResponse]
    @State private var selectedFilter: ShiftFilter = .booked
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddSchedule = false
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private let accentBlue = Color(hex: "0077CC")
    private let lightBlue = Color(hex: "E6F0FA")
    private let darkBlue = Color(hex: "005599")
    
    enum ShiftFilter {
        case booked, available
    }
    
    var filteredShifts: [DoctorResponse.PatientDoctorSlotResponse] {
        switch selectedFilter {
        case .booked: return shifts.filter { $0.is_booked }
        case .available: return shifts.filter { !$0.is_booked }
        }
    }
    
    var bookedCount: Int { shifts.filter { $0.is_booked }.count }
    var availableCount: Int { shifts.filter { !$0.is_booked }.count }
    
    // Group shifts by date for both views
    var groupedShifts: [String: [DoctorResponse.PatientDoctorSlotResponse]] {
        Dictionary(grouping: filteredShifts) { shift in
            let date = formatDate(shift.slot_start_time)
            return date
        }
    }
    
    // Get dates from shifts
    var shiftDates: [String] {
        let dates = Array(groupedShifts.keys).sorted { date1, date2 in
            if let d1 = formatStringToDate(date1), let d2 = formatStringToDate(date2) {
                return d1 < d2
            }
            return date1 < date2
        }
        return dates
    }
    
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
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats Dashboard
                        statsDashboard
                        
                        // Filter Section with Segmented Control
                        filterSection
                        
                        // Shifts Content - Unified UI
                        shiftsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
        .sheet(isPresented: $showAddSchedule) {
            NavigationView {
                DocAddScheduleView()
            }
        }
        .tint(accentBlue)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Shifts")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : darkBlue)
                    
                    Text("Today's Overview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: { showAddSchedule = true }) {
                    ZStack {
                        Circle()
                            .fill(accentBlue.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(accentBlue)
                    }
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
    
    // MARK: - Stats Dashboard
    private var statsDashboard: some View {
        HStack(spacing: 12) {
            // Booked Stats
            StatsTile(
                count: bookedCount,
                title: "Booked",
                icon: "calendar.badge.clock",
                color: accentBlue
            )
            
            // Available Stats
            StatsTile(
                count: availableCount,
                title: "Available",
                icon: "calendar",
                color: darkBlue
            )
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter Shifts")
                .font(.subheadline)
                .foregroundColor(accentBlue)
                .padding(.leading, 4)
            
            Picker("Filter", selection: $selectedFilter) {
                Text("Booked").tag(ShiftFilter.booked)
                Text("Available").tag(ShiftFilter.available)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(accentBlue)
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(lightBlue.opacity(0.9))
            )
            .shadow(color: accentBlue.opacity(0.2), radius: 3)
        }
    }
    
    // MARK: - Unified Shifts Section
    private var shiftsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text(selectedFilter == .booked ? "Booked Shifts" : "Available Shifts")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkBlue)
                
                Spacer()
                
                Text("\(filteredShifts.count) total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(lightBlue.opacity(0.9))
                    )
                    .shadow(color: accentBlue.opacity(0.2), radius: 2)
            }
            
            if filteredShifts.isEmpty {
                EmptyStateView(
                    icon: selectedFilter == .booked ? "calendar.badge.clock" : "calendar",
                    title: "No \(selectedFilter == .booked ? "Booked" : "Available") Shifts",
                    message: "You don't have any \(selectedFilter == .booked ? "booked" : "available") shifts at the moment."
                )
            } else {
                // Display shifts grouped by date
                ForEach(shiftDates, id: \.self) { date in
                    shiftDateSection(date: date, shifts: groupedShifts[date] ?? [])
                }
            }
        }
    }
    
    private func shiftDateSection(date: String, shifts: [DoctorResponse.PatientDoctorSlotResponse]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDateHeader(date))
                .font(.headline)
                .foregroundColor(darkBlue)
                .padding(.top, 10)
                .padding(.bottom, 2)
            
            VStack(spacing: 8) {
                ForEach(shifts.sorted { formatTimeOnly($0.slot_start_time) < formatTimeOnly($1.slot_start_time) }, id: \.slot_id) { shift in
                    ShiftCard(shift: shift, accentBlue: accentBlue, darkBlue: darkBlue)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    // Helper functions for date formatting
    private func formatDate(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDateHeader(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func formatTimeOnly(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

// Shared Stats Tile
struct StatsTile: View {
    let count: Int
    let title: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "0A1B2F") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// Unified Shift Card
struct ShiftCard: View {
    let shift: DoctorResponse.PatientDoctorSlotResponse
    let accentBlue: Color
    let darkBlue: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Time column with vertical line indicator
            HStack(spacing: 8) {
                Text(formatTime(shift.slot_start_time))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(darkBlue)
                
                Rectangle()
                    .fill(shift.is_booked ? accentBlue : darkBlue)
                    .frame(width: 3, height: 24)
                    .cornerRadius(1.5)
            }
            .frame(width: 80, alignment: .leading)
            
            // Slot ID
            Text("Slot #\(shift.slot_id)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Status badge
            Text(shift.is_booked ? "Booked" : "Available")
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(shift.is_booked ? accentBlue.opacity(0.2) : darkBlue.opacity(0.2))
                )
                .foregroundColor(shift.is_booked ? accentBlue : darkBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(hex: "0A1B2F") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(shift.is_booked ? accentBlue.opacity(0.2) : darkBlue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: accentBlue.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    @Environment(\.colorScheme) var colorScheme
    
    private let accentBlue = Color(hex: "0077CC")
    private let lightBlue = Color(hex: "E6F0FA")

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accentBlue.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(accentBlue)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(accentBlue)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "0A1B2F") : lightBlue.opacity(0.9))
        )
        .shadow(color: accentBlue.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}
