//
//  News.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 22.09.2025.
//

import SwiftUI

struct VRGNewsLoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack {
            Image("VRGNews_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                    value: isRotating
                )
                .onAppear {
                    isRotating = true
                }
                .onDisappear {
                    isRotating = false
                }
        }
    }
}
