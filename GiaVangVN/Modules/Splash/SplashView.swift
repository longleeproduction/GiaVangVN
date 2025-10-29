//
//  SplashView.swift
//  GiaVangVN
//
//  Created by ORL on 28/10/25.
//


import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image("img_splash")

            VStack(alignment: .leading) {
                Image("GOlDWAVES")
                    .padding(.vertical, 16)
                Text("Đầu tư thông minh với Giao dịch trực tuyến của chúng tôi")
                    .font(.system(size: 16, weight: .semibold))
            }.padding(.horizontal, 20)
                .padding(.leading, 10)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    SplashView()
}
