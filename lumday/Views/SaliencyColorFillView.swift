//
//  SaliencyColorFillView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI
import PhotosUI
import Vision

struct SaliencyColorFillView: View {
  @ObservedObject var bgRemover = RomoveBackground()
  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var originalImage: UIImage?
  @State private var processedImage: UIImage?
  
  @State private var showCamera = false
  
  @State private var blurAmount: Double = 6
  @State private var dilateRadius: Double = 2
  @State private var featherRadius: Double = 3
  
  @State private var cutOutMode: CutMode = .cutout
  var body: some View {
    NavigationStack {
      ZStack {
        AuraBackgroundView()
        ScrollView {
          VStack(spacing: 30) {
            VStack(spacing: 20) {
                RadioGroup<CutMode>(selection: $cutOutMode, title: "Processing Mode")

                // Show current choice
                HStack {
                    Image(systemName: cutOutMode.icon)
                    Text("Selected: \(cutOutMode.rawValue)")
                }
                .font(.subheadline)
                .padding(.top, 6)
            }
            .padding()
            if let image = processedImage {
              processedImageView(image)
             
            } else if let image = bgRemover.outputImage {
              processedImageView(image)
            } else {
              VStack(spacing: 16) {
                // Icon
                TextLabelsView
                
                // Take Photo Button
                Button(action: {
                  showCamera.toggle()
                }) {
                  Label("Take Photo", systemImage: "camera")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                // Choose from Gallery Button
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
                  Label("Choose from Gallery", systemImage: "photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .onChange(of: selectedItems) { _, newItems in
                  guard let item = newItems.first else { return }
                  Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                      originalImage = uiImage
                      switch cutOutMode {
                      case .outline:
                        bgRemover.inputImage = uiImage
                        bgRemover.removeBackground()
                      case .fillGreen:
                        processSaliency(on: uiImage)
                      case .cutout:
                        processEnzy(on: uiImage)
                      }
                      
                    }
                  }
                }
                .sheet(isPresented: $showCamera) {
                  PerspectiveCameraView { uiImage in
                    self.originalImage = uiImage
                    showCamera.toggle()
                    switch cutOutMode {
                    case .outline:
                      bgRemover.inputImage = uiImage
                      bgRemover.removeBackground()
                    case .fillGreen:
                      processSaliency(on: uiImage)
                    case .cutout:
                      processEnzy(on: uiImage)
                    }
                  }
                }
              }
              .padding()
              .background(Color.white)
              .clipShape(RoundedRectangle(cornerRadius: 20))
              .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
              .padding(.horizontal)
            }
            Spacer()
            
            // Bottom Button
            GoNextButtonView
          }
        }
      }
      .navigationTitle("Home")
    }
  }
  private var MeasurementWheels: some View {
    ZStack {
      
    }
  }
  private var TextLabelsView: some View {
    VStack(spacing: 16) {
      // Icon
      Image(systemName: "photo.on.rectangle")
        .font(.system(size: 40))
        .foregroundColor(.white)
        .padding()
        .background(Color.blue.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
      
      // Title + Subtitle
      Text("Add Your Object Image")
        .font(.headline)
      Text("Place a single object on paper for accurate DXF generation")
        .font(.subheadline)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      
    }
  }
  private var GoNextButtonView: some View {
    Button(action: {
      // TODO: go next action
    }) {
      Label {
        Text("Go Next")
      } icon: {
        Image(systemName: "chevron.right")
      }
      .padding()
      .background(originalImage == nil ? Color.gray.opacity(0.3) : Color.blue)
      .foregroundColor(originalImage == nil ? .white.opacity(0.7) : .white)
      .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    .padding(.horizontal)
    .disabled(processedImage == nil)
  }
  private func processedImageView(_ image: UIImage)-> some View {
    Image(uiImage: image)
      .resizable()
      .frame(height: 300)
      .clipShape(RoundedRectangle(cornerRadius: 15))
      .padding()
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
      .padding(.horizontal)
      .overlay(alignment: .top) {
        HStack {
          Spacer()
          Button(action: {
            processedImage = nil
            bgRemover.outputImage = nil
          }) {
            Image(systemName: "arrow.clockwise")
              .font(.headline)
              .padding(5)
              .background(Color.gray)
              .foregroundColor(.white)
              .clipShape(Circle())
          }
        }
        .padding(.trailing,33)
        .padding(.top,17)
      }
  }
  private func processSaliency(on image: UIImage) {
    Task {
      if let result = await SaliencyManager.shared.runSaliency(
        on: image,
        blurAmount: blurAmount,
        dilateRadius: dilateRadius,
        featherRadius: featherRadius
    ) {
        self.processedImage = result
      }
    }
  }
  private func processEnzy(on image: UIImage) {
      if let result = SaliencyManager.shared.runEzaldeen(on: image) {
        self.processedImage = result
      }
  }
}
#Preview {
  SaliencyColorFillView()
}
