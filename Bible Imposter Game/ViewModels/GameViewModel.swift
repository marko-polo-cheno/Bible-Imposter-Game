import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var roster: [Player] = []
    @Published var selectedDifficulty: Difficulty = .easy {
        didSet { UserDefaults.standard.set(selectedDifficulty.rawValue, forKey: "selected_difficulty") }
    }
    @Published var selectedLanguage: Language = .english {
        didSet { UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selected_language") }
    }
    @Published var showHintForImposter: Bool = true {
        didSet { UserDefaults.standard.set(showHintForImposter, forKey: "show_hint_for_imposter") }
    }
    
    @Published var gameStatus: GameStatus = .setup
    @Published var currentPlayerIndex: Int = 0
    @Published var secretWord: BibleTerm?
    @Published var imposterID: UUID?
    @Published var startingPlayerID: UUID?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // Track last 7 imposters by name for weighted selection
    private var imposterHistory: [String] = []
    private let imposterHistoryKey = "imposter_history"
    private let maxImposterHistory = 7
    
    private let rosterKey = "user_roster_cache"
    
    init() {
        loadRoster()
        loadSettings()
        loadImposterHistory()
    }
    
    // MARK: - Roster Management
    
    func addPlayer(name: String) {
        let newPlayer = Player(name: name)
        roster.append(newPlayer)
        saveRoster()
    }
    
    func removePlayer(at offsets: IndexSet) {
        roster.remove(atOffsets: offsets)
        saveRoster()
    }
    
    func removeAllPlayers() {
        roster.removeAll()
        saveRoster()
    }
    
    private func saveRoster() {
        if let encoded = try? JSONEncoder().encode(roster) {
            UserDefaults.standard.set(encoded, forKey: rosterKey)
        }
    }
    
    private func loadRoster() {
        if let data = UserDefaults.standard.data(forKey: rosterKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            roster = decoded
        }
    }
    
    private func loadSettings() {
        if let rawValue = UserDefaults.standard.string(forKey: "selected_difficulty"),
           let difficulty = Difficulty(rawValue: rawValue) {
            selectedDifficulty = difficulty
        }
        if let rawValue = UserDefaults.standard.string(forKey: "selected_language"),
           let language = Language(rawValue: rawValue) {
            selectedLanguage = language
        }
        if UserDefaults.standard.object(forKey: "show_hint_for_imposter") != nil {
            showHintForImposter = UserDefaults.standard.bool(forKey: "show_hint_for_imposter")
        }
    }
    
    private func loadImposterHistory() {
        imposterHistory = UserDefaults.standard.stringArray(forKey: imposterHistoryKey) ?? []
    }
    
    private func saveImposterHistory() {
        UserDefaults.standard.set(imposterHistory, forKey: imposterHistoryKey)
    }
    
    // MARK: - Game Logic
    
    func startGame() {
        guard roster.count >= 3 else { return }
        
        guard let word = WordManager.shared.getWord(for: selectedDifficulty, language: selectedLanguage) else {
            self.errorMessage = "Could not load words for \(selectedDifficulty.rawValue) in \(selectedLanguage.rawValue)."
            self.showError = true
            return
        }
        self.secretWord = word
        
        let imposterIndex = selectWeightedImposter()
        self.imposterID = roster[imposterIndex].id
        
        // Update imposter history (most recent at index 0)
        let imposterName = roster[imposterIndex].name
        imposterHistory.insert(imposterName, at: 0)
        if imposterHistory.count > maxImposterHistory {
            imposterHistory.removeLast()
        }
        saveImposterHistory()
        
        let starterIndex = Int.random(in: 0..<roster.count)
        self.startingPlayerID = roster[starterIndex].id
        
        self.currentPlayerIndex = 0
        self.gameStatus = .playing
    }
    
    private func selectWeightedImposter() -> Int {
        // Weights: last imposter = 0%, 2nd last = 80%, older = gradually higher, not in history = 100%
        var weights: [Double] = []
        
        for player in roster {
            if let historyIndex = imposterHistory.firstIndex(of: player.name) {
                if historyIndex == 0 {
                    weights.append(0.0) // Last imposter cannot be imposter
                } else {
                    // Index 1: 80%, Index 2: 85%, Index 3: 88%, Index 4: 91%, Index 5: 94%, Index 6: 97%
                    let weight = 0.80 + Double(historyIndex - 1) * 0.03
                    weights.append(min(weight, 0.98))
                }
            } else {
                weights.append(1.0) // Not in history: full chance
            }
        }
        
        let totalWeight = weights.reduce(0, +)
        if totalWeight == 0 {
            // Fallback: everyone was recent imposter, pick anyone except last
            let candidates = roster.indices.filter { imposterHistory.first != roster[$0].name }
            return candidates.randomElement() ?? Int.random(in: 0..<roster.count)
        }
        
        let random = Double.random(in: 0..<totalWeight)
        var cumulative = 0.0
        for (index, weight) in weights.enumerated() {
            cumulative += weight
            if random < cumulative {
                return index
            }
        }
        return roster.count - 1
    }
    
    func nextPlayer() {
        if currentPlayerIndex < roster.count - 1 {
            currentPlayerIndex += 1
        } else {
            gameStatus = .finished
        }
    }
    
    func resetGame() {
        gameStatus = .setup
        currentPlayerIndex = 0
        secretWord = nil
        imposterID = nil
        startingPlayerID = nil
    }
    
    func getRole(for playerID: UUID) -> String {
        if playerID == imposterID {
            if showHintForImposter, let hint = secretWord?.hint {
                return "You are the Imposter!\nHint: \(hint)"
            }
            return "You are the Imposter!"
        } else {
            return secretWord?.term ?? "Error"
        }
    }
}
