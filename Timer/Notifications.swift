import Foundation
import UserNotifications

class Notifications {
        
    let notificationCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    let calendar = Calendar.autoupdatingCurrent
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: options) { isGranted, error in
            print("Granted: \(isGranted) Error: \(error.debugDescription)")
        }
    }
    
    func scheduleStartSession(date: Date) {
        schedule(message: "Yo! Let's speak some English 🇬🇧💂🏻", date: date)
    }
    
    func scheduleFinishSession(date: Date) {
        schedule(message: "Sup! Поговорим по-русски 🪆☦️", date: date)
    }
    
    private func schedule(message: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = message
        content.body = "Motivation quote goes here ;)"
        content.sound = .default
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send request with error: \(error)")
                return
            }
            else {
                print("Notification scheduled")
            }
        }
    }
}

