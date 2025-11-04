//
//  AppHeaderView.swift
//  GiaVangVN
//
//  Created by ORL on 4/11/25.
//

import SwiftUI

struct AppHeaderView: View {
    let title: String
    
    @State var titleFake : String = ""
    
    var body: some View {
        HStack {
            Image("ic_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            Text(titleFake)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.task {
            titleFake = title + "                                                                                           "
            + "                                                                                           "
        }
    }
}

#Preview {
    AppHeaderView(title: "Thị trường")
}
