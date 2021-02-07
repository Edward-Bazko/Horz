import Foundation
import Combine

class ScheduleFetcher {
    private let scheduleURL = URL(string: "http://82.161.151.207:8082/schedule")!
    
    private lazy var schedulePublisher = URLSession.shared
        .dataTaskPublisher(for: scheduleURL)
        .map { $0.data }
        .decode(type: Schedule.self, decoder: decoder)
        .receive(on: RunLoop.main)
    
    func fetchSchedule(completion: @escaping (Schedule) -> Void) {
        schedulePublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Received error: ", error)
                }
            }, receiveValue: { schedule in
                completion(schedule)
                print("Schedule: \(schedule)")
            })
            .store(in: &observers)
    }
    
    private var observers = Set<AnyCancellable>()

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
