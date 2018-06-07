//
//  UIViewExtention.swift
//  iHearU
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore



// Mark: UIView extension to create traingle
extension UIView {
    
    func addSlope(withColor color: UIColor, ofWidth width: CGFloat = 50, ofHeight height: CGFloat = 50) {

        // Make path to draw traingle
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        // Add path to the mask
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        // Adding shape to view's layer
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path.cgPath
        shape.fillColor = color.cgColor
        
        self.layer.insertSublayer(shape, at: 1)
    }
}


//MARK:- extension for find indexpath of tableview cell
//MARK:- ************************************

extension UIView{
    func tableViewCell() -> UITableViewCell? {
        var tableViewcell : UIView? = self
        while(tableViewcell != nil)
        {
            if tableViewcell! is UITableViewCell {
                break
            }
            tableViewcell = tableViewcell!.superview
        }
        return tableViewcell as? UITableViewCell
    }
    
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat,rect:CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
    
    func tableViewIndexPath(_ tableView: UITableView) -> IndexPath? {
        if let cell = self.tableViewCell() {
            return tableView.indexPath(for: cell)
        }
        else {
            return nil
        }
    }
}

//extension UIImage {
//    
//    class func blurEffect(cgImage: CGImageRef) -> UIImage! {
//        return UIImage(CGImage: cgImage)
//    }
//    
//    func blurEffect(boxSize: Float) -> UIImage! {
//        return UIImage(CGImage: blurredCGImage(boxSize))
//    }
//    
//    func blurredCGImage(boxSize: Float) -> CGImageRef! {
//        return CGImage!.blurEffect(boxSize)
//    }
//    
//    func resizeImage(newSize: CGSize) -> UIImage {
//        
//        UIGraphicsBeginImageContext(newSize)
//        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//    func blurredImage(boxSize: Float, times: UInt = 1) -> UIImage {
//        
//        var image = self
//        
//        for _ in 0..<times {
//            image = image.blurEffect(boxSize)
//        }
//        
//        return image
//    }
//    
//    func fixOrientation() -> UIImage {
//        
//        if self.imageOrientation == UIImageOrientation.Up {
//            return self
//        }
//        
//        var transform: CGAffineTransform = CGAffineTransformIdentity
//        
//        switch self.imageOrientation {
//            
//        case .Up,.DownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
//            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
//            
//        case .Left,.LeftMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
//            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
//            
//        case .Right,.RightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
//            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
//            
//        default: break
//            
//        }
//        
//        switch self.imageOrientation {
//            
//        case .UpMirrored,.DownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
//            transform = CGAffineTransformScale(transform, -1, 1)
//            
//        case .LeftMirrored,.RightMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
//            transform = CGAffineTransformScale(transform, -1, 1)
//            
//        default: break
//            
//        }
//        
//        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)!
//        
//        CGContextConcatCTM(ctx, transform)
//        
//        switch self.imageOrientation {
//            
//        case .Left,.LeftMirrored,.Right,.RightMirrored:
//            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
//            
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
//        }
//        
//        let cgimg: CGImageRef = CGBitmapContextCreateImage(ctx)!
//        let img: UIImage = UIImage(CGImage: cgimg)
//        return img
//    }
//    
//}

//extension CGImage {
//    
//    func blurEffect(boxSize: Float) -> CGImageRef! {
//        
//        let boxSize = boxSize - (boxSize % 2) + 1
//        
//        let inProvider = CGImageGetDataProvider(self)
//        
//        let height = vImagePixelCount(CGImageGetHeight(self))
//        let width = vImagePixelCount(CGImageGetWidth(self))
//        let rowBytes = CGImageGetBytesPerRow(self)
//        
//        let inBitmapData = CGDataProviderCopyData(inProvider)
//        let inData = UnsafeMutablePointer<Void>(CFDataGetBytePtr(inBitmapData))
//        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
//        
//        let outData = malloc(CGImageGetBytesPerRow(self) * CGImageGetHeight(self))
//        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
//        
//        _ = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
//        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        //        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self))
//        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self).rawValue)!
//        let imageRef = CGBitmapContextCreateImage(context)
//        
//        free(outData)
//        
//        return imageRef
//    }
//}

