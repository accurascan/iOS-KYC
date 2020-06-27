#import <UIKit/UIKit.h>

/** Represents the resolution options for the returned audit trail image(s) */
typedef NS_ENUM(NSInteger, ZoomAuditTrailType) {
    /** Configures Zoom to disable returning audit trail images. */
    ZoomAuditTrailTypeDisabled = 1,
    /** Configures Zoom to return the full resolution image for the audit trail. */
    ZoomAuditTrailTypeFullResolution = 1,
    /** Configures Zoom to return an image of height 640 for the audit trail */
    ZoomAuditTrailTypeHeight640 = 2,
};

/** Represents the options for the blur effect styles. */
typedef NS_ENUM(NSInteger, ZoomBlurEffectStyle) {
    /** The blur effect will be off/disabled */
    ZoomBlurEffectOff = 0,
    /** The blur effect will be default style (ONLY AVAILABLE ON IOS 10+) */
    ZoomBlurEffectStyleRegular = 1,
    /** The blur effect will have a light/white-tint style */
    ZoomBlurEffectStyleLight = 2,
    /** The blur effect will have a extra light/white-tint style */
    ZoomBlurEffectStyleExtraLight = 3,
    /** The blur effect will have a dark/black-tint style */
    ZoomBlurEffectStyleDark = 4,
    /** The blur effect will have a prominent style (ONLY AVAILABLE ON IOS 10+) */
    ZoomBlurEffectStyleProminent = 5,
};

/** Represents the options for the location of the back button. */
typedef NS_ENUM(NSInteger, ZoomCancelButtonLocation) {
    /** The back button will be located in the top left */
    ZoomCancelButtonLocationTopLeft = 0,
    /** The back button will be located in the top right */
    ZoomCancelButtonLocationTopRight = 1,
    /** The back button will be disabled */
    ZoomCancelButtonLocationDisabled = 2,
};

/** Represents the options for the behavior of iPhone X's view when frame size ratio is set to 1. */
typedef NS_ENUM(NSInteger, ZoomFullScreenBehavior) {
    /** ZoOm will handle the look of the view */
    ZoomFullScreenBehaviorAutomatic = 0,
    /** Developer is in full control of the look of ZoOm */
    ZoomFullScreenBehaviorManual = 1,
};

@protocol ZoomSDKProtocol;

__attribute__((visibility("default")))
@interface Zoom: NSObject
@property (nonatomic, class, readonly, strong) id <ZoomSDKProtocol> _Nonnull sdk;
@end

@protocol ZoomFaceBiometricMetrics;
@class NSDate;

/** Represents the possible state of camera permissions. */
typedef NS_ENUM(NSInteger, ZoomCameraPermissionStatus) {
    /** The user has not yet been asked for permission to use the camera */
     ZoomCameraPermissionStatusNotDetermined = 0,
    /** The user denied the app permission to use the camera or manually revoked the app’s camera permission.
     From this state, permission can only be modified by the user from System ‘Settings’ context. */
    ZoomCameraPermissionStatusDenied = 1,
    /** The camera permission on this device has been disabled due to policy.
     From this state, permission can only be modified by the user from System ‘Settings’ context or contacting the system administrator. */
    ZoomCameraPermissionStatusRestricted = 2,
    /** The user granted permission to use the camera. */
    ZoomCameraPermissionStatusAuthorized = 3,
};

@class UIColor;
@class CAGradientLayer;
@class ZoomInstructionsImages;
@class ZoomOvalCustomization;
@class ZoomFeedbackCustomization;
@class ZoomCancelButtonCustomization;
@class ZoomFrameCustomization;

