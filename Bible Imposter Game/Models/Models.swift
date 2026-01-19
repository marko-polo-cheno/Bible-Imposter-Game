import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case hard = "Hard"
    
    var filename: String {
        switch self {
        case .easy: return "easy"
        case .hard: return "hard"
        }
    }
}

enum Language: String, Codable, CaseIterable {
    case english = "English"
    case chinese = "中文"
    case spanish = "Español"
    
    var suffix: String {
        switch self {
        case .english: return ""
        case .chinese: return "-zh"
        case .spanish: return "-es"
        }
    }
}

struct BibleTerm: Codable, Identifiable {
    let id: Int
    let term: String
    let hint: String
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
