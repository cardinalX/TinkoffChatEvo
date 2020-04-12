//
//  AppDelegate.swift
//  TinkoffChatEvo
//
//  Created by max on 14/02/2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let mainViewController = ChannelsListViewController(nibName: String(describing: ChannelsListViewController.self), bundle: nil)
    let navigationViewController = UINavigationController(rootViewController: mainViewController)
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navigationViewController
    window?.makeKeyAndVisible()
    
    FirebaseApp.configure()
    
    return true
  }

}

