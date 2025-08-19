//
//  BeforeAfterImageScrollView.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI

struct BeforeAfterImageScrollView: View {
    let originalImage: UIImage?
    let processedImage: UIImage?
    let imageSize: CGSize
    
    init(originalImage: UIImage?, processedImage: UIImage?, imageSize: CGSize = CGSize(width: 250, height: 250)) {
        self.originalImage = originalImage
        self.processedImage = processedImage
        self.imageSize = imageSize
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let img = originalImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                if let highlighted = processedImage {
                    Image(uiImage: highlighted)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
    }
}
