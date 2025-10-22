//
//  SettingView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    GoldCalculatorView()
                } label: {
                    Text("Calculator")
                        .padding()
                }

            }.navigationTitle(Text("Settings"))
        }
    }
}

#Preview {
    SettingView()
}
