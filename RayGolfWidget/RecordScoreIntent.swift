import AppIntents
import Foundation
import WidgetKit

struct RecordScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Score"
    static var description = IntentDescription("Record your score for the current hole.")
    
    @Parameter(title: "Score")
    var score: Int
    
    func perform() async throws -> some IntentResult {
        // Use same App Group as main app so widget and app share data
        let def = UserDefaults(suiteName: "group.com.raygolf.app") ?? UserDefaults.standard
        let currentHole = def.integer(forKey: "raygolf.activeRound.currentHole")
        let isNineHole = def.bool(forKey: "raygolf.activeRound.isNineHole")
        let maxHoles = isNineHole ? 9 : 18
        
        guard score >= 1 && score <= 8 && currentHole > 0 && currentHole <= maxHoles else {
            return .result()
        }
        
        // Get existing scores
        var holeScores = (def.array(forKey: "raygolf.activeRound.holeScores") as? [Int]) ?? []
        
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
        let nextHole = currentHole < maxHoles ? currentHole + 1 : maxHoles + 1
        
        // Save back to UserDefaults
        def.set(holeScores, forKey: "raygolf.activeRound.holeScores")
        def.set(nextHole, forKey: "raygolf.activeRound.currentHole")
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "RayGolfWidget")
        
        return .result()
    }
}
