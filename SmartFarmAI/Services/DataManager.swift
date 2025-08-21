import Foundation

final class DataManager {
    static let shared = DataManager()
    private init() {}

    func loadMockJSON<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}


