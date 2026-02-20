import SwiftUI
import SwiftData

struct RoundsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Round.date, order: .reverse) private var rounds: [Round]
    @ObservedObject private var activeRound = ActiveRoundStore.shared
    @State private var showingAddRound = false
    @State private var showingStartRound = false
    @State private var roundToEdit: Round?
    @State private var showingFinishRound = false
    
    var body: some View {
        NavigationStack {
            Group {
                if rounds.isEmpty && !activeRound.hasActiveRound {
                    ContentUnavailableView(
                        "No Rounds",
                        systemImage: "figure.golf",
                        description: Text("Start a round to begin tracking")
                    )
                } else {
                    List {
                        // Active round card
                        if activeRound.hasActiveRound {
                            ActiveRoundCard()
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                        
                        // Past rounds
                        if !rounds.isEmpty {
                            Section {
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
                            } header: {
                                Text("Past Rounds")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Rounds")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if !activeRound.hasActiveRound {
                            Button {
                                showingStartRound = true
                            } label: {
                                Label("Start Round", systemImage: "play.circle")
                            }
                        }
                        Button {
                            showingAddRound = true
                        } label: {
                            Label("Add Round", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddRound) {
                AddRoundView()
            }
            .sheet(isPresented: $showingStartRound) {
                StartRoundView()
            }
            .sheet(item: $roundToEdit) { round in
                AddRoundView(round: round)
            }
            .alert("Round Complete!", isPresented: $showingFinishRound) {
                Button("Save Round") {
                    saveCompletedRound()
                }
                Button("Discard", role: .destructive) {
                    activeRound.clear()
                }
            } message: {
                if let total = activeRound.holeScores.last {
                    Text("Total score: \(activeRound.totalScore)")
                }
            }
            .onAppear {
                if activeRound.isComplete {
                    showingFinishRound = true
                }
            }
        }
    }
    
    private func saveCompletedRound() {
        guard let roundData = activeRound.finishRound() else { return }
        
        let front: Int?
        let back: Int?
        if roundData.isNineHole {
            front = roundData.totalScore
            back = nil
        } else {
            let frontScores = Array(roundData.holeScores.prefix(9))
            let backScores = Array(roundData.holeScores.dropFirst(9))
            front = frontScores.isEmpty ? nil : frontScores.reduce(0, +)
            back = backScores.isEmpty ? nil : backScores.reduce(0, +)
        }
        
        let round = Round(
            date: roundData.date,
            courseName: roundData.courseName,
            totalScore: roundData.totalScore,
            frontNineScore: front,
            backNineScore: back,
            notes: nil,
            isNineHole: roundData.isNineHole,
            holeScores: roundData.holeScores
        )
        modelContext.insert(round)
    }
}

struct ActiveRoundCard: View {
    @ObservedObject private var activeRound = ActiveRoundStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Round in Progress")
                        .font(.headline)
                    if !activeRound.courseName.isEmpty {
                        Text(activeRound.courseName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("Hole \(activeRound.currentHole)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            
            if !activeRound.holeScores.isEmpty {
                HStack {
                    Text("Total: \(activeRound.totalScore)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(activeRound.holeScores.count) holes")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Button {
                activeRound.clear()
            } label: {
                Label("Cancel Round", systemImage: "xmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct StartRoundView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var activeRound = ActiveRoundStore.shared
    @State private var courseName = ""
    @State private var isNineHole = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Course Name", text: $courseName)
                    Toggle("9-hole round", isOn: $isNineHole)
                }
            }
            .navigationTitle("Start Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        activeRound.startRound(courseName: courseName.isEmpty ? "Round" : courseName, isNineHole: isNineHole)
                        dismiss()
                    }
                    .disabled(courseName.isEmpty && courseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
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
