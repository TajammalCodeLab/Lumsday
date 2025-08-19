//
//  AuraBackgroundView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI

struct AuraBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.3, green: 0.5, blue: 1.0), // Soft blue
                Color(red: 0.7, green: 0.4, blue: 1.0), // Lavender
                Color(red: 1.0, green: 0.6, blue: 0.8)  // Soft pink
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            // Add a subtle glow/blur for the "aura" effect
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        center: .center,
                        angle: .degrees(0)
                    )
                )
                .blur(radius: 30)
        )
    }
}
