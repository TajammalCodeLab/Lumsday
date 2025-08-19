//
//  TipSheetView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI
// MARK: - Tip Sheet View
struct TipSheetView: View {
  @Binding var isPresented: Bool
    var body: some View {
        VStack(spacing: 20) {
            Text("Scanning Tips")
                .font(.title)
                .bold()
            Text("""
                1. Hold your phone steady.\n
                2. Align the red dot with the green dot.\n
                3. Make sure the lighting is good.\n
                4. Tap the capture button when aligned.
                """)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 200)
          Button("Close") {
            isPresented.toggle()
          }
            .padding()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .padding()
    }
}
