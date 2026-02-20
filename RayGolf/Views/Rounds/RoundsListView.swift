import SwiftUI
import SwiftData

struct RoundsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Round.date, order: .reverse) private var rounds: [Round]
    @State private var showingAddRound = false
    @State private var roundToEdit: Round?
    
    var body: some View {
        NavigationStack {
            Group {
                if rounds.isEmpty {
                    ContentUnavailableView(
                        "No Rounds",
                        systemImage: "figure.golf",
                        description: Text("Tap + to log your first round")
                    )
                } else {
                    List {
                        ForEach(rounds) { round in
                            RoundRowView(round: round)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    roundToEdit = round
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(round)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Rounds")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddRound = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddRound) {
                AddRoundView()
            }
            .sheet(item: $roundToEdit) { round in
                AddRoundView(round: round)
            }
        }
    }
}

struct RoundRowView: View {
    let round: Round
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(round.courseName.isEmpty ? "Round" : round.courseName)
                    .font(.headline)
                Spacer()
                Text(round.totalScore, format: .number)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            HStack {
                Text(round.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if round.isNineHole {
                    Text("9 holes")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RoundsListView()
        .modelContainer(for: Round.self, inMemory: true)
}
