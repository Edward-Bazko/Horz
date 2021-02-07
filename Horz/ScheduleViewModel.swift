import Foundation
import Combine
import SwiftUI

struct Schedule: Codable, Hashable {
    struct Window: Codable, Hashable {
        var begin: Date
        var end: Date
    }
    var sessions: [Window]
}

extension Schedule.Window {
    var isActive: Bool { (begin...end).contains(Date()) }
}

class ScheduleViewModel: ObservableObject {
    private let store = ScheduleStore()
    private let fetcher = ScheduleFetcher()
    private let notifications = Notifications()
    
    @Published var isSessionRunning = false
    @Published var isLoading = false
    @Published var notificationPermissionsGranted = false
    
    @Published var schedule = Schedule(sessions: []) {
        didSet {
            notifications.resetScheduledSessions()
            for session in schedule.sessions {
                notifications.schedule(session)
                if session.isActive {
                    isSessionRunning = true
                }
            }
        }
    }
    
    init() {
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [unowned self] _ in verifyAuthorization() }
            .store(in: &observers)
    }
    
    func verifyAuthorization() {
        notifications.requestAuthorization { [weak self] isGranted in
            guard let self = self else { return }
            self.notificationPermissionsGranted = isGranted
            if isGranted {
                self.loadSchedule()
            }
        }
    }
    
    private func loadSchedule() {
        if store.isEmpty() {
            fetch()
        }
        else if let schedule = try? store.load() {
            self.schedule = schedule
        }
    }
    
    func refresh() {
        schedule = Schedule(sessions: [])
        store.remove()
        fetch()
    }
    
    func openSystemSettings() {
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsURL)
    }
    
    private func fetch() {
        isLoading = true
        fetcher.fetchSchedule { [unowned self] schedule in
            try? store.save(schedule)
            self.schedule = schedule
            isLoading = false
        }
    }
    
    private var observers = Set<AnyCancellable>()
}
