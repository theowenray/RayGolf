import SwiftUI

struct SettingsView: View {
    @ObservedObject private var goals = GoalsStore.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Weekly goal: \(goals.weeklyGoal) round\(goals.weeklyGoal == 1 ? "" : "s")", value: $goals.weeklyGoal, in: 1...7)
                    Stepper("Monthly goal: \(goals.monthlyGoal) round\(goals.monthlyGoal == 1 ? "" : "s")", value: $goals.monthlyGoal, in: 1...30)
                } header: {
                    Text("Goals")
                } footer: {
                    Text("Play and Consistency rings use these goals.")
                }
                
                Section {
                    HStack {
                        Text("Estimated Handicap")
                        Spacer()
                        Text("Simplified estimate (no slope/rating yet)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("Handicap is computed from your last 10 rounds. Full USGA calculation with course slope/rating may be added later.")
                }
                
                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("RayGolf")
                            .fontWeight(.medium)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
