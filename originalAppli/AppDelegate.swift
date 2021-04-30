//
//  AppDelegate.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/11/27.
//アプリが起動した時

//isLogin　ログインした時

import UIKit
import NCMB
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //mainの下にある表示されない画面？のことでwindowを経由してmainに

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NCMB.setApplicationKey("e575162433b42b92bc9fc8b4d0a124d8ba67aeecf862261a891659cb48c82d07", clientKey: "e38cca1d3005cabe29a8c8e77e0af40c1484d0a239a11d302ba0787a61f6dd74")
    
        //ログイン管理
        let ud = UserDefaults.standard
        let isLogin =  ud.bool(forKey: "isLogin")
        
        if isLogin == true{
            //ログイン中の時
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
            
        }else{
            //ログインしていない時
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "signIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        }
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

