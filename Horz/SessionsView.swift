import SwiftUI
import Foundation

struct SessionsView: View {
    @ObservedObject var model: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            switch model.state {
            
            case .loaded(let schedule):
                scheduleView(schedule)

            case .notificationPermissionsNotDetermined:
                ZStack { }
                
            case .notificationPermissionsDenied:
                noPermissionsView()
                
            case .isLoading:
                ProgressView("Loading Sessions")

            case .loadingFailed(let error):
                errorView(error)
            }
        }
    }
    
    private func scheduleView(_ schedule: Schedule) -> some View {
        List {
            ForEach(schedule.sessions, id:\.self) { session in
                SessionListRow(session: session)
            }
        }
        .navigationBarItems(leading: Button("Refresh", action: { model.refresh() }))
        .navigationBarTitle("Sessions")
        .transition(.opacity)
    }
    
    private func noPermissionsView() -> some View {
        VStack {
            Text("The notification permission was not authorized. Please enable it in Settings to continue")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Open Settings", action: { model.openSystemSettings() })
                .padding()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(30)
        .padding()
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack {
            Text("Something went wrong")
                .multilineTextAlignment(.center)
                .padding()
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button("Refresh", action: { model.refresh() })
                .padding()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(30)
    }
}

private struct SessionListRow: View {
    var session: Schedule.Window
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(begin)")
            Text("\(end)")
        }
        .listRowBackground(color(session))
    }
    
    func color(_ session: Schedule.Window) -> Color {
        session.isActive ? Color(.green).opacity(0.5) : Color(.systemBackground)
    }
    
    var begin: String {
        DateFormatter.localizedString(from: session.begin, dateStyle: .medium, timeStyle: .short)
    }
    
    var end: String {
        DateFormatter.localizedString(from: session.end, dateStyle: .medium, timeStyle: .short)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {            
            SessionsView(model: MockedSchedule())
        }
    }
}

class MockedSchedule: ScheduleViewModel {
    
    struct MockedFetcher: ScheduleFetching {
        var schedule: Schedule
        func fetchSchedule(completion: @escaping (Result<Schedule, Error>) -> Void) {
            completion(.success(schedule))
        }
    }
    
    init() {
        let schedule = Schedule(sessions: [Schedule.Window(begin: Date(), end: Date())])
        super.init(fetcher: MockedFetcher(schedule: schedule))
        self.state = .loaded(schedule)
    }
}