/** Configures the look and feel of Zoom.  */
__attribute__((visibility("default")))
@interface ZoomCustomization : NSObject
/** allow low-light mode, which changes the ZoOm oval colors to a 'white-theme' when a low-light environment is detected. */
@property (nonatomic) BOOL enableLowLightMode;
/** show Pre-Enrollment screens, which greet the user and provide details on the capture process. */
@property (nonatomic) BOOL showPreEnrollmentScreen;
/** show Lockout screen to user, which displays a failure screen with the remaining lockout time to the user after too many failed attempts. */
@property (nonatomic) BOOL showUserLockedScreen;
/** show Retry screen, which occurs when the user's ZoOm attempt fails within the expanded oval animation. */
@property (nonatomic) BOOL showRetryScreen;
/** color of the mainscreen, Pre-Enrollment, and Retry screens' background. */
@property (nonatomic, copy) NSArray<UIColor *> * _Nonnull mainBackgroundColors;
/** color of the mainscreen, Pre-Enrollment, and Retry screens' foreground. Default is white. */
@property (nonatomic, strong) UIColor * _Nonnull mainForegroundColor;
/** color of the action button's text during Pre-Enrollment and Retry screens. Default is white. */
@property (nonatomic, strong) UIColor * _Nonnull buttonTextNormalColor;
/** color of the action button's background during Pre-Enrollment and Retry screens. Default is clear. */
@property (nonatomic, strong) UIColor * _Nonnull buttonBackgroundNormalColor;
/** color of the action button's background when the button is pressed during Pre-Enrollment and Retry screens. Default is white, with an alpha of 0.2. */
@property (nonatomic, strong) UIColor * _Nonnull buttonBackgroundHighlightColor;
/** color of the action button's text when the button is pressed during Pre-Enrollment and Retry screens. Default is a custom color. */
@property (nonatomic, strong) UIColor * _Nonnull buttonTextHighlightColor;
/** color of the Result screen's background color during upload-animations upon completing a ZoOm session. Default is a custom color gradient. */
@property (nonatomic, copy) NSArray<UIColor *> * _Nonnull resultsScreenBackgroundColor;
/** color of the Result screen's foreground color during upload-animations upong completing a ZoOm session. Default is white. */
@property (nonatomic, strong) UIColor * _Nonnull resultsScreenForegroundColor;
/** brand logo, which is shown on the introduction slide of the Pre-Enrollment screens. Default is the ZoOm logo. */
@property (nonatomic, strong) UIImage * _Nullable brandingLogo;
/** font of the title during the Pre-Enrollment screens. */
@property (nonatomic, strong) UIFont * _Nonnull screenHeaderFont;
/** font of the title's subtext during the Pre-Enrollment screens. */
@property (nonatomic, strong) UIFont * _Nonnull screenSubtextFont;
/** font of the action button's text during the Pre-Enrollment and Retry screens. */
@property (nonatomic, strong) UIFont * _Nonnull screenButtonFont;

/** Customize the Pre-Enrollment/Instruction/Retry images. */
@property (nonatomic, strong) ZoomInstructionsImages * _Nonnull instructionsImages;
/** Customize the zoom session's oval. */
@property (nonatomic, strong) ZoomOvalCustomization * _Nonnull ovalCustomization;
/** Customize the feedback bar and its text. */
@property (nonatomic, strong) ZoomFeedbackCustomization * _Nonnull feedbackCustomization;
/** Customize the cancel button location, or disable it. The cancel button is shown during Pre-Enrollment, Retry, and ZoOm. */
@property (nonatomic, strong) ZoomCancelButtonCustomization * _Nonnull cancelButtonCustomization;
/** Customize the frame that contains all views during the ZoOm session. */
@property (nonatomic, strong) ZoomFrameCustomization * _Nonnull frameCustomization;

- (nonnull instancetype)init;
+ (nonnull instancetype)new;
@end


enum ZoomDevicePartialLivenessResult : NSInteger;
enum ZoomRetryReason : NSInteger;

/** Represents results of a Zoom face biometric comparison */
@protocol ZoomFaceBiometricMetrics <NSObject>
/** A sample of images capturing during the face analysis.  This parameter is nil unless ZoomSDK.auditTrailType is set to something other than Disabled. */
@property (nonatomic, readonly, copy) NSArray<UIImage *> * _Nullable auditTrail;
/** A collection of the audit trails captured during the face analysis.  This parameter is nil unless ZoomSDK.auditTrailType is set to something other than Disabled. */
@property (nonatomic, readonly, copy) NSArray<NSArray<UIImage *>*> * _Nullable auditTrailHistory;
/** The liveness level detected during the zoom session. */
@property (nonatomic, readonly) enum ZoomDevicePartialLivenessResult devicePartialLivenessResult;
/** The liveness level detected during the zoom session. */
@property (nonatomic, readonly) enum ZoomRetryReason zoomRetryReason;
/** The liveness score detected during the zoom session. */
@property (nonatomic, readonly) float devicePartialLivenessScore;
/** ZoOm Hybrid Biometric Facemap. */
@property (nonatomic, readonly, copy) NSData * _Nullable zoomFacemap;
@end

