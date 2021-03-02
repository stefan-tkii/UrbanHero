//
//  UserDetailsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/18/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class UserDetailsViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var userRating: RatingControl!
    
    @IBOutlet weak var reasonInputField: UITextField!
    
    @IBOutlet weak var typeSwitch: UISwitch!
    
    var submitter: PFObject?
    
    var loggedUser: PFObject?
    
    var job: PFObject?
    
    var isReported: Bool?
    
    var activityIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupActivityIndicator()
        typeSwitch.isOn = false
        reasonInputField.text = ""
        fillData()
    }
    
    func fillData()
    {
        let rating = job!.object(forKey: "rating") as? Int
        userRating.setRating(toset: rating!)
        let email = submitter!.object(forKey: "username") as? String
        emailLabel.text = "Email: " + email!
        let fullName = submitter!.object(forKey: "fullName") as? String
        fullNameLabel.text = "Full name: " + fullName!
        let address = submitter!.object(forKey: "address") as? String
        addressLabel.text = "Address: " + address!
        checkIfAlreadyReported()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reasonInputField.resignFirstResponder()
    }
    
    func checkIfAlreadyReported()
    {
        let query = PFQuery(className: "Strike")
        query.whereKey("reportedBy", equalTo: self.loggedUser!)
            .whereKey("reportOn", equalTo: self.job!)
            .whereKey("reportAgainst", equalTo: self.submitter!)
    .includeKey("reportedBy").includeKey("reportAgainst").includeKey("reportOn")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                self.isReported = false
                self.stopActivityIndicator()
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.stopActivityIndicator()
                    self.isReported = true
                }
                else
                {
                    self.stopActivityIndicator()
                    self.isReported = false
                }
            }
            else
            {
                self.stopActivityIndicator()
                self.isReported = false
                print("An unknown error has occured.")
            }
        })
    }
    
    @IBAction func doReport(_ sender: UIButton)
    {
        if(isReported!)
        {
            displayAlert(title: "Error", message: "You have already reported this user.", type: .warning)
            return
        }
        else {
        if(reasonInputField.text == "")
        {
            displayAlert(title: "Error", message: "Please write down your reasoning.", type: .failure)
        }
        else
        {
            let strike = PFObject(className: "Strike")
            strike["description"] = reasonInputField.text!
            if(typeSwitch.isOn)
            {
                strike["reason"] = "Fraud"
            }
            else
            {
                strike["reason"] = "Bad behaviour"
            }
            strike["reportOn"] = self.job!
            strike["reportedBy"] = self.loggedUser!
            strike["reportAgainst"] = self.submitter!
            setupActivityIndicator()
            strike.saveInBackground(block: {
                (result, error) in
                if let err = error
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                }
                else if result
                {
                    self.reasonInputField.text = ""
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Success", message: "This user has been reported.", type: .success)
                }
                else
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Could not submit the strike, due to an unkown error", type: .failure)
                }
            })
        }
        }
    }
    
    enum alertType
    {
        case success
        case failure
        case info
        case warning
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
        case .warning:
            alert.showWarning(title, subTitle: message)
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
    
}
