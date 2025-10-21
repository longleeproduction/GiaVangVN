//
//  WebEmbedWatchView.swift
//  GiaVang Watch App
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

/// WebEmbedWatchView provides a graceful fallback for web content on watchOS
/// Since WKWebView is not available on watchOS, this view offers to open the URL on the paired iPhone
struct WebEmbedWatchView: View {
    let url: URL
    let title: String?

    @Environment(\.openURL) private var openURL
    @State private var showOpenConfirmation = false

    init(url: URL, title: String? = nil) {
        self.url = url
        self.title = title
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "globe")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .padding(.top)

                // Title if provided
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Description
                Text("Web content is not available on Apple Watch")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                // URL Display
                VStack(alignment: .leading, spacing: 4) {
                    Text("URL")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(url.absoluteString)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

                // Open on iPhone button
                Button {
                    openURL(url)
                    showOpenConfirmation = true
                } label: {
                    Label("Open on iPhone", systemImage: "iphone")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

                if showOpenConfirmation {
                    Text("Opening on iPhone...")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Alternative compact version for embedding in other views
struct WebEmbedCompactWatchView: View {
    let url: URL
    let title: String

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            openURL(url)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "safari")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text("Tap to view on iPhone")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Full View") {
    NavigationStack {
        WebEmbedWatchView(
            url: URL(string: "https://giavang.pro/box.html?product=RlhfSURDOlVTRFZORA==&theme=light")!,
            title: "Exchange Rate Chart"
        )
    }
}

#Preview("Compact View") {
    WebEmbedCompactWatchView(
        url: URL(string: "https://giavang.pro")!,
        title: "View Gold Prices"
    )
    .padding()
}
