import SwiftUI

struct ProgressRingsView: View {
    let playProgress: Double      // 0...1
    let consistencyProgress: Double
    let improveProgress: Double
    @State private var animatedPlay: Double = 0
    @State private var animatedConsistency: Double = 0
    @State private var animatedImprove: Double = 0
    
    private let ringColors: [(Color, Color)] = [
        (.green, .green.opacity(0.6)),
        (.blue, .blue.opacity(0.6)),
        (.orange, .orange.opacity(0.6))
    ]
    
    var body: some View {
        ZStack {
            // Outer ring (Improve - orange)
            RingView(progress: animatedImprove, color: ringColors[2].0, background: ringColors[2].1, lineWidth: 14, size: 140)
            // Middle ring (Consistency - blue)
            RingView(progress: animatedConsistency, color: ringColors[1].0, background: ringColors[1].1, lineWidth: 14, size: 115)
            // Inner ring (Play - green)
            RingView(progress: animatedPlay, color: ringColors[0].0, background: ringColors[0].1, lineWidth: 14, size: 90)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedPlay = playProgress
                animatedConsistency = consistencyProgress
                animatedImprove = improveProgress
            }
        }
        .onChange(of: playProgress) { _, new in
            withAnimation(.easeOut(duration: 0.5)) { animatedPlay = new }
        }
        .onChange(of: consistencyProgress) { _, new in
            withAnimation(.easeOut(duration: 0.5)) { animatedConsistency = new }
        }
        .onChange(of: improveProgress) { _, new in
            withAnimation(.easeOut(duration: 0.5)) { animatedImprove = new }
        }
    }
}

struct RingView: View {
    let progress: Double
    let color: Color
    let background: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(background, lineWidth: lineWidth)
            .frame(width: size, height: size)
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(-90))
    }
}

#Preview {
    ProgressRingsView(playProgress: 0.7, consistencyProgress: 0.5, improveProgress: 0.3)
        .padding()
}