/** Custom introduction and instruction images can be used for the Pre-Enrollment screens. */
__attribute__((visibility("default")))
@interface ZoomInstructionsImages : NSObject
@property (nonatomic, readonly) UIImage * _Nullable genericImage;
@property (nonatomic, readonly) UIImage * _Nullable badLightingImage;
@property (nonatomic, readonly) UIImage * _Nullable badAngleImage;
- (nonnull instancetype)initWithGenericImage:(UIImage * _Nullable)genericImage badLightingImage:(UIImage * _Nullable)badLightingImage badAngleImage:(UIImage * _Nullable)badAngleImage;
@end

__attribute__((visibility("default")))
@interface ZoomOvalCustomization : NSObject
/** color of the outline of the oval during ZoOm. Default is black. */
@property (nonatomic, strong) UIColor * _Nonnull strokeColor;
/** thickness of the outline of the oval during ZoOm. Default is white. */
@property (nonatomic) double strokeWidth;
/** color of the animated 'progress spinner' strokes during ZoOm. Default for both is a custom blue. */
@property (nonatomic, strong) UIColor * _Nonnull progressColor1;
@property (nonatomic, strong) UIColor * _Nonnull progressColor2;
/** radial offset of the animated 'progress spinner' strokes relative to the outermost bounds of the oval outline. As this value increases, animations move closer toward the oval's center. Default is 16.0. */
@property (nonatomic) double progressRadialOffset;
/** thickness of the animated 'progress spinner' strokes during ZoOm. Default is 14.0. */
@property (nonatomic) double progressStrokeWidth;
- (nonnull instancetype) init;
@end

__attribute__((visibility("default")))
@interface ZoomFeedbackCustomization : NSObject
/** size of the feedback bar during ZoOm, which is relative to the current sizeRatio of the frame. Default is (355, 60). */
@property (nonatomic) CGSize size;
/** vertical spacing of the feedback bar from the top boundary of the ZoOm frame, which is relative to the current sizeRatio of the frame. */
@property (nonatomic) double topMargin;
/** corner radius of the feedback bar during ZoOm. Default is 3.0. */
@property (nonatomic) double cornerRadius;
/** spacing between characters displayed within the feedback bar during ZoOm. Default is 1.5. */
@property (nonatomic) double textSpacing;
/** color of the text displayed within the feedback bar during ZoOm. Default is white. */
@property (nonatomic, strong) UIColor * _Nonnull textColor;
/** font of the text displayed within the feedback bar during ZoOm. Default is a custom font style. */
@property (nonatomic) UIFont * _Nonnull textFont;
/** allow pulsating-text animation within the feedback bar during ZoOm. */
@property (nonatomic) BOOL enablePulsatingText;
/** color of the feedback bar's background. Default is a custom color gradient. */
@property (nonatomic, strong) CAGradientLayer * _Nonnull backgroundColor;
- (nonnull instancetype) init;
@end

__attribute__((visibility("default")))
@interface ZoomFrameCustomization : NSObject
/** size ratio of the ZoOm frame's width relative to the width the the current device's display. Default is 0.88. */
@property (nonatomic) double sizeRatio;
/** vertical spacing of the ZoOm frame from the top boundary of the current device's display. Deafult is 100.0. */
@property (nonatomic) double topMargin;
/** corner radius of the ZoOm frame's border. Default is 5.0. */
@property (nonatomic) double cornerRadius;
/** thickness of the ZoOm frame's border. Default is 2.0. */
@property (nonatomic) double borderWidth;
/** color of the ZoOm frame's border. Default is white. */
@property (nonatomic) UIColor * _Nonnull borderColor;
/** applies a UIBlurEffectStyle over the oval background color during ZoOm. Default is off. */
@property (nonatomic) UIColor * _Nonnull backgroundColor;
/** corner radius of the ZoOm frame's border. Default is 5.0. */
@property (nonatomic) enum ZoomBlurEffectStyle blurEffectStyle;
/** behavior of the ZoOm frame when its sizeRatio is set to 1.0. Specific behavior for iPhone X models. */
@property (nonatomic) enum ZoomFullScreenBehavior fullScreenBehavior;
- (nonnull instancetype) init;
@end

__attribute__((visibility("default")))
@interface ZoomCancelButtonCustomization : NSObject
/** custom cancel button image to use instead of the default 'X'. */
@property (nonatomic, strong) UIImage * _Nullable customImage;
/** location, or use, of the cancel button during ZoOm, Pre-Enrollment, and Retry screens. Default is top right. */
@property (nonatomic) enum ZoomCancelButtonLocation location;
- (nonnull instancetype) init;
@end

