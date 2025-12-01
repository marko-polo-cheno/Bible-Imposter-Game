import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var filename: String {
        switch self {
        case .easy: return "easy"
        case .medium: return "medium"
        case .hard: return "hard"
        }
    }
}

struct BibleTerm: Codable, Identifiable {
    let id: Int
    let term: String
}

struct Player: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

enum GameStatus {
    case setup
    case playing
    case finished
}

