import Foundation
import SwiftData

@Model
final class Round {
    var date: Date
    var courseName: String
    var totalScore: Int
    var frontNineScore: Int?
    var backNineScore: Int?
    var notes: String?
    var isNineHole: Bool
    /// Optional per-hole scores (1–18). When present, used to derive totals.
    var holeScores: [Int]?
    
    init(
        date: Date = .now,
        courseName: String = "",
        totalScore: Int,
        frontNineScore: Int? = nil,
        backNineScore: Int? = nil,
        notes: String? = nil,
        isNineHole: Bool = false,
        holeScores: [Int]? = nil
    ) {
        self.date = date
        self.courseName = courseName
        self.totalScore = totalScore
        self.frontNineScore = frontNineScore
        self.backNineScore = backNineScore
        self.notes = notes
        self.isNineHole = isNineHole
        self.holeScores = holeScores
    }
    
    /// For handicap/trend purposes, use 18-hole equivalent (double 9-hole score).
    var effectiveScore: Int {
        let baseTotal: Int
        if let holeScores, !holeScores.isEmpty {
            baseTotal = holeScores.reduce(0, +)
        } else {
            baseTotal = totalScore
        }
        return isNineHole ? baseTotal * 2 : baseTotal
    }
}
