import Foundation
import Combine

// http://api.urbandictionary.com/v0/define?term=flump
private let randomTermURL = URL(string: "https://api.urbandictionary.com/v0/random")!

typealias UrbanDictionaryDefinition = UrbanDictionary.Term.Definition

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
    
    private func randomWordPublisher() -> AnyPublisher<UrbanDictionaryDefinition, Error> {
        URLSession.shared
            .dataTaskPublisher(for: randomTermURL)
            .map(\.data)
            .decode(type: UrbanDictionary.Term.self, decoder: JSONDecoder())
            .map(\.topDefinition)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchRandomWord(completion: @escaping (Result<UrbanDictionaryDefinition, Error>) -> Void) {
        randomWordPublisher()
            .sink { c in
                switch c {
                case .finished: break
                case .failure(let error): completion(.failure(error))
                }
            } receiveValue: { definition in
                completion(.success(definition))
            }
            .store(in: &observers)
    }
    
    func fetchManyRandomWords(count: Int, completion: @escaping ([UrbanDictionaryDefinition]) -> Void) {
        let words = randomWordPublisher()
            .catch { error in
                Just(UrbanDictionaryDefinition(word: "Error", example: error.localizedDescription, definition: "", thumbs_up: 0))
            }
        
        (1...count).publisher
            .flatMap { _ in words }
            .collect()
            .sink { completion($0) }
            .store(in: &observers)
    }
    
    private var observers = Set<AnyCancellable>()
}
