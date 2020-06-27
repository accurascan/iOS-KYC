//
//  ImageHelper.swift
//  AccuraSDK
//
//  Created by Chang Alex on 1/26/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//

import UIKit

func alphaOffset(_ x: Int, _ y: Int, _ w: Int) -> Int {
    return y * w * 4 + x * 4 + 0
}

func redOffset(_ x: Int, _ y: Int, _ w: Int) -> Int {
    return y * w * 4 + x * 4 + 1
}

func greenOffset(_ x: Int, _ y: Int, _ w: Int) -> Int {
    return y * w * 4 + x * 4 + 2
}

func blueOffset(_ x: Int, _ y: Int, _ w: Int) -> Int {
    return y * w * 4 + x * 4 + 3
}

func CreateARGBBitmapContext(size: CGSize) -> CGContext? {
    let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    return context
}

func CreateRGBBitmapContext(size: CGSize) -> CGContext? {
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 3, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    return context
}

func addRoundedRectToContext(context: CGContext, rect: CGRect, oval: CGSize) {
    if oval.width == 0.0 || oval.height == 0.0
    {
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.addRect(rect)
        context.closePath()
        context.restoreGState()
        return
    }
    
    context.saveGState()
    context.translateBy(x: rect.minX, y: rect.minY)
    context.scaleBy(x: oval.width, y: oval.height)
    let fw = rect.width / oval.width
    let fh = rect.height / oval.height
    
    context.move(to: CGPoint(x: fw, y: fh/2))
    context.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw / 2, y: fh), radius: 1)
    context.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: 0, y: fh / 2), radius: 1)
    context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: fw / 2, y: 0), radius: 1)
    context.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw, y: fh / 2), radius: 1)
    
    context.closePath()
    context.restoreGState()
}

func flipContextVertically(context: CGContext, size: CGSize) {
    var transform = CGAffineTransform.identity
    transform = transform.scaledBy(x: 1.0, y: -1.0)
    transform = transform.translatedBy(x: 0.0, y: -size.height)
    context.concatenate(transform)
}

func newBitmapRGBA8Context(from image: CGImage) -> CGContext? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bitsPerPixels = 32
    let bitsPerComponent = 8
    let bytesPerPixel = bitsPerPixels / bitsPerComponent
    
    let width = Int(image.width)
    let height = Int(image.height)
    
    let bytesPerRow = width * bytesPerPixel
    let bufferLength = bytesPerRow * height
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
    
    return context
}

func isMirrored(image: UIImage) -> Bool {
    if image.imageOrientation == .upMirrored || image.imageOrientation == .leftMirrored || image.imageOrientation == .rightMirrored || image.imageOrientation == .downMirrored {
        return true
    }
    
    return false
}

func isRotated90(image: UIImage) -> Bool {
    switch (image.imageOrientation) {
    case .leftMirrored:
        return true
    case .leftMirrored:
        return true
    case .right:
        return true
    case .rightMirrored:
        return true
    default:
        return false
    }
}

public class ImageHelper: NSObject {
    
    override init() {
        super.init()
    }
    
