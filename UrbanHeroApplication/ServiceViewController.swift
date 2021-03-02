//
//  ServiceViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/13/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class ServiceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var jobTableView: UITableView!
    
    var jobArray = [PFObject]()
    
    var loggedEmail: String?
    
    var loggedUser: PFObject?
    
    var loggedLocation: CLLocation?
    
    var selectedIndex = -1
    
    var isCollapsed = false
    
    var selectedIndexPath: IndexPath?
    
    var activityIndicator: NVActivityIndicatorView?
    
    var comments: PFRelation<PFObject>?
    
    var finishedColor: UIColor?
    
    var deletedReports = [Int]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationItem.title = "Main view"
        self.loggedEmail = PFUser.current()!.email
        jobTableView.layer.cornerRadius = 10
        jobTableView.estimatedRowHeight = 380
        jobTableView.showsVerticalScrollIndicator = false
        jobTableView.separatorStyle = .none
        self.isCollapsed = false
        self.selectedIndex = -1
        self.jobTableView.delegate = self
        self.jobTableView.dataSource = self
        finishedColor = UIColor(red: 0.6819480625, green: 1, blue: 0.4320287588, alpha: 0.7887323944)
        self.getLoggedUser()
    }
    
    func getLoggedUser()
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
                    let long = self.loggedUser!.object(forKey: "latitude") as?
                    Double
                    print(long!)
                    let lat = self.loggedUser!.object(forKey: "longitude") as? Double
                    print(lat!)
                    self.loggedLocation = CLLocation(latitude: lat!, longitude: long!)
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
        let query = PFQuery(className: "Job")
        query.whereKey("service", equalTo: self.loggedUser!).includeKey("problem").includeKey("service")
        .includeKey("comments")
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
                    print("Objects have been found.")
                    self.jobArray = objs
                    self.stopActivityIndicator()
                    self.jobTableView.reloadData()
                }
                else
                {
                    self.stopActivityIndicator()
                    print("No objects found.")
                }
            }
            else
            {
                fatalError("The app has encountered an unkown problem and will crash.")
            }
        })
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
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           if self.selectedIndex == indexPath.row && self.isCollapsed == true
           {
            return 380
           }
           else
           {
            return 140
           }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCell
        let job = self.jobArray[indexPath.row]
        let prob = job.object(forKey: "problem") as? PFObject
        if let p = prob
        {
            let desc = p.object(forKey: "description") as? String
            cell.descriptionLabel.text = "Description: " + desc!
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            let date = p.object(forKey: "date") as? Date
            let dateString = formatter.string(from: date!)
            cell.dateLabel.text = "Submitted at: " + dateString
            let addr = p.object(forKey: "address") as? String
            cell.addressLabel.text = "Address: " + addr!
            let long = p.object(forKey: "longitude") as? Double
            let lat = p.object(forKey: "latitude") as? Double
            print(lat!)
            print(long!)
            let pcord = CLLocation(latitude: lat!, longitude: long!)
            let distance = pcord.distance(from: self.loggedLocation!)/100000
            print(distance)
            cell.distanceLabel.text = "Distance: " + "\(distance)" + " Km"
            let photo = p.object(forKey: "photo") as? PFFileObject
            if let imag = photo
            {
                do
                {
                    let data = try imag.getData()
                    let image = UIImage(data: data)
                    cell.photoImageView.image = image
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
            else
            {
                cell.photoImageView.image = UIImage(named: "notFound")
            }
        }
        else
        {
            self.deletedReports.append(indexPath.row)
            print(indexPath.row)
            cell.descriptionLabel.text = "No data, this report has been cancelled by the user."
            cell.addressLabel.text = "You can delete this job request at your own will."
            cell.dateLabel.text = " "
            cell.distanceLabel.text = " "
            cell.photoImageView.image = UIImage(named: "notFound")
        }
        let status = job.object(forKey: "Status") as? String
        if(status! == "Resolved")
        {
            cell.secView.backgroundColor = self.finishedColor!
        }
        cell.secView.layer.cornerRadius = cell.secView.frame.height/2
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
         let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {
                   (rowAction, indexPath) in
                self.selectedIndexPath = indexPath
                self.doSegue()
               })
               editAction.backgroundColor = .blue
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove", handler: {
            (rowAction, indexPath) in
            self.selectedIndexPath = indexPath
            self.displayAdvancedAlert()
        })
        deleteAction.backgroundColor = .red
               return [editAction, deleteAction]
    }
    
    func displayAdvancedAlert()
    {
        let alertView = SCLAlertView()
        alertView.addButton("Remove", target: self, selector:#selector(doDelete(sender:)))
        alertView.showWarning("Warning", subTitle: "Do you wish to proceed, this action cannot be undone.")
    }
    
    @objc func doDelete(sender: UIButton)
    {
        var flag = false
        for index in self.deletedReports
        {
            print(self.selectedIndexPath!.row)
            if(index == self.selectedIndexPath!.row)
            {
                flag = true
                break
            }
        }
        if flag
        {
            self.jobTableView.beginUpdates()
            let job = self.jobArray[self.selectedIndexPath!.row]
            let fetchedComments = job.relation(forKey: "comments") as? PFRelation
            if let f = fetchedComments
            {
                self.comments = f
            }
            job.deleteInBackground(block: {
                (result, error) in
                if let err = error
                {
                    let alertView = SCLAlertView()
                alertView.showError("Error", subTitle: "Failed to delete this job, please try again.")
                }
                else if result
                {
                    self.jobArray.remove(at: self.selectedIndexPath!.row)
                    self.jobTableView.deleteRows(at: [self.selectedIndexPath!], with: .fade)
                    self.jobTableView.endUpdates()
                    self.deleteComments()
                }
                else
                {
                    fatalError("Error the app has encountered a fatal error while deleting a report.")
                }
            })
        }
        else
        {
            self.displayAlert(title: "Error", message: "Cannot cancel this job, considering that the user has not cancelled the report first.", type: .failure)
        }
    }
    
    func deleteComments()
    {
        if let toDel = self.comments
        {
            self.setupActivityIndicator()
            let query = toDel.query()
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
                        PFObject.deleteAll(inBackground: objs, block: {
                            (result, error) in
                            if let err = error
                            {
                                self.stopActivityIndicator()
                                print(err.localizedDescription)
                            }
                            else if result
                            {
                                self.stopActivityIndicator()
                                print("All comments have been removed.")
                            }
                            else
                            {
                                self.stopActivityIndicator()
                                print("Unkown error while deleting comments.")
                            }
                        })
                    }
                    else
                    {
                        print("No comments to delete.")
                    }
                }
                else
                {
                    print("Unkown error.")
                }
            })
        }
    }
    
    func doSegue()
    {
        var flag = true
        for index in self.deletedReports
        {
            if(index == self.selectedIndexPath!.row)
            {
                flag = false
                break
            }
        }
        if(flag)
        {
            self.performSegue(withIdentifier: "gotoDetails", sender: self)
        }
        else
        {
            self.displayAlert(title: "Error", message: "The details page cannot be viewed because the user has cancelled the report.", type: .failure)
        }
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
           if(segue.identifier == "gotoDetails")
           {
            let vc = segue.destination as! JobDetailsViewController
            let object = self.jobArray[self.selectedIndexPath!.row]
            let prob = object.object(forKey: "problem") as? PFObject
            vc.problem = prob
            vc.loggedUser = self.loggedUser!
            vc.loggedEmail = self.loggedEmail!
            vc.job = object
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
