//
//  GlobalMethods.h
//
//
// ****************************** file use for display alert and declare method which use globally ******************************

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GlobalMethods : NSObject


+(void)showAlertView:(NSString *)text withViewController:(UIViewController *)view;

// Push View Controller Methods
+(void)showAlertView:(NSString *)text withNextviewController:(UIViewController *)nextviewcontroller withviewController:(UIViewController *)viewcontroller wintNavigation :(UINavigationController *)navigationController;

@end
