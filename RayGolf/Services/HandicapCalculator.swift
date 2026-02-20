import Foundation

/// Simplified handicap estimate: average of last N scores minus 72.
/// Future-ready for USGA formula with slope/rating.
struct HandicapCalculator {
    static let defaultRecentRoundsCount = 10
    
    /// Returns estimated handicap from given effective scores (18-hole equivalent).
    /// Uses last N rounds (or all if fewer).
    static func estimatedHandicap(from scores: [Int], recentCount: Int = defaultRecentRoundsCount) -> Double? {
        guard !scores.isEmpty else { return nil }
        let recent = Array(scores.suffix(recentCount))
        let avg = Double(recent.reduce(0, +)) / Double(recent.count)
        return avg - 72
    }
}
