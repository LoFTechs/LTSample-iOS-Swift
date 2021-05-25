//
//  UIImage+Extension.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/26.
//

import UIKit

extension UIImage {
    func scalePreservingAspectRatio(_ targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func scaleToLimit(_ length: CGFloat) -> UIImage {
        if size.width < length && size.height < length {
            return self
        }
        
        if size.width > size.height {
            let target = CGSize(width: length, height: size.height / size.width * length)
            return scalePreservingAspectRatio(target)
        }
        
        let target = CGSize(width: size.width / size.height * length, height: length)
        return scalePreservingAspectRatio(target)
    }
}
