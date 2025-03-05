//
//  NSFaceRegion.swift
//  AccuraSDK
//
//  Created by Chang Alex on 1/26/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//

import UIKit

public class NSFaceRegion: NSObject {
    var face = 0
    var bound: CGRect = .zero
    var confidence: Double = 0.0
    var feature: NSData = NSData()
    var image: UIImage? = nil
    
    override init() {
        super.init()
    }
}
