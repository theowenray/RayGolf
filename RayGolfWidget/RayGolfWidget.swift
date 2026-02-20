//
//  RayGolfWidget.swift
//  RayGolfWidget
//

import AppIntents
import WidgetKit
import SwiftUI

// Use same App Group as main app so widget and app share active round data
private let widgetDefaults: UserDefaults? = UserDefaults(suiteName: "group.com.raygolf.app")

private enum WidgetKeys {
    static let courseName = "raygolf.activeRound.courseName"
    static let isNineHole = "raygolf.activeRound.isNineHole"
    static let currentHole = "raygolf.activeRound.currentHole"
}

struct RayGolfWidget: Widget {
    let kind: String = "RayGolfWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RayGolfTimelineProvider()) { entry in
            RayGolfWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("RayGolf Score")
        .description("Quickly log your score as you play each hole.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    }
}

struct RayGolfTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> RayGolfEntry {
        RayGolfEntry(date: Date(), courseName: "Pebble Beach", currentHole: 3, isNineHole: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (RayGolfEntry) -> Void) {
        let def = widgetDefaults ?? UserDefaults.standard
        let entry = RayGolfEntry(
            date: Date(),
            courseName: def.string(forKey: WidgetKeys.courseName) ?? "",
            currentHole: def.integer(forKey: WidgetKeys.currentHole),
            isNineHole: def.bool(forKey: WidgetKeys.isNineHole)
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RayGolfEntry>) -> Void) {
        let def = widgetDefaults ?? UserDefaults.standard
        let entry = RayGolfEntry(
            date: Date(),
            courseName: def.string(forKey: WidgetKeys.courseName) ?? "",
            currentHole: def.integer(forKey: WidgetKeys.currentHole),
            isNineHole: def.bool(forKey: WidgetKeys.isNineHole)
        )
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct RayGolfEntry: TimelineEntry {
    let date: Date
    let courseName: String
    let currentHole: Int
    let isNineHole: Bool
}

struct RayGolfWidgetView: View {
    var entry: RayGolfEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularView(entry: entry)
        case .accessoryInline:
            InlineView(entry: entry)
        case .systemSmall, .systemMedium:
            SystemWidgetView(entry: entry)
        default:
            Text("RayGolf")
        }
    }
}

/// Home Screen widget (systemSmall / systemMedium) — same content as Lock Screen rectangular.
struct SystemWidgetView: View {
    var entry: RayGolfEntry

    @ViewBuilder
    private func scoreLabel(_ score: Int) -> some View {
        Text("\(score)")
            .font(.caption)
            .fontWeight(.semibold)
            .frame(width: 32, height: 32)
            .background(Color.green.opacity(0.2))
            .foregroundStyle(.primary)
            .clipShape(Circle())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.currentHole > 0 && entry.currentHole <= (entry.isNineHole ? 9 : 18) {
                Text("Hole \(entry.currentHole)")
                    .font(.headline)
                if !entry.courseName.isEmpty {
                    Text(entry.courseName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Button(intent: RecordScore1Intent()) { scoreLabel(1) }.buttonStyle(.plain)
                    Button(intent: RecordScore2Intent()) { scoreLabel(2) }.buttonStyle(.plain)
                    Button(intent: RecordScore3Intent()) { scoreLabel(3) }.buttonStyle(.plain)
                    Button(intent: RecordScore4Intent()) { scoreLabel(4) }.buttonStyle(.plain)
                    Button(intent: RecordScore5Intent()) { scoreLabel(5) }.buttonStyle(.plain)
                    Button(intent: RecordScore6Intent()) { scoreLabel(6) }.buttonStyle(.plain)
                    Button(intent: RecordScore7Intent()) { scoreLabel(7) }.buttonStyle(.plain)
                    Button(intent: RecordScore8Intent()) { scoreLabel(8) }.buttonStyle(.plain)
                }
            } else {
                Text("No active round")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct RectangularView: View {
    var entry: RayGolfEntry

    @ViewBuilder
    private func scoreLabel(_ score: Int) -> some View {
        Text("\(score)")
            .font(.caption)
            .fontWeight(.semibold)
            .frame(width: 28, height: 28)
            .background(Color.green.opacity(0.2))
            .foregroundStyle(.primary)
            .clipShape(Circle())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.currentHole > 0 && entry.currentHole <= (entry.isNineHole ? 9 : 18) {
                Text("Hole \(entry.currentHole)")
                    .font(.headline)
                if !entry.courseName.isEmpty {
                    Text(entry.courseName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Button(intent: RecordScore1Intent()) { scoreLabel(1) }.buttonStyle(.plain)
                    Button(intent: RecordScore2Intent()) { scoreLabel(2) }.buttonStyle(.plain)
                    Button(intent: RecordScore3Intent()) { scoreLabel(3) }.buttonStyle(.plain)
                    Button(intent: RecordScore4Intent()) { scoreLabel(4) }.buttonStyle(.plain)
                    Button(intent: RecordScore5Intent()) { scoreLabel(5) }.buttonStyle(.plain)
                    Button(intent: RecordScore6Intent()) { scoreLabel(6) }.buttonStyle(.plain)
                    Button(intent: RecordScore7Intent()) { scoreLabel(7) }.buttonStyle(.plain)
                    Button(intent: RecordScore8Intent()) { scoreLabel(8) }.buttonStyle(.plain)
                }
            } else {
                Text("No active round")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct InlineView: View {
    var entry: RayGolfEntry

    var body: some View {
        if entry.currentHole > 0 && entry.currentHole <= (entry.isNineHole ? 9 : 18) {
            Label("Hole \(entry.currentHole)", systemImage: "figure.golf")
        } else {
            Label("RayGolf", systemImage: "figure.golf")
        }
    }
}

#Preview(as: .accessoryRectangular) {
    RayGolfWidget()
} timeline: {
    RayGolfEntry(date: .now, courseName: "Pebble Beach", currentHole: 3, isNineHole: false)
    RayGolfEntry(date: .now, courseName: "", currentHole: 0, isNineHole: false)
}
