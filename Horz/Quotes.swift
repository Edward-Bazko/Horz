import Foundation

struct Quote {
    var text: String
    var tag: String
}

class QuotesStore {
    var quotesFileInEnglish = [("MaxPayneQuotes", "txt")]
    private lazy var englishQuotes = tryParse()
    
    private func tryParse() -> [Quote] {
        do { return try parse() }
        catch {
            print("Failed to parse quotes with error: \(error)")
            return []
        }
    }
    
    private func parse() throws -> [Quote] {
        var quotes: [Quote] = []
        for file in quotesFileInEnglish {
            let fileURL = bundle.url(forResource: file.0, withExtension: file.1)!
            let string = try String(contentsOf: fileURL)
            string.split(separator: "\n").forEach { q in
                quotes.append(Quote(text: String(q), tag: file.0))
            }
        }
        print("Quotes count: \(quotes.count)")
        return quotes
    }
    
    func randomEnglishQuote() -> Quote {
        englishQuotes.randomElement() ?? defaultEnglishQuote
    }
    
    func randomRussianQuote() -> Quote {
        return Quote(text: "", tag: "")
    }
    
    private let bundle = Bundle.main
    private let defaultEnglishQuote = Quote(text: "Simple things should be simple. Complex things should be possible.", tag: "")
}
