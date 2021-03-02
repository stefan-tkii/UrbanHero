//
//  AppDelegate.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/11/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import GoogleSignIn
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error
        {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue
            {
                print("The user has not signed in before or they have since signed out.")
            }
            else
            {
                print("\(error.localizedDescription)")
            }
            return
        }
        print("Google sign in works.")
        /*
        let userId = user.userID
        let idToken = user.authentication.idToken
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        */
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()!.handle(url)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        GIDSignIn.sharedInstance()!.clientID = "744319920816-okqhjrntqpvlf2qqou79uta3o23v7kol.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()!.delegate = self
        let configuration = ParseClientConfiguration
        {
            $0.applicationId = "8HQym2ZzWRkiOpo6lCVcRVEYnssUQQ22NsVMCJhF"
            $0.clientKey = "6TL45SQgycY75yYZXv9VlSExL6BTPjKEFumqD6LC"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        //saveInstallationObject()
        GMSServices.provideAPIKey("AIzaSyDirpaOk6Bkv8Xtr2bBdDcbnrg1N9Xra78")
        return true
    }
    
    func saveInstallationObject()
    {
        if let installation = PFInstallation.current()
        {
            installation.saveInBackground(block: {
                (succsess: Bool, error: Error?) in
                if(succsess)
                {
                    print("Object has been saved.")
                }
                else
                {
                    if let err = error
                    {
                        print(err.localizedDescription)
                    }
                    else
                    {
                        print("An unkown error has occured.")
                    }
                }
            })
        }
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

