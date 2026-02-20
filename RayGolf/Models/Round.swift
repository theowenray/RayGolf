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
    
    init(
        date: Date = .now,
        courseName: String = "",
        totalScore: Int,
        frontNineScore: Int? = nil,
        backNineScore: Int? = nil,
        notes: String? = nil,
        isNineHole: Bool = false
    ) {
        self.date = date
        self.courseName = courseName
        self.totalScore = totalScore
        self.frontNineScore = frontNineScore
        self.backNineScore = backNineScore
        self.notes = notes
        self.isNineHole = isNineHole
    }
    
    /// For handicap/trend purposes, use 18-hole equivalent (double 9-hole score).
    var effectiveScore: Int {
        isNineHole ? totalScore * 2 : totalScore
    }
}
