import Foundation
import Combine

// http://api.urbandictionary.com/v0/define?term=flump
private let randomTermURL = URL(string: "https://api.urbandictionary.com/v0/random")!

class UrbanDictionary {
    struct Term: Codable {
        struct Definition: Codable, Comparable {
            var word: String
            var example: String
            var definition: String
            var thumbs_up: Int
            static func < (lhs: Definition, rhs: Definition) -> Bool { lhs.thumbs_up < rhs.thumbs_up }
        }
        var list: [Definition]
        var topDefinition: Definition { list.sorted().last! }
    }
    
    private lazy var randomWordPublisher = URLSession.shared
        .dataTaskPublisher(for: randomTermURL)
        .map { $0.data }
        .decode(type: UrbanDictionary.Term.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
    
    func fetchRandomWord(completion: @escaping (Result<Term, Error>) -> Void) {
        randomWordPublisher
            .sink { c in
                switch c {
                case .finished: break
                case .failure(let error): completion(.failure(error))
                }
            } receiveValue: { term in
                completion(.success(term))
            }
            .store(in: &observers)
    }
    
    private var observers = Set<AnyCancellable>()
}
