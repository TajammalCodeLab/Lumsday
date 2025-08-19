//
//  SaliencyManager.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//

import Foundation
import SwiftUI
import Vision
import CoreImage
import BackgroundRemoval

class SaliencyManager {
  static let shared = SaliencyManager()
  private let context = CIContext()
  
  /// Main Vision call
  func runSaliency(
    on image: UIImage,
    blurAmount: Double = 0,
    dilateRadius: Double = 0,
    featherRadius: Double = 3
  ) async -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    
    let request = VNGenerateObjectnessBasedSaliencyImageRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    do {
      try handler.perform([request])
      guard let observation = request.results?.first as? VNSaliencyImageObservation else { return nil }
      
      return self.applyMask(
        on: image,
        mask: observation.pixelBuffer,
        blurAmount: blurAmount,
        dilateRadius: dilateRadius,
        featherRadius: featherRadius)
    } catch {
      print("Vision error:", error.localizedDescription)
      return nil
    }
  }
  
  /// Apply Vision mask with refinement
  func applyMask(
    on image: UIImage,
    mask: CVPixelBuffer,
    blurAmount: Double,
    dilateRadius: Double,
    featherRadius: Double
  ) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    var maskImage = CIImage(cvPixelBuffer: mask)
    
    // Scale mask to match image size
    maskImage = maskImage.transformed(
      by: CGAffineTransform(scaleX: ciImage.extent.width / maskImage.extent.width,
                            y: ciImage.extent.height / maskImage.extent.height)
    )
    
    // 🔥 Step 1: Initial smoothing
    if blurAmount > 0 {
      maskImage = maskImage
        .clampedToExtent()
        .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: blurAmount])
        .cropped(to: ciImage.extent)
    }
    
    // 🔥 Step 2: Dilation
    if dilateRadius > 0 {
      maskImage = maskImage
        .applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: dilateRadius])
    }
    
    // 🔥 Step 3: Feather edges
    if featherRadius > 0 {
      maskImage = maskImage
        .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: featherRadius])
    }
    
    // Transparent background
    let transparentBackground = CIImage(color: .clear).cropped(to: ciImage.extent)
    
    // Blend with mask
    let masked = ciImage.applyingFilter("CIBlendWithMask", parameters: [
      kCIInputMaskImageKey: maskImage,
      kCIInputBackgroundImageKey: transparentBackground
    ])
    
    if let cgImage = context.createCGImage(masked, from: masked.extent) {
      var ciImage = CIImage(cgImage: cgImage)
      
      // Apply green tint
      ciImage = ciImage.applyingFilter("CIColorMonochrome", parameters: [
        kCIInputColorKey: CIColor(red: 0, green: 1, blue: 0), // Pure green
        kCIInputIntensityKey: 10000
      ])
      
      if let tintedCG = context.createCGImage(ciImage, from: ciImage.extent) {
        return UIImage(cgImage: tintedCG)
      }
    }
    
    return nil
  }
  func runEzaldeen(on image: UIImage) -> UIImage? {
      let backgroundRemoval = BackgroundRemoval()
      do {
          let processedImage = try backgroundRemoval.removeBackground(image: image, maskOnly: true)
          return processedImage
      } catch {
          print("Background removal error: \(error.localizedDescription)")
          return nil
      }
  }
}