    static func imageFromView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func image(with bits: NSData, size: CGSize) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: UnsafeMutableRawPointer(mutating: bits.bytes), width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue | CGBitmapInfo.byteOrder16Big.rawValue)
        
        guard let cgImage = context?.makeImage() else { return nil }
        
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
    
    static func bitmapData(from image: UIImage) -> NSData? {
        guard let context = CreateARGBBitmapContext(size: image.size) else { return nil }
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        guard let cgImage = image.cgImage else { return nil }
        context.draw(cgImage, in: rect)
        
        guard let data = UnsafeRawPointer(context.data) else { return nil }
        
        let result = NSData(bytes: data, length: Int(image.size.width * image.size.height))
        
        return result
    }
    
    static func fitSize(thisSize: CGSize, inSize aSize: CGSize) -> CGSize {
        var scale: CGFloat = 1.0
        var newSize = thisSize
        
        if newSize.height > 0 && (newSize.height > aSize.height) {
            scale = aSize.height / newSize.height
            newSize.width *= scale
            newSize.height *= scale
        }
        
        if newSize.width > 0 && (newSize.width >= aSize.width) {
            scale = aSize.width / newSize.width
            newSize.width *= scale
            newSize.height *= scale
        }
        
        return newSize
    }
    
    static func frameSize(thisSize: CGSize, inSize aSize: CGSize) -> CGRect {
        let size = self.fitSize(thisSize: thisSize, inSize: aSize)
        let dWidth = aSize.width - size.width
        let dHeight = aSize.height - size.height
        
        return CGRect(x: dWidth / 2, y: dHeight / 2, width: size.width, height: size.height)
    }
    
    static func unrotateImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        var size = image.size
        
        if isRotated90(image: image) {
            size = CGSize(width: image.size.height, height: image.size.width)
        }
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .left, .leftMirrored:
            transform = transform.rotated(by: .pi / 2.0)
            transform = transform.translatedBy(x: 0.0, y: -size.width)
            size = CGSize(width: size.height, height: size.width)
            context?.concatenate(transform)
        case .right, .rightMirrored:
            transform = transform.rotated(by: -.pi / 2.0)
            transform = transform.translatedBy(x: -size.height, y: 0.0)
            size = CGSize(width: size.height, height: size.width)
            context?.concatenate(transform)
        case .down, .downMirrored:
            transform = transform.rotated(by: .pi)
            transform = transform.translatedBy(x: -size.width, y: -size.height)
            size = CGSize(width: size.height, height: size.width)
            context?.concatenate(transform)
        default:
            break
        }
        
        if (isMirrored(image: image)) {
            transform = CGAffineTransform(translationX: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            context?.concatenate(transform)
        }
        
        image.draw(at: CGPoint(x: 0, y: 0))
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newimage
    }
    
    static func fit(image: UIImage, inSize viewSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(viewSize)
        image.draw(in: ImageHelper.frameSize(thisSize: image.size, inSize: viewSize))
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newimg;
    }
    
    static func fit(image: UIImage, inView view: UIView) -> UIImage? {
        return ImageHelper.fit(image: image, inSize: view.frame.size)
    }
    
    static func crop(image: UIImage, rect cropRect: CGRect) -> UIImage? {
        let size = image.size
        let viewsize = cropRect.size
        
        UIGraphicsBeginImageContext(viewsize);

        let rect = CGRect(x: -cropRect.origin.x, y: -cropRect.origin.y, width: size.width, height: size.height);
        image.draw(in: rect)
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newimg
    }
    
    static func center(image: UIImage, inSize viewsize: CGSize) -> UIImage? {
        let size = image.size;
        
        UIGraphicsBeginImageContext(viewsize);
        let dwidth = (viewsize.width - size.width) / 2.0
        let dheight = (viewsize.height - size.height) / 2.0
        
        let rect = CGRect(x: dwidth, y: dheight, width: size.width, height: size.height)
        
        image.draw(in: rect)
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newimg
    }
    
    static func center(image: UIImage, inView view: UIView) -> UIImage? {
        return ImageHelper.center(image: image, inSize: view.frame.size)
    }
    
    static func fill(image: UIImage, inSize viewsize: CGSize) -> UIImage? {
        let size = image.size;
        
        let scalex = viewsize.width / size.width
        let scaley = viewsize.height / size.height
        let scale = [scalex, scaley].max() ?? scalex
        
        UIGraphicsBeginImageContext(viewsize);
        
        let width = size.width * scale;
        let height = size.height * scale;
        
        let dwidth = (viewsize.width - width) / 2.0
        let dheight = (viewsize.height - height) / 2.0
            
        let rect = CGRect(x: dwidth, y: dheight, width: size.width * scale, height: size.height * scale);
        image.draw(in: rect)
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newimg
    }
    
    static func fill(image: UIImage, inView view: UIView) -> UIImage? {
        return ImageHelper.fill(image: image, inSize: view.frame.size)
    }
    
    static func addRound(toContext context: CGContext, rect: CGRect, ovalSize: CGSize) {
        addRoundedRectToContext(context: context, rect: rect, oval: ovalSize)
    }
    
    static func roundedImage(image: UIImage, ovalSize: CGSize, inset: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(x: inset, y: inset, width: image.size.width - inset * 2.0, height: image.size.height - inset * 2.0);
        addRoundedRectToContext(context: context, rect: rect, oval: ovalSize);
        
        context.clip()
        image.draw(in: rect)
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newimg
    }
    
    static func roundedImage(image: UIImage, ovalSize: CGSize) -> UIImage? {
        return ImageHelper.roundedImage(image: image, ovalSize: ovalSize, inset: 0.0)
    }
    
    static func roundedBacksplashOfSize(size: CGSize, color: UIColor, rounding: CGFloat, inset: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let rect = CGRect(x: inset, y: inset, width: size.width - 2.0 * inset, height: size.height - 2.0 * inset)
        addRoundedRectToContext(context: context, rect: rect, oval: CGSize(width: rounding, height: rounding))
        context.setFillColor(color.cgColor)
        context.fillPath()
        context.clip()
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimg
    }
    
    static func ellipseImage(image: UIImage, inset: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect(x: inset, y: inset, width: image.size.width - inset * 2.0, height: image.size.height - inset * 2.0)
        context?.addEllipse(in: rect)
        context?.clip()
        
        image.draw(in: rect)
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimg
    }
}
