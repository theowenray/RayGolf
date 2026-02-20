import Foundation

/// Stores user goals (weekly rounds, monthly rounds) in UserDefaults.
final class GoalsStore: ObservableObject {
    static let shared = GoalsStore()
    
    private enum Keys {
        static let weeklyGoal = "raygolf.weeklyGoal"
        static let monthlyGoal = "raygolf.monthlyGoal"
    }
    
    @Published var weeklyGoal: Int {
        didSet { UserDefaults.standard.set(weeklyGoal, forKey: Keys.weeklyGoal) }
    }
    
    @Published var monthlyGoal: Int {
        didSet { UserDefaults.standard.set(monthlyGoal, forKey: Keys.monthlyGoal) }
    }
    
    init() {
        let def = UserDefaults.standard
        weeklyGoal = def.object(forKey: Keys.weeklyGoal) as? Int ?? 1
        monthlyGoal = def.object(forKey: Keys.monthlyGoal) as? Int ?? 4
    }
}
