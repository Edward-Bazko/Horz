import Foundation
import Combine

protocol ScheduleFetching {
    func fetchSchedule(completion: @escaping (Result<Schedule, Error>) -> Void)
}

class ScheduleFetcher: ScheduleFetching {
    private let scheduleURL = URL(string: "http://82.161.151.207:8082/schedule")!
    
    private lazy var schedulePublisher = URLSession.shared
        .dataTaskPublisher(for: scheduleURL)
        .map { $0.data }
        .decode(type: Schedule.self, decoder: decoder)
        .receive(on: RunLoop.main)
    
    func fetchSchedule(completion: @escaping (Result<Schedule, Error>) -> Void) {
        schedulePublisher
            .sink(receiveCompletion: { c in
                switch c {
                case .finished:
                    break
                case .failure(let error):
                    print("Received error: ", error)
                    completion(.failure(error))
                }
            }, receiveValue: { schedule in
                print("Schedule: \(schedule)")
                completion(.success(schedule))
            })
            .store(in: &observers)
    }
    
    private var observers = Set<AnyCancellable>()

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // 2016-07-04T17:37:21
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let candidate = try container.decode(String.self)
            if let date = formatter.date(from: candidate) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date :\(candidate)")
        }
        return decoder
    }
}
