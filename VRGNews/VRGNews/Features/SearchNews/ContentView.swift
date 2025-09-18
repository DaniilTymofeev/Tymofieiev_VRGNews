//
//  ContentView.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 17.09.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Verified")
            Text("Reliable")
            Text("Global")
            HStack {
                Spacer()
                Text("NEWS")
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: 100)
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
