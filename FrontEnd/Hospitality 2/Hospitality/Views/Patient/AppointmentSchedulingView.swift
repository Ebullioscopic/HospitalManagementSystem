import SwiftUI
import PDFKit



struct AppointmentSchedulingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    // State variables for appointment scheduling
    @State private var selectedDoctor: Doctor?
    @State private var confirmedDoctor: Doctor?
    @State private var selectedDate = Date()
    @State private var selectedTime = "09:00 AM"
    @State private var reason = ""
    @State private var showDoctorList = false
    @State private var isScheduling = false
    @State private var appointmentScheduled = false
    @State private var showAppointmentConfirmation = false
    @State private var searchText: String = ""
    @State private var showDatePicker = false
    @State private var showDoctorDetails = false
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    
    // Animation states
    @State private var opacity: Double = 0.0
    @State private var cardScale: CGFloat = 0.95
    
    // Available time slots
    private let timeSlots = [
        "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
        "11:00 AM", "11:30 AM", "12:00 PM", "01:30 PM",
        "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM",
        "04:00 PM", "04:30 PM"
    ]
    
    // Sample doctors
    private let doctors = [
        Doctor(name: "Dr. Sarah Johnson", email: "sarah.johnson@hospital.com", specialty: "Cardiologist", experience: "15 years", qualification: "MD from Harvard Medical School, Residency at Massachusetts General Hospital", image: "doctor1", availableDays: [1, 2, 4, 5]),
        Doctor(name: "Dr. Michael Chen", email: "michael.chen@hospital.com", specialty: "Dermatologist", experience: "12 years", qualification: "MD from Stanford University, Dermatology Residency at UCSF", image: "doctor2", availableDays: [1, 3, 5]),
        Doctor(name: "Dr. Emily Wilson", email: "emily.wilson@hospital.com", specialty: "Orthopedist", experience: "10 years", qualification: "MD from Johns Hopkins, Orthopedic Surgery Residency at Mayo Clinic", image: "doctor3", availableDays: [2, 3, 4, 5]),
        Doctor(name: "Dr. Robert Garcia", email: "robert.garcia@hospital.com", specialty: "Neurologist", experience: "18 years", qualification: "MD from Yale School of Medicine, Neurology Residency at Cleveland Clinic", image: "doctor4", availableDays: [1, 2, 3, 5]),
        Doctor(name: "Dr. Lisa Wong", email: "lisa.wong@hospital.com", specialty: "Pediatrician", experience: "14 years", qualification: "MD from University of Michigan, Pediatric Residency at Children's Hospital of Philadelphia", image: "doctor5", availableDays: [1, 2, 4, 5]),
        Doctor(name: "Dr. David Kim", email: "david.kim@hospital.com", specialty: "Ophthalmologist", experience: "11 years", qualification: "MD from Columbia University, Ophthalmology Residency at Wills Eye Hospital", image: "doctor6", availableDays: [2, 3, 4]),
        Doctor(name: "Dr. Jennifer Taylor", email: "jennifer.taylor@hospital.com", specialty: "General Practitioner", experience: "9 years", qualification: "MD from Duke University, Family Medicine Residency at University of Washington", image: "doctor7", availableDays: [1, 3, 5]),
        Doctor(name: "Dr. Thomas Martin", email: "thomas.martin@hospital.com", specialty: "Endocrinologist", experience: "16 years", qualification: "MD from Northwestern University, Endocrinology Fellowship at UCSF", image: "doctor8", availableDays: [2, 4, 5])
    ]
    
    // Filtered doctors based on search
    private var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return doctors
        } else {
            return doctors.filter { doctor in
                doctor.name.lowercased().contains(searchText.lowercased()) ||
                doctor.specialty.lowercased().contains(searchText.lowercased())
            }
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
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Schedule Appointment")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("Fill in the details to book your appointment")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic(style: .medium)
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    
                    // Step 1: Date Selection Button
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1: Select Date")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            .padding(.horizontal, 20)
                        
                        // Date button that shows date picker when tapped
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showDatePicker = true
                            }
                            triggerHaptic(style: .light)
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "4A90E2").opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "4A90E2"))
                                }
                                
                                Text(formattedDate)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "4A5568"))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Step 2: Find a Doctor (only show if no doctor is confirmed)
                    if confirmedDoctor == nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step 2: Find a Doctor")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                .padding(.horizontal, 20)
                            
                            // Doctor search field
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Search by doctor name or specialty", text: $searchText)
                                    .font(.system(size: 16))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 20)
                            
                            // Doctor list results
                            Text("\(filteredDoctors.count) doctor\(filteredDoctors.count != 1 ? "s" : "") available")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                .padding(.horizontal, 20)
                            
                            // Doctor grid with horizontal scrolling
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    if filteredDoctors.isEmpty {
                                        // No results message
                                        VStack(spacing: 10) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color.gray.opacity(0.6))
                                            
                                            Text("No doctors match your search")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color.gray.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: UIScreen.main.bounds.width - 80, height: 150)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                        )
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                    } else {
                                        // Group doctors in rows of 4
                                        LazyHGrid(rows: [
                                            GridItem(.fixed(130), spacing: 10),
                                            GridItem(.fixed(130), spacing: 10)
                                        ], spacing: 10) {
                                            ForEach(filteredDoctors) { doctor in
                                                doctorSquareCard(doctor: doctor)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Display confirmed doctor (if any)
                    if let doctor = confirmedDoctor {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selected Doctor")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                .padding(.horizontal, 20)
                            
                            // Confirmed doctor card
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "4A90E2").opacity(0.15))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: "4A90E2"))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(doctor.name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                                    
                                    Text(doctor.specialty)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                    
                                    Text("Tap to view profile or change doctor")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "4A90E2"))
                                        .padding(.top, 2)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Clear confirmed doctor to select another
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        confirmedDoctor = nil
                                        searchText = "" // Reset search
                                    }
                                    triggerHaptic(style: .medium)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color.gray)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDoctor = doctor
                                    showDoctorDetails = true
                                }
                                triggerHaptic(style: .light)
                            }
                        }
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        // Step 3: Select Time (only show if doctor is confirmed)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step 3: Select Time")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                .padding(.horizontal, 20)
                            
                            timeSelectionView
                        }
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        // Step 4: Reason for visit (only show if doctor is confirmed)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step 4: Reason for Visit")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                .padding(.horizontal, 20)
                            
                            TextEditor(text: $reason)
                                .padding(12)
                                .frame(minHeight: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                                )
                                .overlay(
                                    Text(reason.isEmpty ? "Please describe your symptoms or reason for appointment (optional)" : "")
                                        .foregroundColor(Color.gray.opacity(0.7))
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12),
                                    alignment: .topLeading
                                )
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        // Schedule Button (only show if doctor is confirmed)
                        Button(action: {
                            triggerHaptic()
                            scheduleAppointment()
                        }) {
                            ZStack {
                                if isScheduling {
                                    // Loading state
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "4A90E2"),
                                                    Color(hex: "5E5CE6")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.2)
                                        )
                                        .frame(height: 54)
                                } else {
                                    // Normal state
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "4A90E2"),
                                                    Color(hex: "5E5CE6")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            HStack {
                                                Text("Schedule Appointment")
                                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                
                                                Image(systemName: "calendar.badge.checkmark")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                            }
                                        )
                                        .frame(height: 54)
                                }
                            }
                            .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        .disabled(isScheduling)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical, 10)
            }
            .opacity(opacity)
            .scaleEffect(cardScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4)) {
                    opacity = 1.0
                    cardScale = 1.0
                }
            }
            
            // Date Picker Overlay
            if showDatePicker {
                datePickerOverlay
            }
            
            // Doctor Details Overlay
            if showDoctorDetails, let doctor = selectedDoctor {
                doctorDetailsOverlay(doctor: doctor)
            }
            
            // Appointment confirmation overlay
            if showAppointmentConfirmation {
                appointmentConfirmationOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL = pdfURL {
                ActivityViewController(activityItems: [pdfURL])
            }
        }
    }
    
    // Doctor square card component
    private func doctorSquareCard(doctor: Doctor) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDoctor = doctor
                showDoctorDetails = true
            }
            triggerHaptic(style: .light)
        }) {
            VStack(alignment: .center, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(confirmedDoctor?.id == doctor.id ? Color(hex: "4A90E2") : Color(hex: "4A90E2").opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(confirmedDoctor?.id == doctor.id ? .white : Color(hex: "4A90E2"))
                }
                
                Text(doctor.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(doctor.specialty)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                    .lineLimit(1)
            }
            .frame(width: 85, height: 120)
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(confirmedDoctor?.id == doctor.id ? Color(hex: "4A90E2") : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // Doctor details overlay
    private func doctorDetailsOverlay(doctor: Doctor) -> some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showDoctorDetails = false
                    }
                }
            
            // Doctor details card
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with doctor info
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(doctor.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text(doctor.specialty)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showDoctorDetails = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                    }
                    
                    // Doctor profile picture
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "4A90E2").opacity(0.15))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "4A90E2"))
                        }
                        
                        Spacer()
                    }
                    
                    // Email section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        
                        Text(doctor.email)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                    }
                    
                    // Experience section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Experience")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        
                        Text(doctor.experience)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                    }
                    
                    // Qualification section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Qualification")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        
                        Text(doctor.qualification)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Available days section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Days")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        
                        HStack(spacing: 8) {
                            ForEach(1...7, id: \.self) { day in
                                let isAvailable = doctor.availableDays.contains(day)
                                let dayName = getDayName(for: day)
                                
                                VStack {
                                    Text(dayName.prefix(1))
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(isAvailable ?
                                                        (colorScheme == .dark ? .white : Color(hex: "2D3748")) :
                                                        (colorScheme == .dark ? Color.white.opacity(0.4) : Color.gray))
                                    
                                    Circle()
                                        .fill(isAvailable ? Color(hex: "4A90E2") : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                                .frame(width: 20)
                            }
                        }
                    }
                    
                    // Confirm doctor button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            confirmedDoctor = doctor
                            showDoctorDetails = false
                        }
                        triggerHaptic(style: .medium)
                    }) {
                        Text("Confirm Doctor")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "4A90E2"),
                                                Color(hex: "5E5CE6")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: Color(hex: "4A90E2").opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "1A202C") : Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
    
    // Date picker overlay
    private var datePickerOverlay: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showDatePicker = false
                    }
                }
            
            // Date picker card
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Select Date")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showDatePicker = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                    }
                }
                .padding(.bottom, 8)
                
                // Date picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...(Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()),
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                .labelsHidden()
                
                // Confirm button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showDatePicker = false
                    }
                    triggerHaptic(style: .medium)
                }) {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "4A90E2"))
                        )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "1A202C") : Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .frame(maxWidth: 350)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
    
    // Time selection view with time slots
    private var timeSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(timeSlots, id: \.self) { time in
                    Button(action: {
                        selectedTime = time
                        triggerHaptic(style: .light)
                    }) {
                        Text(time)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedTime == time ? .white : (colorScheme == .dark ? .white : Color(hex: "2D3748")))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedTime == time ? Color(hex: "4A90E2") : (colorScheme == .dark ? Color(hex: "1E2533") : Color.white))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedTime == time ? Color(hex: "4A90E2") : (colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3)), lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
    }
    
    // Appointment confirmation overlay
    private var appointmentConfirmationOverlay: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Only allow closing after animation is complete
                    if appointmentScheduled {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showAppointmentConfirmation = false
                        }
                    }
                }
            
            // Confirmation card
            VStack(spacing: 20) {
                if appointmentScheduled {
                    // Success icon
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 20)
                    
                    Text("Appointment Scheduled!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                    
                    // Appointment details
                    VStack(alignment: .leading, spacing: 12) {
                        appointmentDetailRow(title: "Doctor", value: confirmedDoctor?.name ?? "")
                        appointmentDetailRow(title: "Specialty", value: confirmedDoctor?.specialty ?? "")
                        appointmentDetailRow(title: "Date", value: formattedDate)
                        appointmentDetailRow(title: "Time", value: selectedTime)
                        
                        if !reason.isEmpty {
                            Divider()
                                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
                            
                            Text("Reason for Visit:")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "718096"))
                            
                            Text(reason)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "2D3748"))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Share button
                    Button(action: {
                        generatePDF()
                        showShareSheet = true
                        triggerHaptic(style: .medium)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Share Appointment")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "4A90E2"))
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Done button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showAppointmentConfirmation = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "4A90E2"))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                } else {
                    // Loading state
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "4A90E2")))
                        .scaleEffect(1.5)
                        .padding(40)
                    
                    Text("Scheduling your appointment...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(hex: "4A5568"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "1A202C") : Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .frame(maxWidth: 320)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // Helper for appointment detail rows
    private func appointmentDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "718096"))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
            
            Spacer()
        }
    }
    
    // Helper for getting day name from number
    private func getDayName(for day: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[day - 1]
    }
    
    // Formatted date string
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    // Schedule appointment logic
    private func scheduleAppointment() {
        guard confirmedDoctor != nil else { return }
        
        isScheduling = true
        
        // Show confirmation overlay
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showAppointmentConfirmation = true
        }
        
        // Simulate scheduling delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                appointmentScheduled = true
                isScheduling = false
            }
        }
    }
    
    // Generate PDF from appointment details
    private func generatePDF() {
        guard let doctor = confirmedDoctor else { return }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Appointment Scheduler",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0 // US Letter size in points
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let attributesTitle = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            let attributesLabel = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.gray
            ]
            let attributesValue = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            var currentY: CGFloat = 40
            
            // Title
            let title = "Appointment Confirmation"
            title.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesTitle)
            currentY += 40
            
            // Doctor
            let doctorLabel = "Doctor:"
            doctorLabel.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesLabel)
            let doctorValue = doctor.name
            doctorValue.draw(at: CGPoint(x: 100, y: currentY), withAttributes: attributesValue)
            currentY += 30
            
            // Specialty
            let specialtyLabel = "Specialty:"
            specialtyLabel.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesLabel)
            let specialtyValue = doctor.specialty
            specialtyValue.draw(at: CGPoint(x: 100, y: currentY), withAttributes: attributesValue)
            currentY += 30
            
            // Date
            let dateLabel = "Date:"
            dateLabel.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesLabel)
            let dateValue = formattedDate
            dateValue.draw(at: CGPoint(x: 100, y: currentY), withAttributes: attributesValue)
            currentY += 30
            
            // Time
            let timeLabel = "Time:"
            timeLabel.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesLabel)
            let timeValue = selectedTime
            timeValue.draw(at: CGPoint(x: 100, y: currentY), withAttributes: attributesValue)
            currentY += 30
            
            // Reason for Visit
            if !reason.isEmpty {
                let reasonLabel = "Reason for Visit:"
                reasonLabel.draw(at: CGPoint(x: 20, y: currentY), withAttributes: attributesLabel)
                currentY += 20
                
                let reasonAttributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ]
                let reasonRect = CGRect(x: 20, y: currentY, width: pageWidth - 40, height: pageHeight - currentY - 20)
                reason.draw(in: reasonRect, withAttributes: reasonAttributes)
            }
        }
        
        // Save PDF to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Appointment_\(formattedDate.replacingOccurrences(of: ", ", with: "_")).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            pdfURL = fileURL
        } catch {
            print("Error saving PDF: \(error)")
        }
    }
    
    // Haptic feedback helper
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Doctor model
struct Doctor: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let specialty: String
    let experience: String
    let qualification: String
    let image: String
    let availableDays: [Int] // 1-7 for days of week (1 = Sunday)
}

// Activity View Controller for sharing
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AppointmentSchedulingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppointmentSchedulingView()
        }
        .preferredColorScheme(.light)
        
        NavigationStack {
            AppointmentSchedulingView()
        }
        .preferredColorScheme(.dark)
    }
}
