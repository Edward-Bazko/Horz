import Foundation

struct Quote {
    var text: String
    var tag: String
}

class QuotesStore {
    var englishFiles = [("MaxPayneQuotes", "txt")]
    var russianFiles = [("Chap", "txt")]
    
    private lazy var englishQuotes = parse(englishFiles)
    private lazy var russianQuotes = parse(russianFiles)
    
    private func parse(_ files: [(String, String)]) -> [Quote] {
        var quotes: [Quote] = []
        for file in files {
            let fileURL = bundle.url(forResource: file.0, withExtension: file.1)!
            guard let string = try? String(contentsOf: fileURL) else {
                continue
            }
            string.split(separator: "\n").forEach { q in
                quotes.append(Quote(text: String(q), tag: file.0))
            }
        }
        return quotes
    }
    
    func randomEnglishQuote() -> Quote {
        englishQuotes.randomElement() ?? defaultEnglishQuote
    }
    
    func randomRussianQuote() -> Quote {
        russianQuotes.randomElement() ?? defaultRussianQuote
    }
    
    private let bundle = Bundle.main
    
    private let defaultEnglishQuote = Quote(text: "Simple things should be simple. Complex things should be possible.", tag: "")
    
    private let defaultRussianQuote = Quote(text: "А сегодня в завтрашний день не все могут смотреть. Вернее смотреть могут не только лишь все, мало кто может это делать", tag: "")
}
