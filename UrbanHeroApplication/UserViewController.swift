//
//  UserViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/13/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reportTableView: UITableView!
    
    var selectedIndex = -1
    
    var isCollapsed = false
    
    var loggedEmail: String?
    
    var loggedUser: PFObject?
    
    var dataArray = [PFObject]()
    
    var toDelete: IndexPath?
    
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationItem.title = "Main view"
        reportTableView.layer.cornerRadius = 10
        reportTableView.estimatedRowHeight = 400
        self.isCollapsed = false
        self.selectedIndex = -1
        reportTableView.rowHeight = UITableView.automaticDimension
        reportTableView.delegate = self
        reportTableView.dataSource = self
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
           self.activityIndicator!.startAnimating()
       }
       
       func stopActivityIndicator()
       {
           self.activityIndicator!.stopAnimating()
           self.activityIndicator!.removeFromSuperview()
       }
    
     func getUser()
       {
           let query = PFQuery(className: "_User")
           query.whereKey("username", equalTo: loggedEmail!)
            self.setupActivityIndicator()
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
                        self.getData()
                   }
               }
               else
               {
                   fatalError("The app has crashed due to an unkown error.")
               }
           })
       }
    
    func getData()
    {
        let query = PFQuery(className: "Report")
        query.whereKey("reportedBy", equalTo: self.loggedUser!)
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                self.stopActivityIndicator()
                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.dataArray = objs
                    self.stopActivityIndicator()
                    self.reportTableView.reloadData()
                }
                else
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Info", message: "You have not submitted any reports.", type: .info)
                }
            }
            else
            {
                fatalError("The application has crashed due to an unkown error.")
            }
        })
    }
    
    @IBAction func doLogout(_ sender: UIBarButtonItem)
    {
         PFUser.logOutInBackground(block: {
                   (error) in
                   if let err = error
                   {
                       print(err.localizedDescription)
                   }
                   else
                   {
                    self.navigationController?.popViewController(animated: true)
                   }
               })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        if(segue.identifier == "gotoComments")
        {
            let vc = segue.destination as! CommentsViewController
            vc.loggedUser = self.loggedUser
            vc.report = self.dataArray[self.selectedIndex]
            vc.loggedEmail = self.loggedEmail!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == indexPath.row && self.isCollapsed == true
        {
            return 400
        }
        else
        {
            return 220
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let report = self.dataArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "foldingCell", for: indexPath) as! FoldingCell
        let addr = report.object(forKey: "address") as? String
        cell.addressLabel.text = "Address: " + addr!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = report.object(forKey: "date") as? Date
        let dateString = formatter.string(from: date!)
        cell.dateLabel.text = "Date requested: " + dateString
        let desc = report.object(forKey: "description") as? String
        cell.descriptionLabel.text = "Description: " + desc!
        let photo = report["photo"] as? PFFileObject
        if let f = photo
        {
            do
            {
                let data = try f.getData()
                let img = UIImage(data: data)
                cell.uploadedImageView.image = img
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        else
        {
            cell.uploadedImageView.image = UIImage(named: "defaultPhoto")
        }
        cell.topView.layer.cornerRadius = cell.topView.frame.height/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        if self.selectedIndex == indexPath.row
        {
            if self.isCollapsed == false
            {
                self.isCollapsed = true
            }
            else
            {
                self.isCollapsed = false
            }
        }
        else
        {
            self.isCollapsed = true
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    /*
    
    func moveToOtherView()
    {
        let alert = SCLAlertView()
        alert.addButton("Proceed", target: self, selector: #selector(self.doSegue(sender:)))
        alert.showInfo("Notification", subTitle: "Tap proceed to view the comments page, tap done to expand the details.")
    }
    
    @objc func doSegue(sender: UIButton)
    {
        self.performSegue(withIdentifier: "gotoComments", sender: self)
    }
     */
    
    /*
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            self.toDelete = indexPath
            self.displayAdvancedAlert()
        }
    }
     
     */
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {
            (rowAction, indexPath) in
            self.selectedIndex = indexPath.row
         self.performSegue(withIdentifier: "gotoComments", sender: self)
        })
        editAction.backgroundColor = .blue
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Cancel", handler: {
            (rowAction, indexPath) in
            self.toDelete = indexPath
            self.displayAdvancedAlert()
        })
        deleteAction.backgroundColor = .red
        return [editAction, deleteAction]
    }
    
    func displayAdvancedAlert()
    {
        let alertView = SCLAlertView()
        alertView.addButton("Proceed", target: self, selector:#selector(doDelete(sender:)))
        alertView.showWarning("Warning", subTitle: "Do you wish to proceed, this action cannot be undone.")
    }
    
    @objc func doDelete(sender: UIButton)
    {
        let report = self.dataArray[self.toDelete!.row]
        let reportDate = report.createdAt
        let date = Date()
        let interval = date.timeIntervalSince(reportDate!)
        let number = Int(interval)
        if(number > 3600)
        {
            print(number)
            self.displayAlert(title: "Error", message: "Cannot delete a request after an hour has passed.", type: .failure)
            return
        }
        else {
        let query = PFQuery(className: "Job")
        query.whereKey("problem", equalTo: report)
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    let job = objs[0]
                    let status = job.object(forKey: "Status") as? String
                    if(status! == "Ongoing")
                    {
                        self.proceedWithDelete()
                    }
                    else
                    {
                        self.displayAlert(title: "Error", message: "Cannot cancel this report, considering that it is already set as finished by the service.", type: .failure)
                    }
                }
                else
                {
                    print("Error no job found.")
                }
            }
            else
            {
                print("An unkown error has occured.")
            }
        })
        }
        
    }
    
    func proceedWithDelete()
    {
        let r = self.dataArray[self.toDelete!.row]
        self.reportTableView.beginUpdates()
        r.deleteInBackground(block: {
            (result, error) in
            if let err = error
            {
                let alertView = SCLAlertView()
                alertView.showError("Error", subTitle: "Failed to delete this report, please try again.")
            }
            else if result
            {
                self.dataArray.remove(at: self.toDelete!.row)
                self.reportTableView.deleteRows(at: [self.toDelete!], with: .fade)
                self.reportTableView.endUpdates()
            }
            else
            {
                fatalError("Error the app has encountered a fatal error while deleting a report.")
            }
        })
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
