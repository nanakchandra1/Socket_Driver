//
//  AppDelegate.swift
//  DriverApp
//
//  Created by Saurabh Shukla on 9/6/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import SafariServices
import SDWebImage
import GoogleMaps
import Stripe
import Fabric
import Crashlytics
import IQKeyboardManager
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var pushData : PushPayLoad?
    var device_Token: String?
    var launchedFromPushNotification: Bool = false
    var stausTimer = Timer()
    let googleMapsApiKey = "AIzaSyCpvhVhEb0N4ihzWh8FA3FIVsdBEBGuESU"

    
    var latitude:CLLocationDegrees {
        
        
        if let location = self.locationManager.location{
            
            return location.coordinate.latitude
        }
        return 0
        
    }
    
    var longitude:CLLocationDegrees {
        
        if let location = self.locationManager.location{
            return location.coordinate.longitude
        }
        return 0
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(googleMapsApiKey)
        Fabric.with([STPAPIClient.self, Crashlytics.self])

        STPPaymentConfiguration.shared().publishableKey = API_Keys.stripeApiKey

        getMainQueue(){
            self.initialSetup(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        
        application.registerForRemoteNotifications()
        
        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(types: .alert, categories: nil))
        
        
        return true
    }
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) -> Void{
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        var token = ""
        for i in 0..<deviceToken.count {
            
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        token = token.trimmingCharacters(in: characterSet)
        
        token = token.replacingOccurrences(of: " ", with: "")
        
        if !token.isEmpty{
            
            self.device_Token = token
        }
        else
        {
            self.device_Token = "123456"
        }
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        SocketIOManager.instance.closeConnection()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: SATRTANIMATE), object: nil, userInfo: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
//        SocketIOManager.instance.connectSocket()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if CurrentUser.token != nil{
            SocketManegerInstance.connectSocket(handler: { () in
                
            })
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.AppInventiv.DriverApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DriverApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        var options: [AnyHashable: Any] = [
            NSMigratePersistentStoresAutomaticallyOption : Int(true),
            NSInferMappingModelAutomaticallyOption : Int(true)]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK:
    // MARK: Device token delegates
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        printlnDebug("didFailToRegisterForRemoteNotificationsWithError : \(error)")
        saveToUserDefaults(deviceTokenn as AnyObject, withKey: NSUserDefaultKey.DeviceTokenn as NSString)
    }
    
    
    //MARK:
    //MARK: Location Services
    func startLocationManager(){
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        self.locationManager.stopUpdatingLocation()
        NotificationCenter.default.post(name: Notification.Name(rawValue: LOCATION_UPDATED), object: nil, userInfo: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError){
        
        printlnDebug("location error \(error)")
        self.locationManager.stopUpdatingLocation()
        
        if (!CLLocationManager.locationServicesEnabled() || (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways  && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse)){
            
            delay(0.5, closure: {
                
                let alertController = UIAlertController(title: appName.localized, message: "Location Services are disabled.Please go to settings to enable".localized, preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                })
                
                let settingsAction = UIAlertAction(title: "Go to Settings".localized, style: UIAlertActionStyle.default, handler: { (action) in
                    
                    openSettings()
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                topViewController.present(alertController, animated: true, completion: nil)
            })
            
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: LOCATION_NOT_UPDATED), object: nil, userInfo: nil)
    }
    
    // MARK:-
    // MARK:- Remote notification delegates
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        self.launchedFromPushNotification = true
//        let aps = JSON(userInfo)
//        printlnDebug(aps)
//        let info = aps["aps"].dictionaryValue
//        printlnDebug(info)
//            self.pushData = PushPayLoad(withPayLoad: info)
//            printlnDebug(self.pushData)
//        
//        if application.applicationState == UIApplicationState.inactive {
//            showPopUp(aps, application: application)
//
//        } else if application.applicationState == UIApplicationState.background {
//            showPopUp(aps, application: application)
//        }
//        else {
//            // App is in foreground
//            showPopUp(aps, application: application)
//        }
    }
    
   
