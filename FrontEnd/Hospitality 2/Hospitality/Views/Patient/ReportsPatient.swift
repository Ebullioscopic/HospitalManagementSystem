import SwiftUI
import Combine

struct LabRecord: Identifiable, Codable {
    let id: Int
    let lab: Int
    let labName: String
    let scheduledTime: Date
    let testResult: [String: TestResultValue]?
    let testType: Int
    let testTypeName: String
    let priority: String
    let appointment: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case id = "lab_test_id"
        case lab
        case labName = "lab_name"
        case scheduledTime = "test_datetime"
        case testResult = "test_result"
        case testType = "test_type"
        case testTypeName = "test_type_name"
        case priority
        case appointment
        case status
    }
}

enum TestResultValue: Codable {
    case number(Double)
    case text(String)
    case object([String: TestResultValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .text(string)
        } else if let object = try? container.decode([String: TestResultValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.typeMismatch(
                TestResultValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown type in TestResultValue")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let num):
            try container.encode(num)
        case .text(let str):
            try container.encode(str)
        case .object(let dict):
            try container.encode(dict)
        }
    }
}

class LabRecordService {
    static let shared = LabRecordService()
    private let baseURL = Constants.baseURL
    
    func fetchUpcomingLabRecords(completion: @escaping (Result<[LabRecord], DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/general/patient/recommended-lab-tests/") ??
                URL(string: "http://ec2-13-127-223-203.ap-south-1.compute.amazonaws.com/api/hospital/general/patient/recommended-lab-tests/")
        else {
            completion(.failure(.invalidURL))
            return
        }
        
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken") ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownError))
                return
            }
            
            if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode([LabRecord].self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

class LabRecordsViewModel: ObservableObject {
    @Published var records: [LabRecord] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchLabRecords() {
        isLoading = true
        LabRecordService.shared.fetchUpcomingLabRecords { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let records):
                    self?.records = records
                case .failure(let error):
                    print("Failed to fetch lab records: \(error)")
                    self?.records = []
                }
            }
        }
    }
}

struct ReportsContent: View {
    @State private var isNavigating = false
    @State private var isPresented = false
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: String = "Recommended"
    @StateObject private var viewModel = LabRecordsViewModel()
    @State private var opacity: Double = 0.0
    @State private var searchText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var iconScale: CGFloat = 0.8
    @State private var isDateFilterActive: Bool = false
    @State private var selectedRecord: LabRecord?
    @StateObject private var doctorViewModel = DoctorViewModel()

    private var filteredRecords: [LabRecord] {
        viewModel.records.filter { record in
            let matchesSegment: Bool
            switch selectedFilter {
            case "Recommended": matchesSegment = record.status.lowercased() == "recommended"
            case "Completed": matchesSegment = record.status.lowercased() == "completed"
            case "Paid": matchesSegment = record.status.lowercased() == "paid"
            default: matchesSegment = true
            }
            let matchesSearch = searchText.isEmpty || record.testTypeName.lowercased().contains(searchText.lowercased())
            let matchesDate = !isDateFilterActive || Calendar.current.isDate(record.scheduledTime, inSameDayAs: selectedDate)
            return matchesSegment && matchesSearch && matchesDate
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()


            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Lab Records")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            Text("View your scheduled and completed lab tests")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)

                    Picker("Report Type", selection: $selectedFilter) {
                        Text("Recommended").tag("Recommended")
                        Text("Completed").tag("Completed")
                        Text("Paid").tag("Paid")
                    }
                    .pickerStyle(.segmented)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 16).fill(colorScheme == .dark ? Color(hex: "1E293B") : Color.white).shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal)

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search tests...", text: $searchText).foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .dark ? Color(hex: "1E2533") : .white).shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5))
                    .padding(.horizontal)

                    LazyVStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView().padding(.vertical, 20).frame(maxWidth: .infinity)
                        } else if filteredRecords.isEmpty {
                            Text("No \(selectedFilter.lowercased()) lab records found")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredRecords) { record in
                                LabRecordCard(record: record, onTap: { selectedRecord = record }).padding(.horizontal)
                            }
                        }
                    }.padding(.vertical)
                }.padding(.vertical)
            }
            .opacity(opacity)
            .onAppear {
                viewModel.fetchLabRecords()
                withAnimation(.easeInOut(duration: 0.8)) { opacity = 1.0 }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) { iconScale = 1.0 }
            }

            if let record = selectedRecord {
                LabRecordDetailOverlay(
                    record: record,
                    isPresented: Binding(
                        get: { selectedRecord != nil },
                        set: { if !$0 { selectedRecord = nil }}
                    ),
                    doctorViewModel: doctorViewModel,
                    viewModel: viewModel
                )
            }
        }
    }
}

private struct LabRecordDetailOverlay: View {
    let record: LabRecord
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var doctorViewModel: DoctorViewModel
    @ObservedObject var viewModel: LabRecordsViewModel
    
