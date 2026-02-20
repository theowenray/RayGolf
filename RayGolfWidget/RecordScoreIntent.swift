import AppIntents
import Foundation
import WidgetKit

// Shared logic for recording a hole score (1–8). Used by each RecordScoreNIntent.
private func recordHoleScore(_ score: Int) {
    let def = UserDefaults(suiteName: "group.com.raygolf.app") ?? UserDefaults.standard
    let currentHole = def.integer(forKey: "raygolf.activeRound.currentHole")
    let isNineHole = def.bool(forKey: "raygolf.activeRound.isNineHole")
    let maxHoles = isNineHole ? 9 : 18

    guard score >= 1 && score <= 8 && currentHole > 0 && currentHole <= maxHoles else { return }

    var holeScores = (def.array(forKey: "raygolf.activeRound.holeScores") as? [Int]) ?? []
    while holeScores.count < currentHole {
        holeScores.append(0)
    }
    if currentHole <= holeScores.count {
        holeScores[currentHole - 1] = score
    } else {
        holeScores.append(score)
    }
    let nextHole = currentHole < maxHoles ? currentHole + 1 : maxHoles + 1
    def.set(holeScores, forKey: "raygolf.activeRound.holeScores")
    def.set(nextHole, forKey: "raygolf.activeRound.currentHole")
    WidgetCenter.shared.reloadTimelines(ofKind: "RayGolfWidget")
}

struct RecordScore1Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 1"
    static var description = IntentDescription("Record a score of 1 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(1)
        return .result()
    }
}

struct RecordScore2Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 2"
    static var description = IntentDescription("Record a score of 2 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(2)
        return .result()
    }
}

struct RecordScore3Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 3"
    static var description = IntentDescription("Record a score of 3 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(3)
        return .result()
    }
}

struct RecordScore4Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 4"
    static var description = IntentDescription("Record a score of 4 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(4)
        return .result()
    }
}

struct RecordScore5Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 5"
    static var description = IntentDescription("Record a score of 5 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(5)
        return .result()
    }
}

struct RecordScore6Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 6"
    static var description = IntentDescription("Record a score of 6 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(6)
        return .result()
    }
}

struct RecordScore7Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 7"
    static var description = IntentDescription("Record a score of 7 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(7)
        return .result()
    }
}

struct RecordScore8Intent: AppIntent {
    static var title: LocalizedStringResource = "Record 8"
    static var description = IntentDescription("Record a score of 8 for this hole.")
    func perform() async throws -> some IntentResult {
        recordHoleScore(8)
        return .result()
    }
}
