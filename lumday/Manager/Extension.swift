//
//  Extension.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//

import SwiftUI
import Foundation
extension UIImage {
  class func imageFromColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    color.setFill()
    UIRectFill(CGRect(origin: CGPoint.zero, size: size))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}
