import SwiftUI

struct StreakView: View {
    let weeksPlayedInRow: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("Weeks Played in a Row")
                .font(.subheadline)
            Spacer()
            Text("\(weeksPlayedInRow)")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    StreakView(weeksPlayedInRow: 3)
        .padding()
}
