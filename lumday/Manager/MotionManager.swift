//
//  MotionManager.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI
import AVFoundation
import CoreMotion

// MARK: - Motion Manager
class MotionManager: ObservableObject {
  private let motion = CMMotionManager()
  @Published var offsetX: Double = 0
  @Published var offsetY: Double = 0
  @Published var isAligned: Bool = false
  
  private let tolerance: Double = 10 // pixels
  
  func startUpdates() {
    motion.deviceMotionUpdateInterval = 1.0 / 60.0
    motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
      guard let self = self, let data = data else { return }
      
      let pitch = data.attitude.pitch * 180 / .pi
      let roll = data.attitude.roll * 180 / .pi
      
      self.offsetX = roll * 2
      self.offsetY = pitch * 2
      
      self.isAligned = abs(self.offsetX) < self.tolerance &&
      abs(self.offsetY) < self.tolerance
    }
  }
  
  func stopUpdates() {
    motion.stopDeviceMotionUpdates()
  }
}


// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
  let session = AVCaptureSession()
  private let output = AVCapturePhotoOutput()
  var onPhotoCaptured: ((UIImage) -> Void)?
  
  func startSession() {
    session.beginConfiguration()
    guard let device = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: device)
    else { return }
    
    if session.canAddInput(input) { session.addInput(input) }
    if session.canAddOutput(output) { session.addOutput(output) }
    
    session.commitConfiguration()
    DispatchQueue.global().async {
      self.session.startRunning()
    }
  }
  
  func stopSession() {
    session.stopRunning()
  }
  
  func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    output.capturePhoto(with: settings, delegate: self)
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let data = photo.fileDataRepresentation(),
          let image = UIImage(data: data) else { return }
    onPhotoCaptured?(image)
  }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    let preview = AVCaptureVideoPreviewLayer(session: session)
    preview.videoGravity = .resizeAspectFill
    preview.frame = view.bounds
    view.layer.addSublayer(preview)
    DispatchQueue.main.async {
      preview.frame = view.bounds
    }
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}
