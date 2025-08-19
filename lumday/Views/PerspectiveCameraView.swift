//
//  PerspectiveCameraView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI
import AVFoundation
import CoreMotion

// MARK: - Main Camera View
struct PerspectiveCameraView: View {
  var onImagePicked: (UIImage) -> Void
  @StateObject private var motionManager = MotionManager()
  @StateObject private var cameraManager = CameraManager()
  
  @State private var showTipSheet = false
  @State private var isTorchOn = false
  @State private var showCapturedView = false
  
  var body: some View {
    ZStack {
      CameraPreview(session: cameraManager.session)
        .ignoresSafeArea()
      
      // Overlay Dots
      GeometryReader { geo in
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        
        Circle()
          .fill(Color.green)
          .frame(width: 14, height: 14)
          .padding()
          .overlay(Circle().stroke(motionManager.isAligned ? Color.green : Color.red, lineWidth: 1))
          .position(center)
        
        Circle()
          .fill(motionManager.isAligned ? Color.green : Color.red)
          .frame(width: 14, height: 14)
          .position(
            x: center.x + CGFloat(motionManager.offsetX),
            y: center.y + CGFloat(motionManager.offsetY)
          )
          .animation(.easeInOut(duration: 0.1), value: motionManager.offsetX)
      }
      
      // Capture and control buttons
      VStack {
        Spacer()
        HStack(spacing: 40) {
          Button(action: toggleTorch) {
            Image(systemName: isTorchOn ? "bolt.fill": "bolt.slash.fill")
              .foregroundColor(.white)
              .padding(10)
              .background(Color.black.opacity(0.5))
              .cornerRadius(8)
          }
          
          Button(action: {
            cameraManager.capturePhoto()
          }) {
            Circle()
              .fill(motionManager.isAligned ? Color.white : Color.gray)
              .frame(width: 60, height: 60)
              .overlay(Circle().stroke(Color.black, lineWidth: 2))
          }
          .disabled(!motionManager.isAligned)
          
          Button(action: {
            showTipSheet = true
          }) {
            Text("Tip")
              .foregroundColor(.white)
              .padding(10)
              .background(Color.black.opacity(0.5))
              .cornerRadius(8)
          }
        }
        .padding(.bottom, 30)
      }
    }
    .onAppear {
      cameraManager.startSession()
      motionManager.startUpdates()
      cameraManager.onPhotoCaptured = { image in
        onImagePicked(image)
        showCapturedView = true
      }
    }
    .onDisappear {
      cameraManager.stopSession()
      motionManager.stopUpdates()
      if isTorchOn {
        toggleTorch()
      }
    }
    .overlay {
      if showTipSheet {
        TipSheetView(isPresented: $showTipSheet)
      }
    }
    
  }
  
  private func toggleTorch() {
    guard let device = AVCaptureDevice.default(for: .video),
          device.hasTorch else { return }
    
    do {
      try device.lockForConfiguration()
      if device.torchMode == .on {
        device.torchMode = .off
        isTorchOn = false
      } else {
        try device.setTorchModeOn(level: 1.0)
        isTorchOn = true
      }
      device.unlockForConfiguration()
    } catch {
      print("Torch could not be used: \(error.localizedDescription)")
    }
  }
}
