//
//  NotificationManager.swift
//  Hospitality
//
//  Created by admin29 on 09/05/25.
//


//
//  NotificationManager.swift
//  Hospitality
//
//  Created by hariharan on 08/05/25.
//


import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications authorized")
            } else {
                print("❌ Notifications not authorized")
            }
        }
    }
    
    func scheduleNotification(appointmentDate: Date, appointmentTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "\(appointmentTitle) is scheduled in 24 hours."
        content.sound = .default

        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointmentDate) else {
            return
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(triggerDate)")
            }
        }
    }
    
    func sendBookingConfirmationNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Appointment Booked"
            content.body = "Your appointment has been successfully booked."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // sends after 1 sec
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Notification error: \(error.localizedDescription)")
                } else {
                    print("✅ Appointment booked notification scheduled")
                }
            }
        }
}
