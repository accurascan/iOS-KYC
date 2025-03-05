//
//  VideoCameraWrapperDelegate.h
//  AccuraSDK
//
//  Created by Chang Alex on 1/26/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecType) {
    REC_INIT = 1001,
    REC_BOTH,
    REC_FACE,
    REC_MRZ
};

typedef NS_ENUM(NSUInteger, RecogType) {
    OCR,
    PDF417,
    MRZ
};

@protocol VideoCameraWrapperDelegate <NSObject>
@optional
-(void)processedImage:(UIImage*)image;
-(void)recognizeFailed:(NSString*)message;
-(void)reco_msg:(NSString*)message;
-(void)onUpdateLayout:(CGSize)frameSize :(float)borderRatio;
-(void)recognizeSucceedMICR:(NSString*)scanedInfo photoImage:(UIImage*)photoImage;
@end