/**
 Represents the estimated likilihood that the subject in the ZoOm session passes liveness check.
 Low Liveness is indicative of spoof attacks or other attempts to fool the biometric verification system with physical objects which attempt to mimic the characteristics of the biometric (photographs, videos, masks etc) and/or poor environment for measuring liveness.
 */
typedef NS_ENUM(NSInteger, ZoomDevicePartialLivenessResult) {
    ZoomDevicePartialLivenessResultLivenessUndetermined = 0,
    ZoomDevicePartialLivenessResultPartialLivenessSuccess = 1,
};

/**
 Represents the estimated reason that the subject failed the ZoOm session.
 */
typedef NS_ENUM(NSInteger, ZoomRetryReason) {
    /**
     ZoOm detected that the user's session had general inconsistencies.
     If this retry reason is returned, we recommend displaying help to the user to make sure their face is unobstructed
     and are not making any facial expressions during the session.
     */
    ZoomRetryReasonGeneric = 0,
    /**
     ZoOm detected bad lighting on or around the user's face.
     If this retry reason is returned, we recommend displaying help to the user to make sure their face is evenly lit.
     */
    ZoomRetryReasonBadLighting = 1,
    /**
     ZoOm detected that the user was not looking straight ahead during the session.
     If this retry reason is returned, we recommend displaying help to the user to hold the phone at eye level.
     */
    ZoomRetryReasonFaceAngle = 2,
    /**
     ZoOm detected bad lighting to the extent that it could not detect a face.
     If this retry reason is returned, we recommend displaying help to the user to make sure their face is evenly lit
     and that there is no harsh lighting surrounding their face.
     */
    ZoomRetryReasonBadLightingFailureToAcquire = 3,
    /**
     There is no retry reason because the user was processed successfully.
     */
    ZoomRetryReasonNotAvailable = 4
};

enum ZoomSDKStatus : NSInteger;
enum ZoomVerificationStatus: NSInteger;
@class UIViewController;
@protocol ZoomVerificationDelegate;

/**
 The ZoomSDKProtocol exposes methods the app can use to configure the behavior of Zoom.
 */
@protocol ZoomSDKProtocol

/**
 Initialize the ZoOm SDK using your app token for online validation.
 This <em>must</em> be called at least once by the application before invoking any SDK operations.
 This function may be called repeatedly without harm.

 @param appToken Identifies the client for determination of license capabilities
 @param completion Callback after app token validation has completed
 */
- (void)initializeWithAppToken:(NSString * _Nonnull)appToken completion:(void (^ _Nullable)(BOOL))completion NS_SWIFT_NAME(initialize(appToken:completion:));

/**
 Initialize the ZoOm SDK using your license file for offline validation.
 This <em>must</em> be called at least once by the application before invoking any SDK operations.
 This function may be called repeatedly without harm.
 
 @param licenseText The string contents of the license file
 @param appToken Identifies the client
 @param completion Callback after app token validation has completed
 */
- (void)initializeWithLicense:(NSString * _Nonnull)licenseText appToken:(NSString * _Nonnull)appToken completion:(void (^ _Nullable)(BOOL))completion NS_SWIFT_NAME(initialize(licenseText:appToken:completion:));

/**
 Configures the look and feel of Zoom.
 
 @param customization An instance of ZoomCustomization
 */
- (void)setCustomization:(ZoomCustomization * _Nonnull)customization;

/**
 Deprecated.
 @see setCustomization:
 */
- (void)setCustomizationWithInterfaceCustomization:(ZoomCustomization * _Nonnull)interfaceCustomization NS_SWIFT_NAME(setCustomization(interfaceCustomization:)) DEPRECATED_MSG_ATTRIBUTE("Use setCustomization: method instead");

/**
 Convenience method to check if the zoom sdk client app token is valid.
 ZoOm requires that the app successfully initializes the SDK and receives confirmation of a valid app token at least once before launching a verification session.  After the initial validation, the SDK will allow a limited number of verifications without any further
 requirement for successful round-trip connection to the ZoOm server. This allows the app to use ZoOm for a limited time without network connectivity.  During this ‘grace period’, the function will return ‘true’.
 
 @return True, if the SDK license has been validated, false otherwise.
 */
- (BOOL)isAppTokenValid;

/**
 Returns the current status of the ZoOm SDK.
 @return ZoomSDKStatusInitialized, if ready to be used.
 */
- (enum ZoomSDKStatus)getStatus;

/**
 * Convenience method to get the time when a lockout will end.
 * This will be null if the user is not locked out
 * @return NSDate
 */
- (NSDate * _Nullable)getLockoutEndTime;

