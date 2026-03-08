//
//  CIImageExtension.swift
//  QRCode
//
//  Created by Jaiouch Yaman - Société ID-APPS on 18/12/2015.
//  Copyright © 2015 Alexander Schuch. All rights reserved.
//

import Foundation
import UIKit

internal typealias Scale = (dx: CGFloat, dy: CGFloat)

internal extension CIImage {

    /// Creates an `UIImage` with interpolation disabled and scaled given a scale property
    ///
    /// - parameter withScale:  a given scale using to resize the result image
    ///
    /// - returns: an non-interpolated UIImage
    func nonInterpolatedImage(withScale scale: Scale = Scale(dx: 1, dy: 1)) -> UIImage? {
        guard let cgImage = CIContext(options: nil).createCGImage(self, from: self.extent) else { return nil }
        let size = CGSize(width: self.extent.size.width * scale.dx, height: self.extent.size.height * scale.dy)

        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let context = ctx.cgContext
            context.interpolationQuality = .none
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(cgImage, in: context.boundingBoxOfClipPath)
        }
    }
}
