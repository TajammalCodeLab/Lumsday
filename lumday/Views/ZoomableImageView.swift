//
//  ZoomableImageView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


// MARK: - Zoomable Fullscreen Image View
import SwiftUI

struct ZoomableImageView: View {
  let image: UIImage
  var onDismiss: () -> Void

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .scaleEffect(scale)
        .gesture(MagnificationGesture()
          .onChanged { value in
            scale = lastScale * value
          }
          .onEnded { _ in
            lastScale = scale
          }
        )

      VStack {
        HStack {
          Spacer()
          Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 30))
              .foregroundColor(.white)
              .padding()
          }
        }
        Spacer()
      }
    }
  }
}
