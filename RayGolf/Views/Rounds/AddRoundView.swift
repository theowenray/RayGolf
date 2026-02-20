import SwiftUI
import SwiftData

struct AddRoundView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var courseName: String
    @State private var notes: String
    @State private var isNineHole: Bool
    @State private var holeScoreStrings: [String]
    
    @State private var showValidationError = false
    
    private var editingRound: Round?
    
    init(round: Round? = nil) {
        editingRound = round
        _date = State(initialValue: round?.date ?? Date())
        _courseName = State(initialValue: round?.courseName ?? "")
        _notes = State(initialValue: round?.notes ?? "")
        _isNineHole = State(initialValue: round?.isNineHole ?? false)
        
        // Initialize 18 hole fields; pre-fill from existing per-hole scores if available.
        if let existingScores = round?.holeScores {
            var initial = Array(repeating: "", count: 18)
            for (index, score) in existingScores.enumerated() where index < 18 {
                initial[index] = String(score)
            }
            _holeScoreStrings = State(initialValue: initial)
        } else {
            _holeScoreStrings = State(initialValue: Array(repeating: "", count: 18))
        }
    }
    
    private var holeCount: Int { isNineHole ? 9 : 18 }
    
    /// Parsed per-hole scores when all visible holes are filled with valid integers.
    private var parsedScores: [Int]? {
        let slice = holeScoreStrings.prefix(holeCount)
        let parsed = slice.compactMap { Int($0) }
        guard parsed.count == holeCount else { return nil }
        return parsed
    }
    
    private var perHoleTotal: Int? {
        parsedScores?.reduce(0, +)
    }
    
    private var isValid: Bool {
        guard let total = perHoleTotal else { return false }
        if isNineHole {
            return total >= 20 && total <= 120
        } else {
            return total >= 40 && total <= 200
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Course Name", text: $courseName)
                }
                
                Section {
                    Toggle("9-hole round", isOn: $isNineHole)
                    
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0..<holeCount, id: \.self) { index in
                            VStack(spacing: 4) {
                                Text("\(index + 1)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                TextField("-", text: Binding(
                                    get: { holeScoreStrings[index] },
                                    set: { holeScoreStrings[index] = $0 }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 44)
                                .padding(6)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        if let total = perHoleTotal {
                            Text("Total: \(total)")
                                .font(.headline)
                        } else {
                            Text("Enter all hole scores")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Score (per hole)")
                } footer: {
                    Text(isNineHole
                         ? "Enter all 9 hole scores. Typical 9-hole totals are between 20 and 120."
                         : "Enter all 18 hole scores. Total must be between 40 and 200.")
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(editingRound == nil ? "Add Round" : "Edit Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Invalid Score", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(isNineHole
                     ? "Please enter a valid 9-hole total (20–120)."
                     : "Please enter a valid 18-hole total (40–200).")
            }
        }
    }
    
    private func save() {
        guard let scores = parsedScores,
              let total = perHoleTotal,
              isValid else {
            showValidationError = true
            return
        }
        
        // Derive front/back from per-hole scores.
        let front: Int?
        let back: Int?
        if isNineHole {
            front = total
            back = nil
        } else {
            let frontScores = Array(scores.prefix(9))
            let backScores = Array(scores.dropFirst(9))
            front = frontScores.isEmpty ? nil : frontScores.reduce(0, +)
            back = backScores.isEmpty ? nil : backScores.reduce(0, +)
        }
        
        if let existing = editingRound {
            existing.date = date
            existing.courseName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.totalScore = total
            existing.frontNineScore = front
            existing.backNineScore = back
            existing.notes = notes.isEmpty ? nil : notes
            existing.isNineHole = isNineHole
            existing.holeScores = scores
        } else {
            let round = Round(
                date: date,
                courseName: courseName.trimmingCharacters(in: .whitespacesAndNewlines),
                totalScore: total,
                frontNineScore: front,
                backNineScore: back,
                notes: notes.isEmpty ? nil : notes,
                isNineHole: isNineHole,
                holeScores: scores
            )
            modelContext.insert(round)
        }
        dismiss()
    }
}

#Preview {
    AddRoundView()
        .modelContainer(for: Round.self, inMemory: true)
}
