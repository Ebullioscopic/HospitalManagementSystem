import SwiftUI

struct ShiftsView: View {
    let shifts: [DoctorResponse.PatientDoctorSlotResponse]
    @State private var selectedFilter: ShiftFilter = .booked
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddSchedule = false
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
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
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy • HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: currentDate)
    }
    
    // Group shifts by date for the available view
    var groupedAvailableShifts: [String: [DoctorResponse.PatientDoctorSlotResponse]] {
        Dictionary(grouping: shifts.filter { !$0.is_booked }) { shift in
            let date = formatDate(shift.slot_start_time)
            return date
        }
    }
    
    // Get upcoming dates from available shifts
    var availableDates: [String] {
        let dates = Array(groupedAvailableShifts.keys).sorted { date1, date2 in
            if let d1 = formatStringToDate(date1), let d2 = formatStringToDate(date2) {
                return d1 < d2
            }
            return date1 < date2
        }
        return dates
    }
    
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
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats Dashboard
                        statsDashboard
                        
                        // Filter Section with Segmented Control
                        filterSection
                        
                        // Shifts Content - Different UI based on filter
                        if selectedFilter == .booked {
                            bookedShiftsSection
                        } else {
                            availableShiftsSection
                        }
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
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Shifts")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Today's Overview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: { showAddSchedule = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(
            colorScheme == .dark ?
                Color(hex: "1A1A1A") :
                Color.white
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Stats Dashboard
    private var statsDashboard: some View {
        HStack(spacing: 12) {
            // Booked Stats
            StatsTile(
                count: bookedCount,
                title: "Booked",
                icon: "calendar.badge.clock",
                color: .blue
            )
            
            // Available Stats
            StatsTile(
                count: availableCount,
                title: "Available",
                icon: "calendar",
                color: .green
            )
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter Shifts")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            Picker("Filter", selection: $selectedFilter) {
                Text("Booked").tag(ShiftFilter.booked)
                Text("Available").tag(ShiftFilter.available)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color(hex: "242424") : Color(hex: "EAEAEC"))
            )
        }
    }
    
    // MARK: - Booked Shifts Section
    private var bookedShiftsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Booked Shifts")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(filteredShifts.count) total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color(hex: "242424") : Color(hex: "EAEAEC"))
                    )
            }
            
            if filteredShifts.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.clock",
                    title: "No Booked Shifts",
                    message: "You don't have any booked shifts at the moment."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredShifts, id: \.slot_id) { shift in
                        BookedShiftCard(shift: shift)
                    }
                }
            }
        }
    }
    
    // MARK: - Available Shifts Section (Redesigned)
    private var availableShiftsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Available Shifts")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(filteredShifts.count) total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color(hex: "242424") : Color(hex: "EAEAEC"))
                    )
            }
            
            if filteredShifts.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Available Shifts",
                    message: "There are no available shifts at the moment."
                )
            } else {
                // Display available shifts grouped by date
                ForEach(availableDates, id: \.self) { date in
                    availableDateSection(date: date, shifts: groupedAvailableShifts[date] ?? [])
                }
            }
        }
    }
    
    private func availableDateSection(date: String, shifts: [DoctorResponse.PatientDoctorSlotResponse]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDateHeader(date))
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 10)
                .padding(.bottom, 2)
            
            VStack(spacing: 6) {
                ForEach(shifts.sorted { formatTimeOnly($0.slot_start_time) < formatTimeOnly($1.slot_start_time) }, id: \.slot_id) { shift in
                    AvailableShiftRow(shift: shift)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(hex: "1E1E1E") : Color(hex: "F5F5F5"))
                    .opacity(0.5)
            )
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

// Redesigned Stats Tile
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
                        .fill(color.opacity(0.15))
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
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "242424") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// Booked Shift Card
struct BookedShiftCard: View {
    let shift: DoctorResponse.PatientDoctorSlotResponse
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Time indicator & icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formatTime(shift.slot_start_time))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                
                Text("Slot #\(shift.slot_id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status badge
            Text("Booked")
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.15))
                )
                .foregroundColor(.blue)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "242424") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Available Shift Row component (streamlined)
struct AvailableShiftRow: View {
    let shift: DoctorResponse.PatientDoctorSlotResponse
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            // Time with indicator
            HStack(spacing: 8) {
                Text(formatTimeOnly(shift.slot_start_time))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 20)
                    .cornerRadius(1.5)
            }
            .frame(width: 70, alignment: .leading)
            
            // Slot ID
            Text("Slot #\(shift.slot_id)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Status dot indicator
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            
            Text("Available")
                .font(.footnote)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(hex: "242424") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func formatTimeOnly(_ timeString: String) -> String {
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
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
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
                .fill(colorScheme == .dark ? Color(hex: "242424") : .white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}