/**
 * @return True if the user is locked out of ZoOm
 */
- (BOOL)isLockedOut;

/**
 Preload FacialRecognition models – this can be used to reduce the amount of time it takes to initialize a ZoOm view controller.
 You may want to call this function when transitioning to a ViewController in your application from which you intend to launch Zoom.
 This insures that Zoom will launch as quickly as possible when requested.
 */
- (void)preload;

/**
 Convenience method to check for camera permissions.
 This function is used to check the camera permission status prior to using Zoom.  If camera permission has not been previously granted,
 Zoom will display a UI asking the user to allow permission.  Some applications may wish to manage camera permission themselves - those applications
 should verify camera permissions prior to transitioning to Zoom.

 @return Value representing the current camera permission status
 */
@property (nonatomic, readonly) enum ZoomCameraPermissionStatus cameraPermissionStatus;

/** Sets a prefered language to be used for all strings. */
- (void)setLanguage:(NSString * _Nonnull)language;

/**
 Configure where the ZoOm SDK looks for custom localized strings.
 @param table Optional name of the string table to look in.  By default, this is "Zoom" and string will be read from Zoom.strings.
 @param bundle Optional NSBundle instance to search for Zoom string definitions in.  This will be searched after the main bundle and before Zoom's default strings.
 */
- (void)configureLocalizationWithTable:(NSString * _Nullable)table bundle:(NSBundle * _Nullable)bundle;

/**
 Sets the type of audit trail images to be collected.
 If this property is not set to Disabled, then Zoom will include a sample of some of the camera frames collected during the Verification process
 on the Verifiation response.
 */
@property (nonatomic) enum ZoomAuditTrailType auditTrailType;

/**
 Sets the time in seconds before a timeout occurs in the verification process.
 This value has to be between 30 and 60 seconds. If it’s lower than 30 or higher than 60, it
 will be defaulted to 30 or 60 respectively.
 */
@property (nonatomic) NSInteger activeTimeoutInSeconds;

/**
 Fetches the version number of the current Zoom SDK release
 
 @return Version number of sdk release package
 */
@property (nonatomic, readonly, copy) NSString * _Nonnull version;

/**
 Set the encryption key to be used for ZoOm Server facemaps
 
 @param publicKey RSA public key to be used in PEM format
 */
- (void)setFacemapEncryptionKeyWithPublicKey:(NSString * _Nonnull)publicKey NS_SWIFT_NAME(setFacemapEncryptionKey(publicKey:));

/**
 Configures and returns a new UIViewController for a verification session.
 Caller should call presentViewController on returned object only once.
 
 @param delegate The delegate on which the application wishes to receive status results from the Verification
 */
- (UIViewController * _Nonnull)createVerificationVCWithDelegate:(id <ZoomVerificationDelegate> _Nonnull)delegate NS_SWIFT_NAME(createVerificationVC(delegate:));

/** Returns a description string for a ZoomVerificationStatus value */
- (NSString * _Nonnull)descriptionForVerificationStatus:(enum ZoomVerificationStatus)status;

/** Returns a description string for a ZoomSDKStatus value */
- (NSString * _Nonnull)descriptionForSDKStatus:(enum ZoomSDKStatus)status;
@end

/** Represents the status of the SDK */
typedef NS_ENUM(NSInteger, ZoomSDKStatus) {
    /** Initialize was never attempted */
    ZoomSDKStatusNeverInitialized = 0,
    /** The app token provided was verified */
    ZoomSDKStatusInitialized = 1,
    /** The app token could not be verified */
    ZoomSDKStatusNetworkIssues = 2,
    /** The app token provided was invalid */
    ZoomSDKStatusInvalidToken = 3,
    /** The current version of the SDK is deprecated */
    ZoomSDKStatusVersionDeprecated = 4,
    /** The app token needs to be verified again */
    ZoomSDKStatusOfflineSessionsExceeded = 5,
    /** An unknown error occurred */
    ZoomSDKStatusUnknownError = 6,
    /** Device is locked out due to too many failures */
    ZoomSDKStatusDeviceLockedOut = 7,
    /** Device is in landscape mode */
    ZoomSDKStatusDeviceInLandscapeMode = 8,
    /** Device is in reverse portrait mode */
    ZoomSDKStatusDeviceInReversePortraitMode = 9,
    /** The provided license has expired or it contains invalid text. */
    ZoomSDKStatusLicenseExpiredOrInvalid,
};

@protocol ZoomVerificationResult;
enum ZoomVerificationStatus : NSInteger;

