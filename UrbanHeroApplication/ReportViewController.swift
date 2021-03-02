//
//  ReportViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/14/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import CoreLocation
import NVActivityIndicatorView

class ReportViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationSwitch: UISwitch!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var parkingSwitch: UISwitch!
    
    @IBOutlet weak var animalSwitch: UISwitch!
    
    @IBOutlet weak var fireSwitch: UISwitch!
    
    @IBOutlet weak var trashSwitch: UISwitch!
    
    @IBOutlet weak var uploadedImageView: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var uploadedImage: UIImage?
    
    var loggedEmail: String?
    
    var service: PFObject?
    
    var loggedUser: PFObject?
    
    let locationManager = CLLocationManager()
    
    var longitude: Double = 0.0
    
    var latitude: Double = 0.0
    
    var flag: Bool = true
    
    var services = [PFObject]()
    
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        uploadButton.isEnabled = true
        saveButton.isEnabled = true
        addressTextField.text = ""
        descriptionTextField.text = ""
        uploadedImageView.image = UIImage(named: "defaultPhoto")
        parkingSwitch.isOn = true
        fireSwitch.isOn = false
        trashSwitch.isOn = false
        animalSwitch.isOn = false
        locationSwitch.isOn = false
        parkingSwitch.addTarget(self, action:#selector(parkingSwitchChanged(switch:)), for:UIControl.Event.valueChanged)
        animalSwitch.addTarget(self, action:#selector(animalSwitchChanged(switch:)), for:UIControl.Event.valueChanged)
        fireSwitch.addTarget(self, action: #selector(fireSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        trashSwitch.addTarget(self, action: #selector(trashSwitchChanged(switch:)), for: UIControl.Event.valueChanged)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        loggedEmail = PFUser.current()!.email
        getUser()
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
        self.addressTextField.isEnabled = false
        self.descriptionTextField.isEnabled = false
        self.parkingSwitch.isEnabled = false
        self.fireSwitch.isEnabled = false
        self.animalSwitch.isEnabled = false
        self.trashSwitch.isEnabled = false
        self.locationSwitch.isEnabled = false
        self.uploadButton.isEnabled = false
        self.saveButton.isEnabled = false
        self.activityIndicator!.startAnimating()
    }
    
    func stopActivityIndicator()
    {
        self.uploadButton.isEnabled = true
        self.saveButton.isEnabled = true
        self.addressTextField.isEnabled = true
        self.descriptionTextField.isEnabled = true
        self.parkingSwitch.isEnabled = true
        self.fireSwitch.isEnabled = true
        self.animalSwitch.isEnabled = true
        self.trashSwitch.isEnabled = true
        self.locationSwitch.isEnabled = true
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.removeFromSuperview()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate
        else
        {
            self.displayAlert(title: "Error", message: "Your current location cannot be accessed, please turn on location services or you won't be able to effectively report the problem.", type: .failure)
            return
        }
        self.longitude = location.longitude
        self.latitude = location.latitude
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        addressTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    func getUser()
    {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: loggedEmail!)
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                fatalError(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count == 0)
                {
                    fatalError("Error failed to get the logged in user.")
                }
                else
                {
                    self.loggedUser = objs[0]
                    print("Logged user has been found.")
                }
            }
            else
            {
                fatalError("The app has crashed due to an unkown error.")
            }
        })
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.uploadedImageView.image = image
            self.uploadedImage = image
        }
        else
        {
            self.displayAlert(title: "Image error", message: "The file you have uploaded cannot be converted to an appropriate type of image.", type: .info)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doUpload(_ sender: UIButton)
    {
        let contr = UIImagePickerController()
        contr.delegate = self
        if(locationSwitch.isOn)
        {
            contr.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        else
        {
            contr.sourceType = UIImagePickerController.SourceType.camera
        }
        contr.allowsEditing = false
        self.present(contr, animated: true)
        {
            
        }
    }
    
    @IBAction func doSave(_ sender: UIBarButtonItem)
    {
        if let imag = self.uploadedImage
        {
            if(addressTextField.text != "")
            {
                if(descriptionTextField.text != "")
                {
                    if(locationSwitch.isOn)
                    {
                        checkAddressValidity()
                    }
                    else
                    {
                        saveProblemOnSpot()
                    }
                }
                else
                {
                    displayAlert(title: "Input error", message: "Please give this problem a description", type: .info)
                }
            }
            else
            {
                displayAlert(title: "Input error", message: "Please fill in the address field", type: .info)
            }
        }
        else
        {
            displayAlert(title: "Input error", message: "Please upload a photo first.", type: .info)
        }
    }
    
    func saveProblemOnSpot()
    {
        let problem = PFObject(className: "Report")
        problem["longitude"] = self.longitude
        problem["latitude"] = self.latitude
        problem["reportedBy"] = self.loggedUser
        problem["description"] = self.descriptionTextField.text
        problem["address"] = self.addressTextField.text
        let currentDateTime = Date()
        problem["date"] = currentDateTime
        if(self.parkingSwitch.isOn)
        {
            problem["type"] = "parking"
        }
        else if(self.animalSwitch.isOn)
        {
            problem["type"] = "animal"
        }
        else if(self.fireSwitch.isOn)
        {
            problem["type"] = "fire"
        }
        else
        {
            problem["type"] = "trash"
        }
        if let img = self.uploadedImage
        {
            let uuid = UUID().uuidString
            let imageData: Data? = img.pngData()
            if let dataImage = imageData
            {
                let imageName = uuid + "." + "png"
                let file = PFFileObject(name: imageName, data: dataImage)
                problem["photo"] = file
                self.setupActivityIndicator()
                problem.saveInBackground(block: {
                    (result, error) in
                    if let err = error
                    {
                        DispatchQueue.main.async {
                            self.stopActivityIndicator()
                            self.displayAlert(title: "Error saving", message: "Could not save the report to the database, perhaps try again with a different image.", type: .failure)
                        }
                    }
                    else if(result)
                    {
                        DispatchQueue.main.async {
                            self.stopActivityIndicator()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else
                    {
                        fatalError("The app has encountered a fatal error while saving the user's report and will crash.")
                    }
                })
            }
            else
            {
                self.displayAlert(title: "Image error", message: "Could not get the data from the uploaded photo, please try a different photo.", type: .failure)
            }
        }
    }
    
    func saveProblemFromHome()
    {
        if flag
        {
            let problem = PFObject(className: "Report")
            problem["longitude"] = self.longitude
            problem["latitude"] = self.latitude
            problem["reportedBy"] = self.loggedUser
            problem["description"] = self.descriptionTextField.text
            problem["address"] = self.addressTextField.text
            let currentDateTime = Date()
            problem["date"] = currentDateTime
            if(self.parkingSwitch.isOn)
            {
                problem["type"] = "parking"
            }
            else if(self.animalSwitch.isOn)
            {
                problem["type"] = "animal"
            }
            else if(self.fireSwitch.isOn)
            {
                problem["type"] = "fire"
            }
            else
            {
                problem["type"] = "trash"
            }
            if let img = self.uploadedImage
            {
                let uuid = UUID().uuidString
                let imageData: Data? = img.pngData()
                if let dataImage = imageData
                {
                    let imageName = uuid + "." + "png"
                    let file = PFFileObject(name: imageName, data: dataImage)
                    problem["photo"] = file
                    self.setupActivityIndicator()
                    problem.saveInBackground(block: {
                        (result, error) in
                        if let err = error
                        {
                            DispatchQueue.main.async {
                                self.stopActivityIndicator()
                                self.displayAlert(title: "Error saving", message: "Could not save the report to the database, perhaps try again with a different image.", type: .failure)
                            }
                        }
                        else if(result)
                        {
                            DispatchQueue.main.async {
                                self.issueReportToService()
                            }
                        }
                        else
                        {
                            fatalError("The app has encountered a fatal error while saving the user's report and will crash.")
                        }
                    })
                }
                else
                {
                    self.displayAlert(title: "Image error", message: "Could not get the data from the uploaded photo, please try a different photo.", type: .failure)
                }
            }
        }
    }
    
    func issueReportToService()
    {
        let query = PFQuery(className: "_User")
        if(self.parkingSwitch.isOn)
        {
            query.whereKey("type", equalTo: "service").whereKey("serviceType", equalTo: "parking")
        }
        else if(self.animalSwitch.isOn)
        {
            query.whereKey("type", equalTo: "service").whereKey("serviceType", equalTo: "animal")
        }
        else if(self.fireSwitch.isOn)
        {
            query.whereKey("type", equalTo: "service").whereKey("serviceType", equalTo: "fire")
        }
        else
        {
            query.whereKey("type", equalTo: "service").whereKey("serviceType", equalTo: "trash")
        }
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.displayAlert(title: "Error saving", message: "Could not save the report to the database, perhaps try again with a different image.", type: .failure)
                }
            }
            else if let objs = objects
            {
                if objs.count > 0
                {
                    DispatchQueue.main.async {
                        self.services = objs
                        self.sendToClosest()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Notification", message: "Sorry but there is currently no service that can resolve your problem, in the future there probably will.", type: .failure)
                        self.removeIssuedReport()
                    }
                }
            }
            else
            {
                fatalError("The app has crashed due to an unkown error.")
            }
        })
    }
    
    func removeIssuedReport()
    {
        let query = PFQuery(className: "Report")
        query.whereKey("reportedBy", equalTo: self.loggedUser!)
            .whereKey("longitude", equalTo: self.longitude)
            .whereKey("latitude", equalTo: self.latitude)
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                let toDel = objs[0]
                toDel.deleteInBackground(block: {
                    (result, error) in
                    if let err = error
                    {
                        print(err.localizedDescription)
                    }
                    else if result
                    {
                        print("Report was deleted.")
                    }
                })
            }
        })
    }
    
    func sendToClosest()
    {
        DispatchQueue.main.async {
            let probCord = CLLocation(latitude: self.latitude, longitude: self.longitude)
            var closest: PFObject = self.services.first!
            let long = closest.object(forKey: "longitude") as? Double
            let lat = closest.object(forKey: "latitude") as? Double
            let serviceCord = CLLocation(latitude: lat!, longitude: long!)
            var distance = probCord.distance(from: serviceCord)
            for service in self.services
            {
                let long = service.object(forKey: "longitude") as? Double
                let lat = service.object(forKey: "latitude") as? Double
                let cord = CLLocation(latitude: lat!, longitude: long!)
                let dst = probCord.distance(from: cord)
                if(dst < distance)
                {
                    distance = dst
                    closest = service
                }
            }
            self.service = closest
            self.send()
        }
    }
    
    func send()
    {
        DispatchQueue.main.async {
            let query = PFQuery(className: "Report")
            query.whereKey("reportedBy", equalTo: self.loggedUser!)
                .whereKey("longitude", equalTo: self.longitude)
                .whereKey("latitude", equalTo: self.latitude)
            query.findObjectsInBackground(block: {
                (objects, error) in
                if let err = error
                {
                    print(err.localizedDescription)
                }
                else if let objs = objects
                {
                    let found = objs[0]
                    let job = PFObject(className: "Job")
                    job["problem"] = found
                    job["service"] = self.service!
                    job["Status"] = "Ongoing"
                    job["rating"] = 0
                    let image = UIImage(named: "notFound")
                    let uuid = UUID().uuidString
                    let imageData: Data? = image!.pngData()
                    if let dataImage = imageData
                    {
                        let imageName = uuid + "." + "png"
                        let file = PFFileObject(name: imageName, data: dataImage)
                        job["workPhoto"] = file
                    }
                    job.saveInBackground(block: {
                        (result, error) in
                        if let err = error
                        {
                            print(err.localizedDescription)
                        }
                        else if result
                        {
                            DispatchQueue.main.async {
                                self.stopActivityIndicator()
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        else
                        {
                            fatalError("The app has encountered a fatal error and has stopped working.")
                        }
                    })
                }
            })
        }
    }
    
    func checkAddressValidity()
    {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.addressTextField.text!) {
            (placemarks, error) in
            if let err = error
            {
                self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location.", type: .failure)
                self.flag = false
                print(err.localizedDescription)
            }
            else if let places = placemarks
            {
                if(places.count == 0)
                {
                    self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location.", type: .failure)
                    self.flag = false
                }
                else
                {
                    let location = places.first!.location as? CLLocation
                    if let loc = location
                    {
                        self.latitude = loc.coordinate.latitude
                        self.longitude = loc.coordinate.longitude
                        self.flag = true
                        self.saveProblemFromHome()
                    }
                    else
                    {
                        self.displayAlert(title: "Address error", message: "The address you have entered does not match any physical location", type: .failure)
                        self.flag = false
                    }
                }
            }
            else
            {
                fatalError("The app has encountered a fatal error and will crash.")
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
