//
//  RegisterViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/11/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import MapKit
import CoreLocation

class RegisterViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var physicalAddressTextField: UITextField!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var heroSwitch: UISwitch!
    
    @IBOutlet weak var serviceSwitch: UISwitch!
    
    @IBOutlet weak var serviceLabel: UILabel!
    
    @IBOutlet weak var parkingLabel: UILabel!
    
    @IBOutlet weak var parkingSwitch: UISwitch!
    
    @IBOutlet weak var animalLabel: UILabel!
    
    @IBOutlet weak var animalSwitch: UISwitch!
    
    @IBOutlet weak var fireLabel: UILabel!
    
    @IBOutlet weak var fireSwitch: UISwitch!
    
    @IBOutlet weak var trashLabel: UILabel!
    
    @IBOutlet weak var trashSwitch: UISwitch!
    
    @IBOutlet weak var registerButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var longitude: Double = 0.0
    
    var latitude: Double = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
            registerButton.isEnabled = true
        }
        else if status == .authorizedAlways
        {
            registerButton.isEnabled = true
        }
        else
        {
            registerButton.isEnabled = false
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
            registerButton.isEnabled = true
        case .authorizedWhenInUse:
            print("Location permissions are enabled.")
            registerButton.isEnabled = true
        @unknown default:
            fatalError("Error the app has encountered a critical error regarding CLLocation manager and has crashed.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        initializeSwitchesAndLabels()
        heroSwitch.addTarget(self, action: #selector(heroSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        serviceSwitch.addTarget(self, action: #selector(serviceSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        parkingSwitch.addTarget(self, action: #selector(parkingSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        animalSwitch.addTarget(self, action: #selector(animalSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        fireSwitch.addTarget(self, action: #selector(fireSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        trashSwitch.addTarget(self, action: #selector(trashSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        registerButton.isEnabled = false
        checkLocationServices()
    }
    
    @objc func heroSwitchChanged(switch: UISwitch)
    {
        if(heroSwitch.isOn)
        {
            serviceSwitch.isOn = false
            serviceLabel.isHidden = true
            parkingLabel.isHidden = true
            parkingSwitch.isHidden = true
            animalLabel.isHidden = true
            animalSwitch.isHidden = true
            fireLabel.isHidden = true
            fireSwitch.isHidden = true
            trashLabel.isHidden = true
            trashSwitch.isHidden = true
        }
        else
        {
            serviceSwitch.isOn = true
            serviceLabel.isHidden = false
            parkingLabel.isHidden = false
            parkingSwitch.isHidden = false
            animalLabel.isHidden = false
            animalSwitch.isHidden = false
            fireLabel.isHidden = false
            fireSwitch.isHidden = false
            trashLabel.isHidden = false
            trashSwitch.isHidden = false
        }
    }
    
    @objc func serviceSwitchChanged(switch: UISwitch)
    {
        if(serviceSwitch.isOn)
        {
            heroSwitch.isOn = false
            serviceLabel.isHidden = false
            parkingLabel.isHidden = false
            parkingSwitch.isHidden = false
            animalLabel.isHidden = false
            animalSwitch.isHidden = false
            fireLabel.isHidden = false
            fireSwitch.isHidden = false
            trashLabel.isHidden = false
            trashSwitch.isHidden = false
        }
        else
        {
            heroSwitch.isOn = true
            serviceLabel.isHidden = true
            parkingLabel.isHidden = true
            parkingSwitch.isHidden = true
            animalLabel.isHidden = true
            animalSwitch.isHidden = true
            fireLabel.isHidden = true
            fireSwitch.isHidden = true
            trashLabel.isHidden = true
            trashSwitch.isHidden = true
        }
    }
    
    @objc func parkingSwitchChanged(switch: UISwitch)
    {
        if(parkingSwitch.isOn)
        {
            animalSwitch.isOn = false
            fireSwitch.isOn = false
            trashSwitch.isOn = false
        }
        else
        {
            parkingSwitch.isOn = true
        }
    }
    
    @objc func animalSwitchChanged(switch: UISwitch)
    {
        if(animalSwitch.isOn)
        {
            parkingSwitch.isOn = false
            fireSwitch.isOn = false
            trashSwitch.isOn = false
        }
        else
        {
            animalSwitch.isOn = true
        }
    }
    
    @objc func fireSwitchChanged(switch: UISwitch)
    {
        if(fireSwitch.isOn)
        {
            parkingSwitch.isOn = false
            animalSwitch.isOn = false
            trashSwitch.isOn = false
        }
        else
        {
            fireSwitch.isOn = true
        }
    }
    
    @objc func trashSwitchChanged(switch: UISwitch)
    {
        if(trashSwitch.isOn)
        {
            parkingSwitch.isOn = false
            animalSwitch.isOn = false
            fireSwitch.isOn = false
        }
        else
        {
            trashSwitch.isOn = true
        }
    }
    
    func initializeSwitchesAndLabels()
    {
        heroSwitch.isOn = true
        serviceSwitch.isOn = false
        serviceLabel.isHidden = true
        parkingLabel.isHidden = true
        parkingSwitch.isOn = true
        parkingSwitch.isHidden = true
        animalLabel.isHidden = true
        animalSwitch.isOn = false
        animalSwitch.isHidden = true
        fireLabel.isHidden = true
        fireSwitch.isOn = false
        fireSwitch.isHidden = true
        trashLabel.isHidden = true
        trashSwitch.isOn = false
        trashSwitch.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        fullNameTextField.resignFirstResponder()
        physicalAddressTextField.resignFirstResponder()
    }
    
    @IBAction func doRegister(_ sender: UIButton)
    {
        let status: Bool = inputControl()
        if status
        {
            checkAddressValidity()
        }
        else
        {
            return
        }
    }
    
    func checkAddressValidity()
    {
        let address = physicalAddressTextField.text!
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            if let err = error
            {
                self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location.", type: .failure)
                print(err.localizedDescription)
            }
            else if let places = placemarks
            {
                if(places.count == 0)
                {
                    self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location.", type: .failure)
                }
                else
                {
                    let location = places.first!.location as? CLLocation
                    if let loc = location
                    {
                        self.latitude = loc.coordinate.latitude
                        self.longitude = loc.coordinate.longitude
                        self.registerUser()
                    }
                    else
                    {
                        self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location", type: .failure)
                    }
                }
            }
            else
            {
                fatalError("The app has encountered a fatal error and will crash.")
            }
        }
    }
    
    func registerUser()
    {
        let user = PFUser()
        user.email = self.emailAddressTextField.text
        user.username = self.emailAddressTextField.text
        user.password = self.passwordTextField.text
        user["fullName"] = self.fullNameTextField.text
        user["address"] = self.physicalAddressTextField.text
        user["longitude"] = self.longitude
        user["latitude"] = self.latitude
        if(self.heroSwitch.isOn)
        {
            user["type"] = "hero"
        }
        else
        {
            user["type"] = "service"
            if(self.parkingSwitch.isOn)
            {
                user["serviceType"] = "parking"
            }
            else if(self.animalSwitch.isOn)
            {
                user["serviceType"] = "animal"
            }
            else if(self.fireSwitch.isOn)
            {
                user["serviceType"] = "fire"
            }
            else
            {
                user["serviceType"] = "trash"
            }
        }
        user.signUpInBackground(block: {
            (result, error) in
            if let err = error
            {
                self.displayAlert(title: "Email error", message: "An account with this email already exists.", type: .failure)
                print(err.localizedDescription)
            }
            else if result
            {
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                fatalError("The app has encountered a fatal error while registering a new user.")
            }
        })
    }
    
    func inputControl() -> Bool
    {
        if fullNameTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the name text field.", type: .failure)
            return false
        }
        else if physicalAddressTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the physical address text field.", type: .failure)
            return false
        }
        else if emailAddressTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the email address text field.", type: .failure)
            return false
        }
        else if passwordTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the password text field.", type: .failure)
            return false
        }
        else if confirmPasswordTextField.text == ""
        {
            displayAlert(title: "Input error", message: "Please fill in the confirm password text field.", type: .failure)
            return false
        }
        else
        {
            if passwordTextField.text != confirmPasswordTextField.text
            {
                displayAlert(title: "Password error", message: "Your passwords do not match.", type: .failure)
                return false
            }
            else
            {
                return true
            }
        }
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
