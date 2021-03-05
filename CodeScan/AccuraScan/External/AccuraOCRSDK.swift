//
//  AccuraOCRSDK.swift
//  AccuraSDK
//
//  Created by Technozer on 30/06/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//

import Foundation
import AccuraOCR
import Firebase
public class AccuraOCRSDK: NSObject {
    
   public static func configure() -> Void{
    
        var accuraCameraWrapper: AccuraCameraWrapper? = nil
        accuraCameraWrapper = AccuraCameraWrapper.init()
        accuraCameraWrapper?.showLogFile(true) // Set true to print log from KYC SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            accuraCameraWrapper?.accuraSDK()
        }
//        FirebaseApp.configure()
    }
}
