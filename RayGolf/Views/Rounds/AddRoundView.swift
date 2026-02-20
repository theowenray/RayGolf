import SwiftUI
import SwiftData

struct AddRoundView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var courseName: String
    @State private var totalScore: String
    @State private var frontNineScore: String
    @State private var backNineScore: String
    @State private var notes: String
    @State private var isNineHole: Bool
    
    @State private var showValidationError = false
    
    private var editingRound: Round?
    
    init(round: Round? = nil) {
        editingRound = round
        _date = State(initialValue: round?.date ?? Date())
        _courseName = State(initialValue: round?.courseName ?? "")
        _totalScore = State(initialValue: round.map { String($0.totalScore) } ?? "")
        _frontNineScore = State(initialValue: round?.frontNineScore.map { String($0) } ?? "")
        _backNineScore = State(initialValue: round?.backNineScore.map { String($0) } ?? "")
        _notes = State(initialValue: round?.notes ?? "")
        _isNineHole = State(initialValue: round?.isNineHole ?? false)
    }
    
    private var scoreInt: Int? { Int(totalScore) }
    private var isValid: Bool {
        guard let s = scoreInt else { return false }
        return s >= 40 && s <= 200
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
                    TextField(isNineHole ? "9-hole score" : "18-hole score", text: $totalScore)
                        .keyboardType(.numberPad)
                    if !isNineHole {
                        TextField("Front 9 (optional)", text: $frontNineScore)
                            .keyboardType(.numberPad)
                        TextField("Back 9 (optional)", text: $backNineScore)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Score")
                } footer: {
                    Text("Score must be between 40 and 200")
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
                Text("Score must be between 40 and 200")
            }
        }
    }
    
    private func save() {
        guard let score = scoreInt, score >= 40, score <= 200 else {
            showValidationError = true
            return
        }
        
        let front = Int(frontNineScore).map { $0 > 0 ? $0 : nil } ?? nil
        let back = Int(backNineScore).map { $0 > 0 ? $0 : nil } ?? nil
        
        if let existing = editingRound {
            existing.date = date
            existing.courseName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.totalScore = score
            existing.frontNineScore = front
            existing.backNineScore = back
            existing.notes = notes.isEmpty ? nil : notes
            existing.isNineHole = isNineHole
        } else {
            let round = Round(
                date: date,
                courseName: courseName.trimmingCharacters(in: .whitespacesAndNewlines),
                totalScore: score,
                frontNineScore: front,
                backNineScore: back,
                notes: notes.isEmpty ? nil : notes,
                isNineHole: isNineHole
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
