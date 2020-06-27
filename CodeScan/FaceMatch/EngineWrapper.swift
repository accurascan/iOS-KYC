//
//  EngineWrapper.swift
//  AccuraSDK
//
//  Created by Chang Alex on 1/26/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//

import UIKit

var g_nEngineInit = -100

class EngineWrapper {
    static func faceEngineInit() {
        let dataFilePath1 = Bundle.main.path(forResource: "model1", ofType: "dat")
        let dataFilePath2 = Bundle.main.path(forResource: "model2", ofType: "dat")
        let licensePath = Bundle.main.path(forResource: "accuraface", ofType: "license")
        
        if licensePath == nil || licensePath == "" {
            g_nEngineInit = -20
            return
        }
        
        let ret = InitEngine((dataFilePath1! as NSString).utf8String,
                             (dataFilePath2! as NSString).utf8String,
                             (licensePath! as NSString).utf8String)
        
        g_nEngineInit = Int(ret.rawValue)
    }
    
    static func isEngineInit() -> Bool {
        return g_nEngineInit == Int(wOK.rawValue)
    }
    
    static func getEngineInitValue() -> Int {
        return g_nEngineInit
    }
    
    /**
    * This method use for identify face match score.
    * Parameters to Pass: front image data and back image data.
    *
    * This method will return int score.
    */
    static func identify(_ pbuff1: NSData?, feature2 pbuff2: NSData?) -> Float {
        let len1 = Int32(pbuff1?.count ?? 0)
        let len2 = Int32(pbuff2?.count ?? 0)
        
        var score: Float = 0.0
        
        if len1 == 0 || len2 == 0 {
            return 0.0
        }
        
        
        let buff1: UnsafeMutablePointer<Float> = Data(referencing: pbuff1!).withUnsafeBytes({ ptr -> UnsafeMutablePointer<Float> in
            return UnsafeMutablePointer(mutating: ptr)
        })
        
        let buff2: UnsafeMutablePointer<Float> = Data(referencing: pbuff2!).withUnsafeBytes({ ptr -> UnsafeMutablePointer<Float> in
            return UnsafeMutablePointer(mutating: ptr)
        })
        
        let ret = Identify(len1, buff1, len2, buff2, &score)
        
        if ret != wOK {
            return 0.0
        }
        
        return score
    }
    
    /**
    * This method use for identify face in front image.
    * Parameters to Pass: front image data
    *
    * This method will return image.
    */
    static func detectSourceFaces(_ image: UIImage?) -> NSFaceRegion? {
        if !self.isEngineInit() {
            return nil
        }
        
        guard let image = image else { return nil }
        
        let region = NSFaceRegion()
        region.image = nil
        
        guard let inbits = ImageHelper.bitmapData(from: image) else { return nil }
        
        let inBuff: UnsafeMutablePointer<BYTE> = Data(referencing: inbits).withUnsafeBytes({ ptr -> UnsafeMutablePointer<BYTE> in
            return UnsafeMutablePointer(mutating: ptr)
        })
        
        let imgSize = (image.size.width * 32 + 31) / 32 * 4 * image.size.height
        let imgWidth = image.size.width
        let imgHeight = image.size.height
        
        var nFaceCount: Int32 = 0
        
        var pFaces = SFaceExt()
        let ret = DetectSourceFace(inBuff, DWORD(imgSize), DWORD(imgWidth), DWORD(imgHeight), &nFaceCount, &pFaces)
        
        if ret == wOK {
            if nFaceCount > 0 {
                let rect = pFaces.Rectangle
                let fx = CGFloat(rect.X)
                let fy = CGFloat(rect.Y)
                
                let fw = CGFloat(rect.Width)
                let fh = CGFloat(rect.Height)
                
                region.bound = CGRect(x: fx, y: fy, width: fw, height: fh)
                
                region.confidence = pFaces.Confidence
                region.face = 1
                
                let buff: UnsafeMutableRawPointer = withUnsafeMutablePointer(to: &pFaces.featureData) { ptr -> UnsafeMutableRawPointer in
                    return UnsafeMutableRawPointer(ptr)
                }
                
                region.feature = NSData(bytes: buff, length: Int(pFaces.nFeatureSize) * MemoryLayout<Float>.size)
            }
        }
        
        region.image = image
        
        return region
    }
    
    /**
    * This method use for identify face in back image which found in front image.
    * Parameters to Pass: back image and front image data
    *
    * This method will return image.
    */
    static func detectTargetFaces(_ image: UIImage?, feature: NSData?) -> NSFaceRegion? {
        guard let image = image else { return nil }
        
        if !self.isEngineInit() {
            return nil
        }
        
        let region = NSFaceRegion()
        region.image = nil
        
        guard let inbits = ImageHelper.bitmapData(from: image) else { return nil }
        
        let inBuff: UnsafeMutablePointer<BYTE> = Data(referencing: inbits).withUnsafeBytes({ ptr -> UnsafeMutablePointer<BYTE> in
            return UnsafeMutablePointer(mutating: ptr)
        })
        
        let imgSize = (image.size.width * 32 + 31) / 32 * 4 * image.size.height
        let imgWidth = image.size.width
        let imgHeight = image.size.height
        
        var nFaceCount: Int32 = 0
        
        let featureBuff: UnsafeMutablePointer<Float> = Data(referencing: feature ?? NSData()).withUnsafeBytes({ ptr -> UnsafeMutablePointer<Float> in
            return UnsafeMutablePointer(mutating: ptr)
        })
        
        var pFaces = SFaceExt()
        let ret = DetectTargetFace(inBuff, DWORD(imgSize), DWORD(imgWidth), DWORD(imgHeight), &nFaceCount, &pFaces, featureBuff)
        
        if ret == wOK {
            if nFaceCount > 0 {
                let rect = pFaces.Rectangle
                let fx = CGFloat(rect.X)
                let fy = CGFloat(rect.Y)
                
                let fw = CGFloat(rect.Width)
                let fh = CGFloat(rect.Height)
                
                region.bound = CGRect(x: fx, y: fy, width: fw, height: fh)
                
                region.confidence = pFaces.Confidence
                region.face = 1
                
                let buff: UnsafeMutableRawPointer = withUnsafeMutablePointer(to: &pFaces.featureData) { ptr -> UnsafeMutableRawPointer in
                    return UnsafeMutableRawPointer(ptr)
                }
                
                region.feature = NSData(bytes: buff, length: Int(pFaces.nFeatureSize) * MemoryLayout<Float>.size)
            }
        }
        
        region.image = image
        
        return region
    }
    
    static func faceEngineClose() {
        if self.isEngineInit() == false {
            return
        }
        
        g_nEngineInit = -100
        CloseEngine()
    }
}
