//
//  ViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/11/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import GoogleSignIn
import MapKit
import CoreLocation
import NVActivityIndicatorView

class LoginViewController: UIViewController, GIDSignInDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var googleButton: UIButton!
    
    var activityIndicator: NVActivityIndicatorView?
    
    var googleEmail: String = ""
    
    var googleFullName: String = ""
    
    var googleId: String = ""
    
    let locationManager = CLLocationManager()
    
    var hasDefaults: Bool?
    
    var isBanned: Bool?
    
    let rememberData = UserDefaults()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        rememberSwitch.addTarget(self, action: #selector(switchToggled(sender:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loginButton.isEnabled = false
        googleButton.isEnabled = false
        checkUserDefaults()
        checkLocationServices()
    }
    
    @objc func switchToggled(sender: UISwitch)
    {
        if(sender.isOn)
        {
            self.hasDefaults = true
        }
        else
        {
            self.hasDefaults = false
        }
    }
    
    func checkUserDefaults()
    {
        let username = rememberData.value(forKey: "username") as? String
        if let us = username
        {
            let password = rememberData.value(forKey: "password") as? String
            self.emailTextField.text = us
            self.passwordTextField.text = password!
            rememberSwitch.isOn = true
            self.hasDefaults = true
        }
        else
        {
            rememberSwitch.isOn = false
            emailTextField.text = ""
            passwordTextField.text = ""
            self.hasDefaults = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func doLogin(_ sender: UIButton)
    {
        let status: Bool = inputControl()
        if status
        {
            checkForBanRegularLogin()
        }
        else
        {
            return
        }
    }
    
    func loginAction()
    {
        if(self.hasDefaults!)
        {
            self.rememberData.set(self.emailTextField.text!, forKey: "username")
            self.rememberData.set(self.passwordTextField.text!, forKey: "password")
        }
        else
        {
            self.rememberData.removeObject(forKey: "username")
            self.rememberData.removeObject(forKey: "password")
        }
        PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: {
            (logged, error) in
            if let err = error
            {
                self.displayAlert(title: "Login error", message: err.localizedDescription, type: .failure)
            }
            else if let log = logged
            {
                let type = log.object(forKey: "type") as? String
                if(type! == "hero")
                {
                    self.performSegue(withIdentifier: "gotoUser", sender: self)
                }
                else if(type! == "service")
                {
                    self.performSegue(withIdentifier: "gotoService", sender: self)
                }
                else
                {
                    self.performSegue(withIdentifier: "gotoAdmin", sender: self)
                }
            }
            else
            {
                fatalError("The app has encountered a fatal error while trying to log in the user.")
            }
        })
    }
    
    func checkForBanRegularLogin()
    {
        setupActivityIndicator()
        let query = PFQuery(className: "Ban")
        query.includeKey("toUser")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.loginButton.isEnabled = false
                self.googleButton.isEnabled = false
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.isBanned = false
                    for ban in objs
                    {
                        let user = ban.object(forKey: "toUser") as? PFObject
                        if let u = user
                        {
                            let username = u.object(forKey: "username") as? String
                            let comp = self.emailTextField.text!
                            if(username! == comp)
                            {
                                self.isBanned = true
                                break
                            }
                        }
                    }
                    self.stopActivityIndicator()
                    if(self.isBanned!)
                    {
                        self.displayAlert(title: "Error", message: "This account is banned, contact admin@management.com to negotiate a revoke.", type: .failure)
                    }
                    else
                    {
                        self.loginAction()
                    }
                }
                else
                {
                    self.isBanned = false
                    self.stopActivityIndicator()
                    self.loginAction()
                }
            }
            else
            {
                print("An unknown error has occured.")
                self.loginButton.isEnabled = false
                self.googleButton.isEnabled = false
                self.stopActivityIndicator()
            }
        })
    }
    
    func inputControl() -> Bool
    {
        if emailTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the email text field", type: .failure)
            return false
        }
        else if passwordTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the password text field", type: .failure)
            return false
        }
        else
        {
            return true
        }
    }
    
    @IBAction func doGoogleSignIn(_ sender: UIButton)
    {
        GIDSignIn.sharedInstance()!.delegate = self
        GIDSignIn.sharedInstance()!.presentingViewController = self
        GIDSignIn.sharedInstance()!.signIn()
    }
    
     func checkLocationServices()
    {
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        }
        else
        {
            displayAlert(title: "User error", message: "Please turn on location services for this app to work.", type: .info)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse
        {
            loginButton.isEnabled = true
            googleButton.isEnabled = true
        }
        else if status == .authorizedAlways
        {
            loginButton.isEnabled = true
            googleButton.isEnabled = true
        }
        else
        {
            loginButton.isEnabled = false
            googleButton.isEnabled = false
        }
    }
    
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            displayAlert(title: "Permissions error", message: "Location permissions are restricted on this device, the app won't be able to work.", type: .failure)
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            displayAlert(title: "Permissions error", message: "Location permissions must be enabled.", type: .failure)
        case .authorizedAlways:
            print("Location permissions are enabled.")
            loginButton.isEnabled = true
            googleButton.isEnabled = true
        case .authorizedWhenInUse:
            print("Location permissions are enabled.")
            loginButton.isEnabled = true
            googleButton.isEnabled = true
        @unknown default:
            fatalError("Error the app has encountered a critical error regarding CLLocation manager and has crashed.")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
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
        self.googleFullName = user.profile.name
        self.googleEmail = user.profile.email
        self.googleId = user.userID
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: user.profile.email!)
        query.findObjectsInBackground(block: {
            (users, error) in
            if let err = error
            {
                fatalError(err.localizedDescription)
            }
            else if let us = users
            {
                if(us.count == 0)
                {
                    self.performSegue(withIdentifier: "gotoGoogleRegister", sender: self)
                }
                else
                {
                    self.setupActivityIndicator()
                    let query = PFQuery(className: "Ban")
                    query.includeKey("toUser")
                    query.findObjectsInBackground(block: {
                        (objects, error) in
                        if let err = error
                        {
                            print(err.localizedDescription)
                            self.loginButton.isEnabled = false
                            self.googleButton.isEnabled = false
                            self.stopActivityIndicator()
                        }
                        else if let objs = objects
                        {
                            if(objs.count > 0)
                            {
                                self.isBanned = false
                                for ban in objs
                                {
                                    let user = ban.object(forKey: "toUser") as? PFObject
                                    if let u = user
                                    {
                                        let username1 = self.googleEmail
                                        let username2 = u.object(forKey: "username") as? String
                                        if(username1 == username2!)
                                        {
                                            self.isBanned = true
                                            break
                                        }
                                    }
                                }
                                self.stopActivityIndicator()
                                if(self.isBanned!)
                                {
                                    self.displayAlert(title: "Error", message: "This account is banned, please contact admin@management.com, to negotiate a revoke.", type: .failure)
                                }
                                else
                                {
                                    self.doLoginAction()
                                }
                            }
                            else
                            {
                                self.isBanned = false
                                self.stopActivityIndicator()
                                self.doLoginAction()
                            }
                        }
                        else
                        {
                            print("Unknown error.")
                            self.loginButton.isEnabled = false
                            self.googleButton.isEnabled = false
                            self.stopActivityIndicator()
                        }
                    })
                }
            }
            else
            {
                fatalError("The app has encountered an error while trying to log in the google user.")
            }
        })
    }
    
    func doLoginAction()
    {
        PFUser.logInWithUsername(inBackground: self.googleEmail, password: self.googleId, block: {
            (logged, error) in
            if let err = error
            {
                self.displayAlert(title: "Login error", message: err.localizedDescription, type: .failure)
            }
            else if let log = logged
            {
                let type = log.object(forKey: "type") as? String
                if(type! == "hero")
                {
                    self.performSegue(withIdentifier: "gotoUser", sender: self)
                }
                else if(type! == "service")
                {
                    self.performSegue(withIdentifier: "gotoService", sender: self)
                }
            }
            else
            {
                fatalError("The app has encountered an unknown fatal error while trying to log in the user.")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoGoogleRegister"
        {
            let vc = segue.destination as! GoogleRegisterViewController
            vc.userEmail = self.googleEmail
            vc.userFullName = self.googleFullName
            vc.userId = self.googleId
        }
    }
    
     func setupActivityIndicator()
       {
           self.activityIndicator = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .blue, padding: 0)
           self.activityIndicator!.translatesAutoresizingMaskIntoConstraints = false
           self.view.addSubview(activityIndicator!)
           NSLayoutConstraint.activate([
               self.activityIndicator!.widthAnchor.constraint(equalToConstant: 40),
               self.activityIndicator!.heightAnchor.constraint(equalToConstant: 40),
               self.activityIndicator!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
               self.activityIndicator!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
           ])
           self.activityIndicator!.startAnimating()
       }
                
       func stopActivityIndicator()
       {
           self.activityIndicator!.stopAnimating()
           self.activityIndicator!.removeFromSuperview()
       }
    
    enum alertType
    {
        case success
        case failure
        case info
    }
    
    func displayAlert(title: String, message: String, type: alertType)
    {
        let alert = SCLAlertView()
        switch type
        {
        case .success:
            alert.showSuccess(title, subTitle: message)
        case .failure:
            alert.showError(title, subTitle: message)
        case .info:
            alert.showInfo(title, subTitle: message)
        }
    }
    
}
