//
//  ContentView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedPage = 0

    var body: some View {
        TabView(selection: $selectedPage) {
            DashboardWatchView()
                .tag(0)

            GoldWatchView()
                .tag(1)

            CurrencyWatchView()
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    ContentView()
}
