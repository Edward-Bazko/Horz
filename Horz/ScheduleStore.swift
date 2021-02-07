import Foundation

class ScheduleStore {
    
    var fileName = "schedule.json"
    
    func save(_ schedule: Schedule) throws {
        let data = try encoder.encode(schedule)
        try data.write(to: fileURL)
    }
    
    func load() throws -> Schedule {
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Schedule.self, from: data)
    }
    
    func isEmpty() -> Bool {
        !fileManager.fileExists(atPath: fileURL.path)
    }
    
    func remove() {
        try? fileManager.removeItem(at: fileURL)
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
    
    private lazy var fileManager = FileManager.default
    private lazy var documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    private lazy var fileURL = documentDirectory.appendingPathComponent(fileName)
}
