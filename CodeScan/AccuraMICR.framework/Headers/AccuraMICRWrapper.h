//
//  VideoCameraWrapper.h
//  AccuraSDK
//
//  Created by Chang Alex on 1/26/20.
//  Copyright © 2020 Elite Development LLC. All rights reserved.
//
#if !TARGET_OS_WATCH
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VideoCameraWrapperDelegate.h"
#import "SDKModels.h"

typedef NS_ENUM(NSUInteger, CameraFacing)
{
    CAMERA_FACING_BACK,
    CAMERA_FACING_FRONT
};

typedef NS_ENUM(NSUInteger, CardSide)
{
    BACK_CARD_SCAN,
    FRONT_CARD_SCAN
};

typedef NS_ENUM(NSUInteger, BarcodeType)
{
    ean8,
    ean13,
    pdf417,
    aztec,
    code128,
    code39,
    code93,
    dataMatrix,
    upca,
    itf,
    qrcode,
    upce,
    codabar,
    all
};

typedef NS_ENUM(NSInteger, MICRTYPE) {
    E13B,
    CMC7,
};

@interface AccuraMICRWrapper : NSObject

{
    CameraFacing Camerafacing;
    CardSide ScanCard;
    BarcodeType barCodeType;
    MICRTYPE micrType;
    BOOL _isCapturing;
    BOOL _isMotion;
    NSThread *thread;
//    SDKModel sdkm;
}


@property (nonatomic, strong) id<VideoCameraWrapperDelegate> delegate;


//@property NSMutableDictionary *ocrDataSet;
//@property(nullable, nonatomic) MLKDigitalInkRecognizer *recognizer;
//@property(nullable, nonatomic) NSMutableArray<MLKStroke *> *strokes;
//@property(nullable, nonatomic) NSMutableArray<MLKStrokePoint *> *points;

- (SDKModels *)loadEngine:(NSString *)url;
- (SDKModels *)loadEngine:(NSString *)path documentDirectory:(NSString *)url;

-(id)initWithDelegate:(UIViewController<VideoCameraWrapperDelegate>*)delegate andImageView:(UIImageView *)iv andLabelMsg:(UILabel*)l andurl:(NSString*)url type:(MICRTYPE) micrType;

-(void)startCamera;
-(void)stopCamera;
-(void)stopCameraPreview;
-(void)startCameraPreview;
-(void)ChangedOrintation:(CGFloat)width height:(CGFloat)height;

-(void)processWithArray:(NSArray*)imageDataArray andarrTextData:(NSArray*)ad;

-(void)processWithBack1:(NSString*)stCard  andisCheckBack:(bool)isCheckBack;

-(void)bankBiffNumber:(int)bankCode;

-(void)setGlarePercentage:(int)intMin intMax:(int)intMax;
-(void)accuraSDK;
-(void)SetCameraFacing:(CameraFacing)camera;
-(void)SwitchCamera;
-(void)setBlurPercentage:(int)blur;
//-(void)showLogFile:(bool)isShowLogs;
-(void)CloseOCR;
-(NSString *)getMRZSDKVersion;
- (void)updateView:(UIView *)msg;
-(void)restartMICR;
@end
#endif
