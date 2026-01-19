import Foundation

class WordManager {
    static let shared = WordManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func getWord(for difficulty: Difficulty, language: Language) -> BibleTerm? {
        let filename = difficulty.filename + language.suffix
        guard let allWords = loadJSON(filename: filename), !allWords.isEmpty else {
            return nil
        }
        
        let historyKey = "history_\(difficulty.rawValue)_\(language.rawValue)"
        var history = userDefaults.array(forKey: historyKey) as? [Int] ?? []
        
        var available = allWords.filter { !history.contains($0.id) }
        
        if available.isEmpty {
            history.removeAll()
            userDefaults.removeObject(forKey: historyKey)
            available = allWords
        }
        
        guard let selectedWord = available.randomElement() else { return nil }
        
        history.append(selectedWord.id)
        userDefaults.set(history, forKey: historyKey)
        
        return selectedWord
    }
    
    private func loadJSON(filename: String) -> [BibleTerm]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Error: Could not find \(filename).json in bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([BibleTerm].self, from: data)
            return words
        } catch {
            print("Error decoding \(filename).json: \(error)")
            return nil
        }
    }
}
