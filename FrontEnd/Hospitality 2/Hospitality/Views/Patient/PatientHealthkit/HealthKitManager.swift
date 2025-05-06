import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private var readTypes: Set<HKObjectType> {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let spo2Type = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        return [heartRateType, spo2Type]
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            completion(success)
        }
    }

    func fetchAverageHeartRate(completion: @escaping (Double?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, _ in
            guard let result = result,
                  let avg = result.averageQuantity() else {
                completion(nil)
                return
            }
            let bpm = avg.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            completion(bpm)
        }
        healthStore.execute(query)
    }

    func fetchHighHeartRateEvents(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let highHeartRate = HKQuantity(unit: heartRateUnit, doubleValue: 120.0)
        let predicate = HKQuery.predicateForQuantitySamples(with: .greaterThanOrEqualTo, quantity: highHeartRate)
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            completion(samples)
        }
        healthStore.execute(query)
    }
    
    func fetchLowHeartRateEvents(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let lowHeartRate = HKQuantity(unit: heartRateUnit, doubleValue: 50.0)
        let predicate = HKQuery.predicateForQuantitySamples(with: .lessThanOrEqualTo, quantity: lowHeartRate)
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            completion(samples)
        }
        healthStore.execute(query)
    }


    func fetchAverageSpO2(completion: @escaping (Double?) -> Void) {
        guard let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: spo2Type,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, _ in
            guard let result = result,
                  let avg = result.averageQuantity() else {
                completion(nil)
                return
            }
            let percent = avg.doubleValue(for: HKUnit.percent()) * 100
            completion(percent)
        }
        healthStore.execute(query)
    }

    func fetchLowSpO2Events(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
        let spo2Unit = HKUnit.percent()
        let lowSpO2 = HKQuantity(unit: spo2Unit, doubleValue: 0.95)
        let predicate = HKQuery.predicateForQuantitySamples(with: .lessThanOrEqualTo, quantity: lowSpO2)
        
        let query = HKSampleQuery(
            sampleType: spo2Type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            completion(samples)
        }
        healthStore.execute(query)
    }
}