/**
 Applications should implement this delegate to receive results from a ZoomVerification UIViewController.
 */
@protocol ZoomVerificationDelegate <NSObject>
/**
 This method will be called exactly once after the Zoom Session has completed.
 @param result A ZoomVerificationResult instance.
 */
- (void)onZoomVerificationResultWithResult:(id<ZoomVerificationResult> _Nonnull)result NS_SWIFT_NAME(onZoomVerificationResult(result:));

/**
 Optional callback function to be called when ZoOm is about to be dismissed.
 @param status The ZoomVerificationStatus for the ZoOm session.
 @return TRUE if you want to handle the dismissal of the ZoOm view controller.
 */
@optional
- (bool)onBeforeZoomDismissWithStatus:(enum ZoomVerificationStatus)status retryReason:(enum ZoomRetryReason)reason NS_SWIFT_NAME(onBeforeZoomDismiss(status:retryReason:));
@end

/** Represents results of a Zoom Verification Request */
@protocol ZoomVerificationResult <NSObject>
/** Indicates whether the verification succeeded or the cause of failure. */
@property (nonatomic, readonly) enum ZoomVerificationStatus status;
/** Metrics collected during face verification. */
@property (nonatomic, readonly, strong) id<ZoomFaceBiometricMetrics> _Nullable faceMetrics;
/** Number of full sessions (both retry and success) that the user performed from the time ZoOm was invoked to the time control is handed back to the application. */
@property (nonatomic, readonly) NSInteger countOfZoomSessionsPerformed;
/** Unique id for a ZoOm session. */
@property (nonatomic, readonly, copy) NSString * _Nonnull sessionId;
@end

/** Represents the various end states of a verification session */
typedef NS_ENUM(NSInteger, ZoomVerificationStatus) {
    /**
     The user was successfully processed. Device liveness and quality checks passed and a facemap was created.
     */
    ZoomVerificationStatusUserProcessedSuccessfully,
    /**
     The user was not processed successfully.
     This could be a liveness failure or a failure on the part of the user to perform a ZoOm correctly and/or with sufficiently good environmental conditions.
     A facemap was created if there were sufficient frames provided by the user.
     */
    ZoomVerificationStatusUserNotProcessed,
    /**
     The user cancelled out of the verification session rather than completing it.
     A facemap will not be created.
     */
    ZoomVerificationStatusFailedBecauseUserCancelled,
    /**
     When not using an offline license, ZoOm requires the developer to pass a valid app token in order to function.
     This status will never be returned in a properly configured app, as the ZoOm APIs allow you to check app token validity before invoking ZoOm UI.
     */
    ZoomVerificationStatusFailedBecauseAppTokenNotValid,
    /**
     The camera access is prevented because either the user has explicitly denied permission or
     the user's device is configured to not allow access by a device policy.
     For more information on restricted by policy case, please see the the Apple Developer documentation on AVAuthorizationStatus.restricted.
     */
    ZoomVerificationStatusFailedBecauseCameraPermissionDenied,
    /**
     Verification was terminated due to the app being terminated, put to sleep or to the background.
     A facemap will not be created.
     */
    ZoomVerificationStatusFailedBecauseOfOSContextSwitch,
    /**
     The user was unable to complete a session in the allotted time set by the developer.
     A facemap will not be created.
     */
    ZoomVerificationStatusFailedBecauseOfTimeout,
    /**
     Verification failed due to low memory.
     A facemap will not be created.
     */
    ZoomVerificationStatusFailedBecauseOfLowMemory,
    /**
     When not using an offline license, ZoOm requires network connection when being used.
     */
    ZoomVerificationStatusFailedBecauseNoConnectionInDevMode,
    /**
     When not using an offline license, ZoOm allows a number of sessions to occur without validating the app token to handle scenarios where
     an end user might have lost connection to a network. Once that limit has been exceeded this failure will
     be returned.
     */
    ZoomVerificationStatusFailedBecauseOfflineSessionsExceeded,
    /**
     When configuring ZoOm to return facemaps, a valid ZoOm Hybrid encryption key is required.
     Note: Liveness checks can occur without setting an encryption key.
     */
    ZoomVerificationStatusFailedBecauseEncryptionKeyInvalid,
    /**
     Verification failed because of an unknown and unexpected error.
     ZoOm leverages a variety of iOS APIs including camera, storage, security, networking, and more.
     This return value is a catch-all for errors experienced during normal usage of these APIs.
     */
    ZoomVerificationStatusUnknownError
};

