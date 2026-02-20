import Foundation
import Combine

/// App Group ID — must match the capability added to both RayGolf and RayGolfWidgetExtension targets in Xcode.
let kRayGolfAppGroupID = "group.com.raygolf.app"

/// Manages the current round in progress (for Lock Screen widget).
/// Uses App Group UserDefaults when available so the widget can read/write the same data.
final class ActiveRoundStore: ObservableObject {
    static let shared = ActiveRoundStore()
    
    private let defaults: UserDefaults
    private init() {
        let def = UserDefaults(suiteName: kRayGolfAppGroupID) ?? UserDefaults.standard
        defaults = def
        courseName = def.string(forKey: Keys.courseName) ?? ""
        isNineHole = def.bool(forKey: Keys.isNineHole)
        currentHole = def.integer(forKey: Keys.currentHole)
        holeScores = (def.array(forKey: Keys.holeScores) as? [Int]) ?? []
        date = def.object(forKey: Keys.date) as? Date ?? Date()
    }
    
    private enum Keys {
        static let courseName = "raygolf.activeRound.courseName"
        static let isNineHole = "raygolf.activeRound.isNineHole"
        static let currentHole = "raygolf.activeRound.currentHole"
        static let holeScores = "raygolf.activeRound.holeScores"
        static let date = "raygolf.activeRound.date"
    }
    
    @Published var courseName: String {
        didSet { save() }
    }
    
    @Published var isNineHole: Bool {
        didSet { save() }
    }
    
    @Published var currentHole: Int {
        didSet { save() }
    }
    
    @Published var holeScores: [Int] {
        didSet { save() }
    }
    
    @Published var date: Date {
        didSet { save() }
    }
    
    var hasActiveRound: Bool {
        currentHole > 0 && currentHole <= (isNineHole ? 9 : 18)
    }
    
    var isComplete: Bool {
        let maxHoles = isNineHole ? 9 : 18
        return currentHole > maxHoles && holeScores.count >= maxHoles
    }
    
    var totalScore: Int {
        holeScores.reduce(0, +)
    }
    
    func startRound(courseName: String, isNineHole: Bool) {
        self.courseName = courseName
        self.isNineHole = isNineHole
        self.currentHole = 1
        self.holeScores = []
        self.date = Date()
    }
    
    func recordScore(_ score: Int) {
        guard score >= 1 && score <= 8 else { return }
        let maxHoles = isNineHole ? 9 : 18
        
        // Ensure array is large enough
        while holeScores.count < currentHole {
            holeScores.append(0)
        }
        
        // Record score for current hole (1-indexed, so subtract 1)
        if currentHole <= holeScores.count {
            holeScores[currentHole - 1] = score
        } else {
            holeScores.append(score)
        }
        
        // Advance to next hole
        if currentHole < maxHoles {
            currentHole += 1
        } else {
            // Round complete
            currentHole = maxHoles + 1
        }
    }
    
    func finishRound() -> (courseName: String, isNineHole: Bool, totalScore: Int, holeScores: [Int], date: Date)? {
        guard isComplete else { return nil }
        let result = (courseName, isNineHole, totalScore, holeScores, date)
        clear()
        return result
    }
    
    func clear() {
        courseName = ""
        isNineHole = false
        currentHole = 0
        holeScores = []
        date = Date()
    }
    
    private func save() {
        defaults.set(courseName, forKey: Keys.courseName)
        defaults.set(isNineHole, forKey: Keys.isNineHole)
        defaults.set(currentHole, forKey: Keys.currentHole)
        defaults.set(holeScores, forKey: Keys.holeScores)
        defaults.set(date, forKey: Keys.date)
    }
}
