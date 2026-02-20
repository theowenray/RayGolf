import Foundation
import SwiftData

struct StatisticsService {
    /// Rounds this week (calendar week)
    static func roundsThisWeek(from rounds: [Round]) -> Int {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return rounds.filter { $0.date >= startOfWeek }.count
    }
    
    /// Rounds in last 30 days
    static func roundsInLast30Days(from rounds: [Round]) -> Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return rounds.filter { $0.date >= thirtyDaysAgo }.count
    }
    
    /// Scoring average of last N rounds.
    /// - Parameters:
    ///   - normalizeTo18: when true, uses 18-hole equivalent scores so 9-hole rounds are doubled.
    static func scoringAverage(from rounds: [Round], count: Int = 5, normalizeTo18: Bool = false) -> Double? {
        let sorted = rounds.sorted { $0.date > $1.date }
        let recent: [Int]
        if normalizeTo18 {
            recent = Array(sorted.prefix(count)).map(\.effectiveScore)
        } else {
            recent = Array(sorted.prefix(count)).map(\.totalScore)
        }
        guard !recent.isEmpty else { return nil }
        return Double(recent.reduce(0, +)) / Double(recent.count)
    }
    
    /// Best round (lowest raw total score) in last 90 days
    static func bestRoundLast90Days(from rounds: [Round]) -> Int? {
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let recent = rounds.filter { $0.date >= ninetyDaysAgo }.map(\.totalScore)
        return recent.min()
    }
    
    /// Trend: Improving / Flat / Worsening based on last 5 vs previous 5
    static func trend(from rounds: [Round]) -> Trend {
        let sorted = rounds.sorted { $0.date > $1.date }
        guard sorted.count >= 2 else { return .flat }
        let last5 = Array(sorted.prefix(5)).map(\.effectiveScore)
        let prev5 = Array(sorted.dropFirst(5).prefix(5)).map(\.effectiveScore)
        guard !last5.isEmpty, !prev5.isEmpty else { return .flat }
        let lastAvg = Double(last5.reduce(0, +)) / Double(last5.count)
        let prevAvg = Double(prev5.reduce(0, +)) / Double(prev5.count)
        let diff = prevAvg - lastAvg
        if diff > 1 { return .improving }
        if diff < -1 { return .worsening }
        return .flat
    }
    
    enum Trend: String {
        case improving = "Improving"
        case flat = "Flat"
        case worsening = "Worsening"
    }
    
    /// Weeks played in a row (at least 1 round per week)
    static func weeksPlayedInRow(from rounds: [Round]) -> Int {
        guard !rounds.isEmpty else { return 0 }
        let sorted = rounds.sorted { $0.date > $1.date }
        var streak = 0
        var checkDate = Date()
        let cal = Calendar.current
        
        while true {
            let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: checkDate)) ?? checkDate
            let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek) ?? startOfWeek
            let hasRound = sorted.contains { r in r.date >= startOfWeek && r.date < endOfWeek }
            if hasRound {
                streak += 1
                checkDate = cal.date(byAdding: .day, value: -7, to: startOfWeek) ?? startOfWeek
            } else {
                break
            }
        }
        return streak
    }
    
    /// Baseline average (first 5 rounds, or all if fewer)
    static func baselineAverage(from rounds: [Round]) -> Double? {
        let byDate = rounds.sorted { $0.date < $1.date }
        let first = Array(byDate.prefix(5)).map(\.effectiveScore)
        guard !first.isEmpty else { return nil }
        return Double(first.reduce(0, +)) / Double(first.count)
    }
    
    /// Internal: scoring average using effective scores (18-hole equivalent for 9-hole rounds)
    private static func effectiveScoringAverage(from rounds: [Round], count: Int = 5) -> Double? {
        let sorted = rounds.sorted { $0.date > $1.date }
        let recent = Array(sorted.prefix(count)).map(\.effectiveScore)
        guard !recent.isEmpty else { return nil }
        return Double(recent.reduce(0, +)) / Double(recent.count)
    }
    
    /// Improve ring fill: clamp((baseline - last5) / 10, 0...1)
    static func improveRingProgress(from rounds: [Round]) -> Double {
        guard let baseline = baselineAverage(from: rounds),
              let last5 = effectiveScoringAverage(from: rounds, count: 5) else { return 0 }
        let improvement = baseline - last5
        return min(max(improvement / 10, 0), 1)
    }
}
