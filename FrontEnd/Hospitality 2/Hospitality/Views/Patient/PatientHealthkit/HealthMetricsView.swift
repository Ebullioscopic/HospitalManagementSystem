import SwiftUI
import HealthKit

struct HealthMetricsView: View {
    @StateObject private var viewModel = HealthMetricsViewModel()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading health data...")
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header Stats
                            headerStatsView
                            
                            // Heart Rate Section
                            heartRateSection
                            
                            // SpO2 Section
                            spO2Section
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Health Metrics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshData) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .onAppear {
                viewModel.requestAuthorization { success in
                    if !success {
                        showingPermissionAlert = true
                    }
                }
            }
            .alert("Health Permissions Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings", role: .cancel) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .destructive) {}
            } message: {
                Text("Please enable Health permissions in Settings to view your health metrics.")
            }
        }
    }
    
    // MARK: - Header Stats View
    private var headerStatsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Average Heart Rate
                MetricCardView(
                    title: "Heart Rate",
                    value: viewModel.averageHeartRate != nil ? "\(String(format: "%.0f", viewModel.averageHeartRate!))" : "–",
                    unit: "BPM",
                    iconName: "heart.fill",
                    color: .red,
                    trend: viewModel.heartRateTrend
                )
                
                // Average SpO2
                MetricCardView(
                    title: "Blood Oxygen",
                    value: viewModel.averageSpO2 != nil ? "\(String(format: "%.0f", viewModel.averageSpO2!))" : "–",
                    unit: "%",
                    iconName: "lungs.fill",
                    color: .blue,
                    trend: viewModel.spO2Trend
                )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Heart Rate Section
    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Heart Rate Events")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 5)
            
            VStack(spacing: 12) {
                // High Heart Rate Events
                EventsCardView(
                    title: "High Heart Rate",
                    description: "Events over 120 BPM",
                    samples: viewModel.highHeartRateSamples,
                    noDataMessage: "No high heart rate events detected",
                    valueFormatter: { sample in
                        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        return String(format: "%.0f", bpm)
                    },
                    valueColor: .red,
                    valueUnit: "BPM",
                    iconName: "arrow.up.heart.fill"
                )
                
                // Low Heart Rate Events
                EventsCardView(
                    title: "Low Heart Rate",
                    description: "Events under 50 BPM",
                    samples: viewModel.lowHeartRateSamples,
                    noDataMessage: "No low heart rate events detected",
                    valueFormatter: { sample in
                        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        return String(format: "%.0f", bpm)
                    },
                    valueColor: .blue,
                    valueUnit: "BPM",
                    iconName: "arrow.down.heart.fill"
                )
            }
        }
    }
    
    // MARK: - SpO2 Section
    private var spO2Section: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Blood Oxygen Events")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 5)
            
            // Low SpO2 Events
            EventsCardView(
                title: "Low Blood Oxygen",
                description: "Events under 95%",
                samples: viewModel.lowSpO2Samples,
                noDataMessage: "No low SpO₂ events detected",
                valueFormatter: { sample in
                    let percent = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
                    return String(format: "%.0f", percent)
                },
                valueColor: .orange,
                valueUnit: "%",
                iconName: "lungs.fill"
            )
        }
    }
}

// MARK: - Metric Card View
struct MetricCardView: View {
    let title: String
    let value: String
    let unit: String
    let iconName: String
    let color: Color
    let trend: Double?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 2) {
                            Image(systemName: trend > 0 ? "arrow.up" : "arrow.down")
                                .font(.caption)
                                .foregroundColor(trend > 0 ? .red : .green)
                            
                            Text("\(abs(trend), specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(height: 100)
    }
}

// MARK: - Events Card View
struct EventsCardView: View {
    let title: String
    let description: String
    let samples: [HKQuantitySample]
    let noDataMessage: String
    let valueFormatter: (HKQuantitySample) -> String
    let valueColor: Color
    let valueUnit: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(valueColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(samples.count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(valueColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.separator).opacity(0.5))
                .padding(.horizontal, 16)
            
            if samples.isEmpty {
                HStack {
                    Spacer()
                    Text(noDataMessage)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(samples.prefix(5), id: \.uuid) { sample in
                        eventRow(sample: sample)
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func eventRow(sample: HKQuantitySample) -> some View {
        HStack {
            Text(valueFormatter(sample))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(valueColor)
            
            Text(valueUnit)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(formatDate(sample.startDate))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - ViewModel
class HealthMetricsViewModel: ObservableObject {
    @Published var averageHeartRate: Double?
    @Published var averageSpO2: Double?
    @Published var highHeartRateSamples: [HKQuantitySample] = []
    @Published var lowHeartRateSamples: [HKQuantitySample] = []
    @Published var lowSpO2Samples: [HKQuantitySample] = []
    @Published var isLoading = true
    @Published var heartRateTrend: Double? = 1.2 // Mock data, would calculate from historical data
    @Published var spO2Trend: Double? = -0.3 // Mock data, would calculate from historical data
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        HealthKitManager.shared.requestAuthorization { [weak self] success in
            if success {
                self?.loadData()
            }
            completion(success)
        }
    }
    
    func loadData() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let group = DispatchGroup()
        
        var avgHR: Double?
        var highHR: [HKQuantitySample] = []
        var lowHR: [HKQuantitySample] = []
        var avgSpO2: Double?
        var lowSpO2: [HKQuantitySample] = []
        
        group.enter()
        HealthKitManager.shared.fetchAverageHeartRate { avg in
            avgHR = avg
            group.leave()
        }
        
        group.enter()
        HealthKitManager.shared.fetchHighHeartRateEvents { samples in
            highHR = samples.sorted(by: { $0.startDate > $1.startDate })
            group.leave()
        }
        
        group.enter()
        HealthKitManager.shared.fetchLowHeartRateEvents { samples in
            lowHR = samples.sorted(by: { $0.startDate > $1.startDate })
            group.leave()
        }
        
        group.enter()
        HealthKitManager.shared.fetchAverageSpO2 { avg in
            avgSpO2 = avg
            group.leave()
        }
        
        group.enter()
        HealthKitManager.shared.fetchLowSpO2Events { samples in
            lowSpO2 = samples.sorted(by: { $0.startDate > $1.startDate })
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.averageHeartRate = avgHR
            self.highHeartRateSamples = highHR
            self.lowHeartRateSamples = lowHR
            self.averageSpO2 = avgSpO2
            self.lowSpO2Samples = lowSpO2
            self.isLoading = false
        }
    }
    
    func refreshData() {
        loadData()
    }
}

// MARK: - Preview
struct HealthMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthMetricsView()
    }
}






