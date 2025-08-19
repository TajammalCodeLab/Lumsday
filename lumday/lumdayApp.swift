//
//  lumdayApp.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/18/25.
//
import SwiftUI

@main
struct lumdayApp: App {
  var body: some Scene {
    WindowGroup {
      SaliencyColorFillView()
    }
  }
}
import SwiftUI
import BackgroundRemoval
import PhotosUI
import Vision
import CoreML
struct RomoveImageBackground: View {
  @ObservedObject var bgRemover = RomoveBackground()
  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var selectedImage: UIImage?

  // For fullscreen preview
  @State private var showFullScreen = false
  @State private var fullscreenImage: IdentifiedImage?


  var body: some View {
    NavigationView {
      VStack(spacing: 24) {

        // Horizontal scroll of images
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {

            // Original Image Card
            if let img = selectedImage {
              imageCard(uiImage: img, label: "Original")
            }

            // Processed Image Card
            if let processed = bgRemover.outputImage {
              imageCard(uiImage: processed, label: "Processed")
            }
          }
          .padding(.horizontal)
        }
        .frame(height: 360)

        // Pick Button
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
          Text("Select Photo")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
              LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                             startPoint: .leading,
                             endPoint: .trailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }

        Spacer()
      }
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle("Remove Background")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onChange(of: selectedItems) { _, newItems in
      guard let item = newItems.first else { return }
      Task {
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
          selectedImage = uiImage
          bgRemover.inputImage = uiImage
          bgRemover.removeBackground()
        }
      }
    }
    // Fullscreen Image Modal
    .fullScreenCover(item: $fullscreenImage) { item in
        ZoomableImageView(image: item.image) {
            fullscreenImage = nil
        }
    }

  }

  // MARK: - Image Card
  private func imageCard(uiImage: UIImage, label: String) -> some View {
    VStack {
      Image(uiImage: uiImage)
        .resizable()
        .scaledToFill()
        .frame(width: 260, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .onTapGesture {
            fullscreenImage = IdentifiedImage(image: uiImage)
        }


      Text(label)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
  }
}
struct IdentifiedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

