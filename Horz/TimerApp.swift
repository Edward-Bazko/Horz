import SwiftUI

@main
struct HorzApp: App {
    
    var body: some Scene {
        WindowGroup {
            SessionsView(model: ScheduleViewModel())
        }
    }
}
