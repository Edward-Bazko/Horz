import Foundation
import UserNotifications

class Notifications {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let calendar = Calendar.autoupdatingCurrent
    private let quotes = QuotesStore()
    private let ud = UrbanDictionary()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async { completion(true) }
                return
            }
            
            guard let self = self else { return }
            self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, error in
                DispatchQueue.main.async { completion(isGranted) }
            }
        }
    }
    
    func schedule(_ window: Schedule.Window) {
        scheduleStartSession(date: window.begin)
        scheduleFinishSession(date: window.end)
    }
    
    func resetScheduledSessions() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    private func scheduleStartSession(date: Date) {
        ud.fetchRandomWord { [weak self] result in
            guard let self = self else { return }
            let term = try? result.get()
            
            let body = self.removeBrackets(term?.definition ?? self.quotes.randomEnglishQuote().text)
            let example = self.removeBrackets(term?.example ?? "")
            
            self.schedule(message: term?.word ?? "Yo! Let's speak some English 🇬🇧💂🏻",
                          body: body + " :: " + example,
                          date: date)
        }
    }
    
    private func removeBrackets(_ string: String) -> String {
        string
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\\r", with: "")
            .replacingOccurrences(of: "\\n", with: "")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\'", with: "'")
    }
    
    private func scheduleFinishSession(date: Date) {
        schedule(message: "Чокаво! Поговорим по-русски 🪆☦️",
                 body: quotes.randomRussianQuote().text,
                 date: date)
    }
        
    private func schedule(message: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = message
        content.body = body
        content.sound = .default
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add notification with error: \(error)")
            }
            else {
                // print("Notification scheduled: \(request)")
            }
        }
    }
    
    func printPendingRequests() {
        notificationCenter.getPendingNotificationRequests { requests in
            print(requests)
        }
    }
}



