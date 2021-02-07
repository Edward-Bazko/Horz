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
    private let notifications = Notifications()
    private let fetcher: ScheduleFetching
    
    enum State {
        case loaded(Schedule)
        case isLoading
        case loadingFailed(Error)
        case notificationPermissionsNotDetermined
        case notificationPermissionsDenied
    }
    
    @Published var isSessionRunning = false
    
    @Published var state = State.notificationPermissionsNotDetermined {
        didSet {
            if case .loaded(let schedule) = state {
                try? store.save(schedule)
                scheduleNotifications(schedule)
            }
        }
    }
    
    private func scheduleNotifications(_ schedule: Schedule) {
        notifications.resetScheduledSessions()
        for session in schedule.sessions {
            notifications.schedule(session)
            if session.isActive {
                isSessionRunning = true
            }
        }
    }
    
    init(fetcher: ScheduleFetching = ScheduleFetcher()) {
        self.fetcher = fetcher
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [unowned self] _ in verifyAuthorization() }
            .store(in: &observers)
    }
    
    func verifyAuthorization() {
        notifications.requestAuthorization { [weak self] isGranted in
            guard let self = self else { return }
            if isGranted {
                self.loadSchedule()
            }
            else {
                self.state = .notificationPermissionsDenied
            }
        }
    }
    
    private func loadSchedule() {
        if store.isEmpty() {
            fetch()
            return
        }
        
        do {
            state = .loaded(try store.load())
        }
        catch {
            state = .loadingFailed(error)
        }
    }
    
    func refresh() {
        store.remove()
        fetch()
    }
    
    func openSystemSettings() {
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsURL)
    }
    
    private func fetch() {
        state = .isLoading
        fetcher.fetchSchedule { [unowned self] result in
            switch result {
            case .failure(let error):
                state = .loadingFailed(error)
            case .success(let schedule):
                state = .loaded(schedule)
            }
        }
    }
    
    private var observers = Set<AnyCancellable>()
}
