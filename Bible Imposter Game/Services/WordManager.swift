import Foundation

class WordManager {
    static let shared = WordManager()
    
    private var easyWords: [BibleTerm] = []
    private var mediumWords: [BibleTerm] = []
    private var hardWords: [BibleTerm] = []
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadWords()
    }
    
    private func loadWords() {
        easyWords = loadJSON(filename: "easy")
        mediumWords = loadJSON(filename: "medium")
        hardWords = loadJSON(filename: "hard")
    }
    
    private func loadJSON(filename: String) -> [BibleTerm] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Error: Could not find \(filename).json in bundle.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([BibleTerm].self, from: data)
            return words
        } catch {
            print("Error decoding \(filename).json: \(error)")
            return []
        }
    }
    
    func getWord(for difficulty: Difficulty) -> BibleTerm? {
        let allWords: [BibleTerm]
        let historyKey: String
        
        switch difficulty {
        case .easy:
            allWords = easyWords
            historyKey = "history_easy"
        case .medium:
            allWords = mediumWords
            historyKey = "history_medium"
        case .hard:
            allWords = hardWords
            historyKey = "history_hard"
        }
        
        guard !allWords.isEmpty else { return nil }
        
        // Load history
        var history = userDefaults.array(forKey: historyKey) as? [Int] ?? []
        
        // Filter available words
        var available = allWords.filter { !history.contains($0.id) }
        
        // Reset if needed
        if available.isEmpty {
            history.removeAll()
            userDefaults.removeObject(forKey: historyKey)
            available = allWords
        }
        
        // Pick random
        guard let selectedWord = available.randomElement() else { return nil }
        
        // Update history
        history.append(selectedWord.id)
        userDefaults.set(history, forKey: historyKey)
        
        return selectedWord
    }
}

