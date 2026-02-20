import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Round.date, order: .reverse) private var rounds: [Round]
    @ObservedObject private var goals = GoalsStore.shared
    @State private var use18HoleEquivalent = false
    
    private var playProgress: Double {
        let current = StatisticsService.roundsThisWeek(from: rounds)
        let goal = Double(max(goals.weeklyGoal, 1))
        return min(Double(current) / goal, 1)
    }
    
    private var consistencyProgress: Double {
        let current = StatisticsService.roundsInLast30Days(from: rounds)
        let goal = Double(max(goals.monthlyGoal, 1))
        return min(Double(current) / goal, 1)
    }
    
    private var improveProgress: Double {
        StatisticsService.improveRingProgress(from: rounds)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Rings
                    VStack(spacing: 8) {
                        ProgressRingsView(
                            playProgress: playProgress,
                            consistencyProgress: consistencyProgress,
                            improveProgress: improveProgress
                        )
                        HStack(spacing: 20) {
                            RingLegend(label: "Play", sublabel: "\(Int(playProgress * 100))%", color: .green)
                            RingLegend(label: "Consistency", sublabel: "\(Int(consistencyProgress * 100))%", color: .blue)
                            RingLegend(label: "Improve", sublabel: "\(Int(improveProgress * 100))%", color: .orange)
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 8)
                    
                    // Score mode toggle
                    HStack {
                        Text("Scores")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $use18HoleEquivalent) {
                            Text("9 Holes").tag(false)
                            Text("18 Holes").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                    
                    // Metrics
                    MetricsCardsView(
                        scoringAverage: StatisticsService.scoringAverage(from: rounds, count: 5, use18HoleEquivalent: use18HoleEquivalent),
                        bestRound: StatisticsService.bestRoundLast90Days(from: rounds, use18HoleEquivalent: use18HoleEquivalent)
                    )
                    
                    // Trend chart
                    TrendChartView(rounds: rounds, use18HoleEquivalent: use18HoleEquivalent)
                    
                    // Streak
                    StreakView(weeksPlayedInRow: StatisticsService.weeksPlayedInRow(from: rounds))
                }
                .padding()
            }
            .navigationTitle("RayGolf")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct RingLegend: View {
    let label: String
    let sublabel: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(sublabel)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Round.self, inMemory: true)
}
