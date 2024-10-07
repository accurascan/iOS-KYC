
import UIKit
import CoreData
import AccuraOCR
//list of Page Type
public enum NAV_PAGETYPE: Int {
    case Default
    case AppDelgate
    case ScanPassport
    case ScanPan
    case ScanAadhar
    case ScanOCR
    case DLPlate
    case BankCard
}

//list of Scan Type
public enum NAV_SCANTYPE: Int {
    case Default
    case OcrScan
    case FMScan
    case AccuraScan
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait
    var selectedScanType: NAV_SCANTYPE = .Default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 0.0)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.removeObject(forKey: "type")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

  
    
    internal var shouldRotate = true
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
//        return shouldRotate ? .allButUpsideDown : .portrait
    }

    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            // print("Landscape")
        }
        
        if UIDevice.current.orientation.isPortrait {
            // print("Portrait")
        }
        
    }
    
    struct AppUtility {

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
       
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }

    }
}

