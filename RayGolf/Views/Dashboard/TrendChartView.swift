import SwiftUI
import SwiftData

struct TrendChartView: View {
    let rounds: [Round]
    let use18HoleEquivalent: Bool
    @State private var showHandicap = false
    
    private var sortedRounds: [Round] {
        rounds.sorted { $0.date < $1.date }
    }
    
    private var chartData: [(date: Date, value: Double)] {
        let sorted = sortedRounds
        let scores = sorted.map(\.effectiveScore)
        if showHandicap {
            return sorted.enumerated().compactMap { i, r in
                let recent = Array(scores.prefix(i + 1))
                guard let h = HandicapCalculator.estimatedHandicap(from: recent) else { return nil }
                return (r.date, h)
            }
        } else {
            // Score mode: use 9-hole or 18-hole equivalent based on toggle.
            return sorted.map {
                let value = use18HoleEquivalent ? Double($0.effectiveScore) : $0.nineHoleEquivalentScore
                return (date: $0.date, value: value)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trend")
                    .font(.headline)
                Spacer()
                Picker("", selection: $showHandicap) {
                    Text("Score").tag(false)
                    Text("Handicap").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            
            if chartData.isEmpty {
                Text("Add rounds to see your trend")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                SimpleLineChart(data: chartData, yLabel: showHandicap ? "Handicap" : "Score")
                    .frame(height: 180)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SimpleLineChart: View {
    let data: [(date: Date, value: Double)]
    let yLabel: String
    
    private var yRange: (min: Double, max: Double) {
        guard !data.isEmpty else { return (0, 100) }
        let values = data.map(\.value)
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 100
        let pad = max((maxV - minV) * 0.1, 2)
        return (minV - pad, maxV + pad)
    }
    
    private var range: (min: Double, max: Double) { yRange }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let stepX = data.count > 1 ? w / CGFloat(data.count - 1) : w
            let r = range
            
            ZStack(alignment: .bottomLeading) {
                // Line
                if data.count >= 2 {
                    Path { path in
                        for (i, point) in data.enumerated() {
                            let x = CGFloat(i) * stepX
                            let norm = (point.value - r.min) / (r.max - r.min)
                            let y = h * (1 - norm)
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                }
                // End dot
                if let last = data.last {
                    let x = CGFloat(data.count - 1) * stepX
                    let norm = (last.value - r.min) / (r.max - r.min)
                    let y = h * (1 - norm)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

#Preview {
    TrendChartView(rounds: [], use18HoleEquivalent: false)
        .padding()
}
