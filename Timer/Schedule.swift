import Foundation
import Combine

let scheduleURL = URL(string: "http://82.161.151.207:8082/schedule")!

let sample = """
{
  "sessions": [
    {
      "begin": "2021-01-31T19:55:00Z",
      "end": "2021-01-31T21:10:00Z"
    }
  ]
}
"""


struct ScheduleResponse: Decodable, Hashable {
    struct Window: Decodable, Hashable {
        var begin: Date
        var end: Date
    }
    var sessions: [Window]
}

class ScheduleRequest {
    
    static var shared = ScheduleRequest()
    let notifications = Notifications()
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    lazy var schedulePublisher = URLSession.shared.dataTaskPublisher(for: scheduleURL)
        .map { $0.data }
        .decode(type: ScheduleResponse.self, decoder: decoder)
    
    lazy var samplePublisher = Just(sample.data(using: .utf8)!)
                                        .decode(type: ScheduleResponse.self, decoder: decoder)
    
    func requestSchedule() {
        notifications.requestAuthorization()
        
        schedulePublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("received error: ", error)
                }
            }, receiveValue: { [weak self] schedule in
                print("Schedule: \(schedule)")
                self?.setupNotifications(schedule)
            })
            .store(in: &observers)
    }
    
    private func setupNotifications(_ response: ScheduleResponse) {
        response.sessions.forEach { window in
            notifications.scheduleStartSession(date: window.begin)
            notifications.scheduleFinishSession(date: window.end)
        }
    }
    
    private var observers = Set<AnyCancellable>()
}