//    func showPopUp(_ aps: JSON, application: UIApplication) {
//        
//
//        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
//            
//            guard viewController != nil else { return }
//            
//            printlnDebug(aps)
//            
//            if let type = aps["type"].string{
//                
//                 if type == "ads"{
//                    
//                    driverSharedInstance.notificationCount = driverSharedInstance.notificationCount + 1
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION), object: nil, userInfo: nil)
//                    
//                    if application.applicationState == UIApplicationState.inactive {
//                        gotoNotificationVC()
//                    } else if application.applicationState == UIApplicationState.background {
//                        gotoNotificationVC()                    }
//                    else {
//                        
//                        let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "NotificationPopUpVC") as! NotificationPopUpVC
//                        popUp.modalPresentationStyle = .overCurrentContext
//                        if let info = aps["aps"].dictionary{
//                            popUp.userInfo = info as JSONDictionary
//                        }
//                        
//                        getMainQueue({
//                            viewController!.present(popUp, animated: true, completion: nil)
//                        })
//                    }
//                    
//                 }else{
//
//                    let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
//                
//                printlnDebug(type)
//                if type == "riderequest"{
//                    popUp.selectedPopUp = ShowPopUp.request
//                    popUp.modalPresentationStyle = .overCurrentContext
//                    popUp.jobDetails = JobDetailsModel(with: aps)
//                    
//                    getMainQueue({
//                        viewController!.present(popUp, animated: true, completion: nil)
//                    })
//
//                }else if type == "pickuprequest"{
//                    popUp.selectedPopUp = ShowPopUp.pickUpRequest
//                    popUp.modalPresentationStyle = .overCurrentContext
//                    popUp.jobDetails = JobDetailsModel(with: aps)
//                    
//                    getMainQueue({
//                        viewController!.present(popUp, animated: true, completion: nil)
//                    })
//
//                }else if type == "changelocation"{
//                    popUp.selectedPopUp = ShowPopUp.changeDestination
//                    popUp.modalPresentationStyle = .overCurrentContext
//                    popUp.userInfo = ChangeDropModel(with: aps)
//                    
//                    getMainQueue({
//                        viewController!.present(popUp, animated: true, completion: nil)
//                    })
//
//                }else if type == "prebookingrequest"{
//                    
//                    popUp.selectedPopUp = ShowPopUp.request
//                    popUp.modalPresentationStyle = .overCurrentContext
//                    popUp.jobDetails = JobDetailsModel(with: aps)
//                    
//                    getMainQueue({
//                        viewController!.present(popUp, animated: true, completion: nil)
//                    })
//                }else if type == "ridecancelled"{
//                    
//                    sharedAppdelegate.stausTimer.invalidate()
//                    
//                    if CurrentUser.r_type == RequestType.pickup{
//                        if CurrentUser.d_type == DriverType.pickup_driver{
//                        
//                        }else{
//                            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.R_TYPE)
//                            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_State)
//                            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.D_TYPE)
//                            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.TRIP_STATE)
//
//                        }
//                    
//                    }else{
//                        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.R_TYPE)
//                        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_State)
//                        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.D_TYPE)
//                        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.TRIP_STATE)
//
//                    }
//                    gotoHomeVC()
//                    showToastWithMessage(AppConstantString.rideCancel)
//                    
//                    }
//                }
//            }
//        }
//    }

    // MARK:
    // MARK: Memory Warning
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication){
        clearCache()
    }
    
    func gotoNotificationVC(){
        
        let settingsScene = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navController = UINavigationController(rootViewController: settingsScene)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        selectedIndex = 4
    }
    
    func handleRemotePush(_ infoDict:JSON, application: UIApplication){
        
//        showPopUp(infoDict, application: application)

    }
    
    func clearCache(){
        //removeing SDWebImage Cache to clear memory
        SDWebImageManager.shared().imageCache?.clearMemory()
        SDWebImageManager.shared().imageCache?.clearDisk()
        URLCache.shared.removeAllCachedResponses()
        
    }
    
    
    func initialSetup(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?){
        

        //CountryHandler
        let handler: VoiceeCountryHandler = VoiceeCountryHandler()
        handler.prepareDataBace()
        
        if launchOptions != nil{
            
            if let userInfo = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]{
                printlnDebug("launchOptions userInfo\n\(userInfo)")
                
                if (userInfo["aps"] as? [String:AnyObject]) != nil{
                    
                    //  Push recived
//                    self.handleRemotePush(userInfo as! [String: AnyObject], application: application)
                    //self.handleRemotePush(userInfo as! [String: AnyObject])
                }
            }
        }
        
        
        // Device token permission settings
        
        if((userDefaultsForKey(NSUserDefaultKey.DeviceTokenn as NSString) as? String) == nil || (userDefaultsForKey(NSUserDefaultKey.DeviceTokenn as NSString) as? String) == deviceTokenn || ((userDefaultsForKey(NSUserDefaultKey.SystemVersion as NSString) as? String) != nil && SystemVersion_String != (userDefaultsForKey(NSUserDefaultKey.SystemVersion as NSString) as? String))){
            
            saveToUserDefaults(deviceTokenn as AnyObject, withKey: NSUserDefaultKey.DeviceTokenn as NSString)
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        self.startLocationManager()
        //IQ Keyboard Manager setup
        IQKeyboardManager.shared().isEnabled = true
    }
    
    func leftSideMenuButtonPressed(_ sender: AnyObject?){
        
        mfSideMenuContainerViewController.leftMenuViewController.viewWillAppear(false)
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion({
        })
    }
    
    //MARK: Tabbarviewcontroller delegates
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        let bgView1 = tabBarController.tabBar.viewWithTag(11211)
        let bgView2 = tabBarController.tabBar.viewWithTag(11212)
        let bgView3 = tabBarController.tabBar.viewWithTag(11213)
        
        
        switch tabBarController.selectedIndex {
        case 0:
            bgView1?.backgroundColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1)
            bgView2?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
            bgView3?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
        case 1:
            bgView2?.backgroundColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1)
            bgView1?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
            bgView3?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
        case 2:
            bgView3?.backgroundColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1)
            bgView2?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
            bgView1?.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
        default:
            break
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

struct PushPayLoad {
    
    let alert:String!
    let pushId : String!
    let pushType: String!
    
    init(withPayLoad : [String:JSON]) {
        self.pushId = withPayLoad["push_id"]?.stringValue
        self.alert = withPayLoad["alert"]?.stringValue
        self.pushType = withPayLoad["push_type"]?.stringValue
    }
}