    @State private var showPaymentSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Lab Record")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Test Type", value: record.testTypeName)
                        DetailRow(label: "Status", value: record.status.capitalized)
                        DetailRow(label: "Priority", value: record.priority.capitalized)
                        DetailRow(label: "Lab Name", value: record.labName)
                        DetailRow(label: "Scheduled", value: record.scheduledTime, format: .dateTime.day().month().year().hour().minute())

                        // Test Results
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Results")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))

                            if let resultMap = record.testResult, !resultMap.isEmpty {
                                ForEach(resultMap.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    HStack {
                                        Text(key.capitalized + ":")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))

                                        Spacer()

                                        switch value {
                                        case .number(let num):
                                            Text(String(format: "%.2f", num))
                                                .foregroundColor(.blue)
                                        case .text(let str):
                                            Text(str)
                                                .foregroundColor(.gray)
                                        case .object:
                                            Text("Complex Result")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                }
                            } else {
                                Text("Not Available")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 200)

                // Action Buttons
                VStack(spacing: 6) {
                    if record.status.lowercased() == "recommended" {
                        ActionButton(
                            title: "Pay for Test",
                            icon: "creditcard.fill",
                            color: .blue,
                            action: {
                                showPaymentSheet = true
                            }
                        )
                    } else if record.status.lowercased() == "completed" {
                        ActionButton(
                            title: "Download PDF",
                            icon: "arrow.down.doc.fill",
                            color: .blue,
                            action: {
                                generateAndSharePDF()
                            }
                        )
                    }

                    // Close button
                    ActionButton(
                        title: "Close",
                        icon: "xmark",
                        color: .gray,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                    )
                }

                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(colorScheme == .dark ? Color(hex: "1A202C") : Color.white.opacity(0.95))
            }
            .frame(maxWidth: 300, maxHeight: 350)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 12)
            .transition(.scale.combined(with: .opacity))
        }
        .sheet(isPresented: $showPaymentSheet) {
            PaymentGatewayView(
                labTestId: record.id, 
                onPaymentCompleted: {
                    isPresented = false
                    viewModel.fetchLabRecords()
                }
            )
        }
    }

    private func generateAndSharePDF() {
        PDFGenerator.createLabRecordPDF(from: record, using: doctorViewModel) { pdfData in
            guard let data = pdfData else {
                print("Failed to generate PDF.")
                return
            }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("LabTest-\(record.id).pdf")

            do {
                try data.write(to: tempURL)
                sharePDF(at: tempURL)
            } catch {
                print("Failed to write PDF: \(error.localizedDescription)")
            }
        }
    }

    private func sharePDF(at url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: - Helper Components

    private struct ActionButton: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(colorScheme == .dark ? 0.2 : 0.1))
                )
                .foregroundColor(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    private struct DetailRow<Value>: View {
        let label: String
        let value: Value
        let format: Date.FormatStyle?

        init(label: String, value: Value, format: Date.FormatStyle? = nil) {
            self.label = label
            self.value = value
            self.format = format
        }

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            HStack(alignment: .top) {
                Text(label + ":")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                    .frame(width: 80, alignment: .leading)

                Spacer()

                if let date = value as? Date, let fmt = format {
                    Text(date, format: fmt)
                } else {
                    Text(String(describing: value))
                }
            }
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
        }
    }
}



struct LabRecordCard: View {
    let record: LabRecord
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Icon on the left with a playful style
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.blue.opacity(0.2) : Color(hex: "A3BFFA").opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? Color.blue.opacity(0.4) : Color(hex: "A3BFFA"), lineWidth: 2)
                        )
                    
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(colorScheme == .dark ? Color(hex: "E0E7FF") : Color(hex: "4A90E2"))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                
                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    // Test name (larger and prominent)
                    Text(record.testTypeName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "E0E7FF") : Color(hex: "2D3748"))
                        .lineLimit(1)
                    
                    // Lab name (smaller, below test name)
                    Text(record.labName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(hex: "718096"))
                        .lineLimit(1)
                    
                    // Date and time
                    Text(record.scheduledTime, format: .dateTime.day().month().hour().minute())
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(hex: "718096"))
                }
                
                Spacer()
                
                // Status label on the right
                Text(record.status.capitalized)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        record.status.lowercased() == "recommended" ?
                        Color(hex: "A3BFFA").opacity(0.2) :
                        (record.status.lowercased() == "completed" ? Color(hex: "6EE7B7").opacity(0.2) : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(
                        colorScheme == .dark ?
                        (record.status.lowercased() == "recommended" ? Color(hex: "A3BFFA") : Color(hex: "6EE7B7")) :
                        (record.status.lowercased() == "recommended" ? Color(hex: "4A90E2") : Color(hex: "2ECC71"))
                    )
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(hex: "1E2533") : Color.white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.1), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Color(hex: "A3BFFA").opacity(0.2) : Color(hex: "E0E7FF").opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct ReportsContent_Previews: PreviewProvider {
    static var previews: some View {
        ReportsContent()
            .preferredColorScheme(.light)
        ReportsContent()
            .preferredColorScheme(.dark)
    }
}
