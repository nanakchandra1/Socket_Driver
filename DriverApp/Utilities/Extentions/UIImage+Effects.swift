//
//  UIImage+Effects.swift
//  PetTracker
//
//  Created by Gurdeep Singh on 14/02/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//


// BlurrImage

import UIKit
import QuartzCore
import Accelerate

extension UIImage {
    
    class func blurEffect(_ cgImage: CGImage) -> UIImage! {
        return UIImage(cgImage: cgImage)
    }
    
    func blurEffect(_ boxSize: Float) -> UIImage! {
        return UIImage(cgImage: blurredCGImage(boxSize))
    }
    
    func blurredCGImage(_ boxSize: Float) -> CGImage! {
        return cgImage!.blurEffect(boxSize)
    }
    
    func resizeImage(_ newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func blurredImage(_ boxSize: Float, times: UInt = 1) -> UIImage {
        
        var image = self
        
        for _ in 0..<times {
            image = image.blurEffect(boxSize)
        }
        
        return image
    }
    
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
       
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch self.imageOrientation {
       
        case .up,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
      
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        
        default: break
            
        }
        
        switch self.imageOrientation {
        
        case .upMirrored,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        
        case .leftMirrored,.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        
        default: break
        
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        switch self.imageOrientation {
        
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
    }

}

extension CGImage {
    
    func blurEffect(_ boxSize: Float) -> CGImage! {
        
        let boxSize = boxSize - (boxSize.truncatingRemainder(dividingBy: 2)) + 1
        
        let inProvider = self.dataProvider
        
        let height = vImagePixelCount(self.height)
        let width = vImagePixelCount(self.width)
        let rowBytes = self.bytesPerRow
        
        let inBitmapData = inProvider!.data
        let inData = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(self.bytesPerRow * self.height)
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        _ = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self))
        let context = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: self.bitmapInfo.rawValue)!
        let imageRef = context.makeImage()
        
        free(outData)
        
        return imageRef
    }
}
