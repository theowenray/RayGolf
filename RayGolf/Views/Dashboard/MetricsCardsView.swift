import SwiftUI

struct MetricsCardsView: View {
    let scoringAverage: Double?
    let bestRound: Int?
    
    var body: some View {
        HStack(spacing: 12) {
            MetricCard(title: "Scoring Avg", value: avgText, subtitle: "Last 5 rounds")
                .frame(maxWidth: .infinity)
            MetricCard(title: "Best Round", value: bestText, subtitle: "Last 90 days")
                .frame(maxWidth: .infinity)
        }
    }
    
    private var avgText: String {
        scoringAverage.map { String(format: "%.1f", $0) } ?? "—"
    }
    
    private var bestText: String {
        bestRound.map(String.init) ?? "—"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    var trendIcon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                if let icon = trendIcon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(trendColor)
                }
            }
            if let sub = subtitle {
                Text(sub)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var trendColor: Color {
        switch trendIcon {
        case "arrow.down.circle.fill": return .green
        case "arrow.up.circle.fill": return .red
        default: return .secondary
        }
    }
}

#Preview {
    MetricsCardsView(
        scoringAverage: 84.2,
        bestRound: 78
    )
    .padding()
}
