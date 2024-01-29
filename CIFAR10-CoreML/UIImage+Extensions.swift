//
//  UIImage+Extensions.swift
//  mobilenetv2
//
//  Created by yukiharada on 2024/01/28.
//

import UIKit
import VideoToolbox


extension UIImage {
    
    func croppedToSquare() -> UIImage {
        let cgImage = self.cgImage!
        let shorterSide = min(self.size.width, self.size.height)
        let croppedRect = CGRect(
            x: (self.size.width - shorterSide) / 2,
            y: (self.size.height - shorterSide) / 2,
            width: shorterSide,
            height: shorterSide
        )
        if let croppedCGImage = cgImage.cropping(to: croppedRect) {
            return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
        }
        return self
    }
    
    func resizedTo(size :CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func croppedSquareAndResizedTo(size: CGSize) -> UIImage {
        let croppedImage = self.croppedToSquare()
        return croppedImage.resizedTo(size: size)
    }
    
    func toBuffer() -> CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    public convenience init?(fromPixelBuffer pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
