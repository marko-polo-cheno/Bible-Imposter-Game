import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var roster: [Player] = []
    @Published var selectedDifficulty: Difficulty = .easy {
        didSet {
            UserDefaults.standard.set(selectedDifficulty.rawValue, forKey: "selected_difficulty")
        }
    }
    
    @Published var gameStatus: GameStatus = .setup
    @Published var currentPlayerIndex: Int = 0
    @Published var secretWord: BibleTerm?
    @Published var imposterID: UUID?
    @Published var startingPlayerID: UUID?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let rosterKey = "user_roster_cache"
    
    init() {
        loadRoster()
        loadDifficulty()
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
    
    private func loadDifficulty() {
        if let rawValue = UserDefaults.standard.string(forKey: "selected_difficulty"),
           let difficulty = Difficulty(rawValue: rawValue) {
            selectedDifficulty = difficulty
        }
    }
    
    // MARK: - Game Logic
    
    func startGame() {
        guard roster.count >= 3 else { return }
        
        // 1. Get Word
        guard let word = WordManager.shared.getWord(for: selectedDifficulty) else {
            self.errorMessage = "Could not load words for \(selectedDifficulty.rawValue). Please check the JSON files."
            self.showError = true
            return
        }
        self.secretWord = word
        
        // 2. Pick Imposter
        let imposterIndex = Int.random(in: 0..<roster.count)
        self.imposterID = roster[imposterIndex].id
        
        // 3. Pick Random Starter
        // (Can be anyone, including the imposter)
        let starterIndex = Int.random(in: 0..<roster.count)
        self.startingPlayerID = roster[starterIndex].id
        
        // 4. Reset Game State
        self.currentPlayerIndex = 0
        self.gameStatus = .playing
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
            return "You are the Imposter!"
        } else {
            return secretWord?.term ?? "Error"
        }
    }
}

