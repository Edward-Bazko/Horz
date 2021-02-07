import SwiftUI
import Foundation

struct SessionsView: View {
    @ObservedObject var model: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            if !model.notificationPermissionsGranted {
                noPermissionsView
            }
            else if model.isLoading {
                ProgressView("Loading Sessions")
            }
            else {
                List {
                    ForEach(model.schedule.sessions, id:\.self) { session in
                        SessionListRow(session: session)
                    }
                }
                .navigationBarItems(leading: Button("Refresh", action: { model.refresh() }))
                .navigationBarTitle("Sessions")
            }
        }
    }
    
    var noPermissionsView: some View {
        VStack {
            Text("The notification permission was not authorized. Please enable it in Settings to continue")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Open Settings", action: { model.openSystemSettings() })
                .padding()
        }
        .padding()
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
        SessionsView(model: ScheduleViewModel())
    }
}
