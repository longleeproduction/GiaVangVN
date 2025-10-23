//
//  GiaVang_WidgetLiveActivity.swift
//  GiaVang Widget
//
//  Created by ORL on 23/10/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GiaVang_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GiaVang_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GiaVang_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GiaVang_WidgetAttributes {
    fileprivate static var preview: GiaVang_WidgetAttributes {
        GiaVang_WidgetAttributes(name: "World")
    }
}

extension GiaVang_WidgetAttributes.ContentState {
    fileprivate static var smiley: GiaVang_WidgetAttributes.ContentState {
        GiaVang_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GiaVang_WidgetAttributes.ContentState {
         GiaVang_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GiaVang_WidgetAttributes.preview) {
   GiaVang_WidgetLiveActivity()
} contentStates: {
    GiaVang_WidgetAttributes.ContentState.smiley
    GiaVang_WidgetAttributes.ContentState.starEyes
}
