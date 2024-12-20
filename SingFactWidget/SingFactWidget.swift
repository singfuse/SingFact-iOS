//
//  SingFactWidget.swift
//  SingFactWidget
//
//  Created by Vinkas on 12/12/24.
//

import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FactEntry {
        FactEntry(date: Date(), index: -1)
    }

    func getSnapshot(in context: Context, completion: @escaping (FactEntry) -> ()) {
        let entry: FactEntry
        entry = FactEntry(date: Date(), index: 0)
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [FactEntry] = []
        let currentDate = Date()
        var hourOffset = 0
        
        for i in 0..<10 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = FactEntry(date: entryDate, index: i)
            entries.append(entry)
            hourOffset += 2
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct FactEntry: TimelineEntry {
    let date: Date
    let index: Int
}

struct SingFactWidgetEntryView : View {
    @Query var facts: [Fact]
    @Query var settings: [Setting]
    var entry: Provider.Entry
    let placeholderText = "Kallang River is the longest river in Singapore."
    let emptyText = "Open the app first to load the facts initially"
    
    func getText() -> String {
        if entry.index < 0 {
            return placeholderText
        } else if facts.isEmpty {
            let hasFacts = self.settings.first(where: { $0.id == "hasFacts" })
            
            if hasFacts?.value == "true" {
                WidgetCenter.shared.reloadAllTimelines()
            }

            return emptyText
        } else {
            return facts[entry.index].text
        }
    }

    var body: some View {
        VStack {
            Text(self.getText())
                .minimumScaleFactor(0.4)
        }
    }
}

struct SingFactWidget: Widget {
    let kind: String = "SingFactWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                SingFactWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(SingFact.modelContainer())
            } else {
                SingFactWidgetEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(SingFact.modelContainer())
            }
        }
        .configurationDisplayName("Random Fact")
        .description("This will display a random fact about Singapore.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    SingFactWidget()
} timeline: {
    FactEntry(date: .now, index: -1)
    FactEntry(date: .now, index: 0)
}
