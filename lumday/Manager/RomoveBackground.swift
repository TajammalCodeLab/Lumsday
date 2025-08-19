//
//  RomoveBackground.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//

import SwiftUI
import CoreML
import Foundation
import Vision

class RomoveBackground: ObservableObject {
  private let model = try! VNCoreMLModel(for: DeepLabV3(configuration: MLModelConfiguration()).model)
  var inputImage: UIImage = UIImage()
  @Published var outputImage: UIImage?

  func removeBackground() {
    guard let cgImage = inputImage.cgImage else { return }

    var requestHandler: VNCoreMLRequest
    requestHandler = VNCoreMLRequest(model: model, completionHandler: visionRequestDidCompete)
    requestHandler.imageCropAndScaleOption = .scaleFill

    let handler = VNImageRequestHandler(cgImage: cgImage)
    DispatchQueue.global().async {
      do {
        try handler.perform([requestHandler])

      } catch {
        print("Failed to perform request: \(error.localizedDescription)")
      }
    }
  }

  func visionRequestDidCompete(request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      if let oberservation = request.results as? [VNCoreMLFeatureValueObservation],
         let segmentMap = oberservation.first?.featureValue.multiArrayValue {
        let segMark = segmentMap.image(min: 0, max: 1)
        self.outputImage = segMark?.resized(to: self.inputImage.size)

      }

    }
  }
  func maskInputImage()-> UIImage {
    let bgImage = UIImage.imageFromColor(color: .blue,size: self.inputImage.size, scale: self.inputImage.scale)!
    let begingImage = CIImage(cgImage: inputImage.cgImage!)
    let backgrount = CIImage(cgImage: bgImage.cgImage!)
    let mask = CIImage(cgImage: (self.outputImage?.cgImage!)!)
    if let compositeImage = CIFilter(name:  "CIBlendWithMask", parameters: [
      kCIInputImageKey : begingImage,
      kCIInputBackgroundImageKey : backgrount,
      kCIOutputImageKey : mask
    ])?.outputImage {
      let ciContent = CIContext(options: nil)
      let filteredImage = ciContent.createCGImage(compositeImage, from: compositeImage.extent)
      return UIImage(cgImage: filteredImage!)

    }
    return UIImage()
  }
}
