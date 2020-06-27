
import UIKit
import CoreData
import Firebase
import AccuraOCR

//list of Page Type
public enum NAV_PAGETYPE: Int {
    case Default
    case AppDelgate
    case ScanPassport
    case ScanPan
    case ScanAadhar
    case ScanOCR
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
    var selectedScanType: NAV_SCANTYPE = .Default
    var videoCameraWrapper: VideoCameraWrapper? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 0.0)
        UIApplication.shared.statusBarStyle = .lightContent
        videoCameraWrapper = VideoCameraWrapper.init()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.videoCameraWrapper?.accuraSDk()
        }
//        FirebaseApp.configure()
        AccuraOCRSDKApp.configure()
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

  
    
    internal var shouldRotate = false
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return shouldRotate ? .allButUpsideDown : .portrait
    }

    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            // print("Landscape")
        }
        
        if UIDevice.current.orientation.isPortrait {
            // print("Portrait")
        }
        
    }
}

