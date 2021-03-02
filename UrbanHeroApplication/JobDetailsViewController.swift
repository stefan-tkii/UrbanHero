//
//  JobDetailsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/17/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class JobDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var job: PFObject?
    
    var loggedUser: PFObject?
    
    var comments = [PFObject]()
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var activityIndicator: NVActivityIndicatorView?
    
    var user: PFObject?
    
    var problem: PFObject?
    
    var loggedEmail: String?
    
    var image: UIImage?
    
    var toDelete: IndexPath?
    
    var foundProblem: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.title = "Details view"
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.layer.cornerRadius = 10
        commentsTableView.showsVerticalScrollIndicator = false
        commentsTableView.separatorStyle = .none
        commentTextField.text = ""
        let sampleImg = UIImage(named: "defaultPhoto")
        self.photoImageView.image = sampleImg!
        checkData()
    }
    
    func toggleButtons(value: Bool)
    {
        self.bookmarkButton.isEnabled = value
        self.submitButton.isEnabled = value
        self.composeButton.isEnabled = value
        self.uploadButton.isEnabled = value
        self.commentTextField.isEnabled = value
        self.datePicker.isEnabled = value
    }
    
    func getReporter()
    {
        let query = PFQuery(className: "Report")
        query.whereKey("objectId", equalTo: self.problem!.objectId!)
        .includeKey("reportedBy")
        self.setupActivityIndicator()
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                self.searchButton.isEnabled = false
                self.displayAlert(title: "Error", message: "Could not obtain information regarding the submitter of this report.", type: .failure)
                print(err.localizedDescription)
                self.bookmarkButton.isEnabled = false
                self.getComments()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    let ob = objs[0]
                    self.foundProblem = ob
                    let repo = ob.object(forKey: "reportedBy") as? PFObject
                    self.user = repo!
                    print("Submitter was found.")
                    self.getComments()
                }
                else
                {
                    self.searchButton.isEnabled = false
                    print("No report found.")
                    self.displayAlert(title: "Error", message: "Could not obtain information regarding the submitter of this report.", type: .failure)
                    self.bookmarkButton.isEnabled = false
                    self.getComments()
                }
            }
            else
            {
                self.searchButton.isEnabled = false
                self.displayAlert(title: "Error", message: "Could not obtain information regarding the submitter of this report.", type: .failure)
                print("Unkown error.")
                self.bookmarkButton.isEnabled = false
                self.getComments()
            }
        })
    }
    
    @IBAction func uploadAction(_ sender: UIButton)
    {
        displayAdvancedAlert()
    }
    
    @IBAction func doCompose(_ sender: UIBarButtonItem)
    {
        setOrUpdateAsResolved()
    }
    
    @IBAction func doBookmark(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "gotoUserDetails", sender: self)
    }
    
    @IBAction func doSubmit(_ sender: UIButton)
    {
        addComment()
    }
    
    func checkData()
    {
        let status = self.job!.object(forKey: "Status") as? String
        if(status! != "Ongoing")
        {
            let fdate = self.job!.object(forKey: "workDate") as? Date
            // let formatter = DateFormatter()
            // formatter.dateFormat = "dd-MM-yyyy HH:mm"
            self.datePicker.setDate(fdate!, animated: true)
            let photo = self.job!.object(forKey: "workPhoto") as? PFFileObject
            if let p = photo
            {
                do
                {
                    let data = try p.getData()
                    let imag = UIImage(data: data)
                    self.photoImageView.image = imag
                }
                catch
                {
                    self.displayAlert(title: "Error", message: "Could not find the uploaded image associated with this job.", type: .failure)
                    self.photoImageView.image = UIImage(named: "notFound")
                    print(error.localizedDescription)
                }
            }
            else
            {
                self.photoImageView.image = UIImage(named: "defaultPhoto")
            }
            self.getReporter()
        }
        else
        {
            let date = Date()
            self.datePicker.setDate(date, animated: true)
            self.photoImageView.image = UIImage(named: "defaultPhoto")
            self.getReporter()
        }
    }
    
    func getComments()
    {
        let coms = self.job!.object(forKey: "comments") as? PFRelation
        if let c = coms
        {
            let query = c.query()
            query.includeKey("madeBy").addDescendingOrder("createdAt")
            query.findObjectsInBackground(block: {
                (objects, error) in
                if let err = error
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Could not get the comments.", type: .failure)
                    print(err.localizedDescription)
                }
                else if let objs = objects
                {
                    if(objs.count > 0)
                    {
                        self.comments = objs
                        self.stopActivityIndicator()
                        self.commentsTableView.reloadData()
                    }
                    else
                    {
                        self.stopActivityIndicator()
                        self.displayAlert(title: "Notification", message: "There are no comments on this report, be the first to make a statement.", type: .info)
                        print("No comments found.")
                    }
                }
                else
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Could not get the comments.", type: .failure)
                    print("Unknown error.")
                }
            })
        }
        else
        {
            self.stopActivityIndicator()
            self.displayAlert(title: "Notification", message: "There are no comments on this report, be the first to make a statement.", type: .info)
            print("No comments found.")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextField.resignFirstResponder()
        datePicker.resignFirstResponder()
    }
    
    func addComment()
    {
        if(self.commentTextField.text == "")
        {
            self.displayAlert(title: "Error", message: "Please fill out the comment field first.", type: .failure)
            return
        }
        else
        {
            let comm = PFObject(className: "Comment")
            comm["value"] = self.commentTextField.text!
            comm["madeBy"] = self.loggedUser!
            self.toggleButtons(value: false)
            self.setupActivityIndicator()
            comm.saveInBackground(block: {
                (result, error) in
                if let err = error
                {
                    self.stopActivityIndicator()
                    self.toggleButtons(value: true)
                    self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                }
                else if result
                {
                    DispatchQueue.main.async {
                        print("New comment has been saved to the database.")
                        self.continueWithCommit()
                    }
                }
                else
                {
                    self.toggleButtons(value: true)
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Failed to save the comment", type: .failure)
                }
            })
        }
    }
    
    func continueWithCommit()
    {
        let query = PFQuery(className: "Comment")
        query.whereKey("value", equalTo: self.commentTextField.text!).whereKey("madeBy", equalTo: self.loggedUser!).includeKey("madeBy")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                fatalError("The app has crashed due to: " + err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    print("Newly added comment has been retrieved.")
                    let c = objs[0]
                    let coms = self.job!.relation(forKey: "comments") as? PFRelation
                    if let com = coms
                    {
                        com.add(c)
                        self.job!.saveInBackground(block: {
                            (result, error) in
                            if let err = error
                            {
                                self.toggleButtons(value: true)
                                print(err.localizedDescription)
                            }
                            else if result
                            {
                                DispatchQueue.main.async {
                                    print("The retrieved comment has been added to the comments relation of the job.")
                                    self.updateData()
                                }
                            }
                            else
                            {
                                self.toggleButtons(value: true)
                                print("An unknown error has occured.")
                            }
                        })
                    }
                }
                else
                {
                    self.toggleButtons(value: true)
                    print("No comments found, while commiting.")
                }
            }
            else
            {
                fatalError("The app has crashed due to an unkown error.")
            }
        })
    }
    
    func updateData()
    {
        print("Inside update data")
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: self.job!.objectId!)
            .includeKey("comments")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                self.toggleButtons(value: true)
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.job = objs[0]
                    let comens = self.job!.relation(forKey: "comments") as? PFRelation
                    if let comn = comens
                    {
                        let q = comn.query()
                        q.addDescendingOrder("createdAt")
                            .includeKey("madeBy")
                        q.findObjectsInBackground(block: {
                            (objects, error) in
                            if let err = error
                            {
                                self.toggleButtons(value: true)
                                print(err.localizedDescription)
                            }
                            else if let objs = objects
                            {
                                if(objs.count > 0)
                                {
                                    self.toggleButtons(value: true)
                                    self.comments = objs
                                    self.stopActivityIndicator()
                                    self.commentTextField.text = ""
                                    self.commentsTableView.reloadData()
                                }
                                else
                                {
                                    self.toggleButtons(value: true)
                                    print("No objects found.")
                                }
                            }
                            else
                            {
                                self.toggleButtons(value: true)
                                print("An unknown error has occured.")
                            }
                        })
                    }
                }
                else
                {
                    self.toggleButtons(value: true)
                    print("Error no job found.")
                }
            }
            else
            {
                fatalError("The app has encountered a fatal error and will crash.")
            }
        })
    }
    
    func setOrUpdateAsResolved()
    {
        let createdAt = self.job!.createdAt
        if(createdAt! > self.datePicker.date)
        {
            self.displayAlert(title: "Error", message: "The date is set to an earlier date than the request date.", type: .failure)
            return
        }
        else {
        self.job!["workDate"] = self.datePicker.date
        self.job!["Status"] = "Resolved"
        if let img = self.image
        {
            let uuid = UUID().uuidString
            let imageData: Data? = img.pngData()
            if let dataImage = imageData
            {
                let imageName = uuid + "." + "png"
                let file = PFFileObject(name: imageName, data: dataImage)
                if let f = file
                {
                    self.job!["workPhoto"] = f
                }
                else
                {
                    self.displayAlert(title: "Error", message: "Could not convert the uploaded image to an appropriate file type, please try with a different image.", type: .failure)
                    return
                }
            }
            else
            {
                self.displayAlert(title: "Error", message: "Could not obtain the data from the uploaded image, please try a different image.", type: .failure)
                return
            }
        }
        self.toggleButtons(value: false)
        self.setupActivityIndicator()
        self.job!.saveInBackground(block: {
            (result, error) in
            if let err = error
            {
                self.stopActivityIndicator()
                self.toggleButtons(value: true)
                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
            }
            else if result
            {
                self.stopActivityIndicator()
                self.toggleButtons(value: true)
                self.displayAlert(title: "Success", message: "The problem has been updated.", type: .success)
            }
            else
            {
                self.stopActivityIndicator()
                self.toggleButtons(value: true)
                self.displayAlert(title: "Error", message: "Failed to update the problem.", type: .failure)
            }
        })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        if segue.identifier == "gotoUserDetails"
        {
            let vc = segue.destination as! UserDetailsViewController
            vc.loggedUser = self.loggedUser!
            vc.submitter = self.user!
            vc.job = self.job!
        }
        else if segue.identifier == "gotoMaps"
        {
            let vc = segue.destination as! MapsViewController
            vc.loggedUser = self.loggedUser!
            vc.report = self.foundProblem!
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uploaded = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.image = uploaded
            self.photoImageView.image = self.image
        }
        else
        {
            self.displayAlert(title: "Image error", message: "The file you have uploaded cannot be converted to an appropriate type of image.", type: .info)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reimaginedComment", for: indexPath) as! ReimaginedCommentCell
        let comment = self.comments[indexPath.row]
        let detail = comment.object(forKey: "value") as? String
        cell.commentLabel.text = detail!
        let made = comment.object(forKey: "madeBy") as? PFObject
        if let m = made
        {
            let usn = m.object(forKey: "username") as? String
            if usn! == self.loggedEmail!
            {
                cell.sentLabel.text = "From: You"
            }
            else
            {
                let name = m.object(forKey: "fullName") as? String
                cell.sentLabel.text = "From: " + name!
            }
        }
        let sentAt = comment.createdAt
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let st = formatter.string(from: sentAt!)
        cell.dateLabel.text = "Sent at: " + st
        cell.mainView.layer.cornerRadius = cell.mainView.frame.height/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let comment = self.comments[indexPath.row]
            let made = comment.object(forKey: "madeBy") as? PFObject
            let usn = made!.object(forKey: "username") as? String
            if usn! == self.loggedEmail!
            {
                self.toDelete = indexPath
                self.deleteComment()
            }
            else
            {
                self.displayAlert(title: "Warning", message: "You cannot delete other user's comments.", type: .info)
                return
            }
        }
    }
    
    func deleteComment()
    {
        self.commentsTableView.beginUpdates()
        let todel = self.comments[self.toDelete!.row]
        todel.deleteInBackground(block: {
            (result, error) in
            if let err = error
            {
                self.displayAlert(title: "Error", message: "Failed to delete this comment.", type: .failure)
                print(err.localizedDescription)
            }
            else if result
            {
                self.comments.remove(at: self.toDelete!.row)
                self.commentsTableView.deleteRows(at: [self.toDelete!], with: .fade)
                self.commentsTableView.endUpdates()
            }
            else
            {
                self.displayAlert(title: "Error", message: "Failed to delete this comment.", type: .failure)
                print("Unkown error.")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    @IBAction func doSearch(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "gotoMaps", sender: self)
    }
    
    func displayAdvancedAlert()
    {
        let alert = SCLAlertView()
        alert.addButton("Camera", target: self, selector: #selector(uploadByCamera(sender:)))
        alert.addButton("Gallery", target: self, selector: #selector(uploadByLibrary(sender:)))
        alert.showInfo("Photo source", subTitle: "Choose from where do you want to grab the photo to upload.")
    }
    
    @objc func uploadByCamera(sender: UIButton)
    {
        let contr = UIImagePickerController()
        contr.delegate = self
        contr.sourceType = UIImagePickerController.SourceType.camera
        contr.allowsEditing = false
        self.present(contr, animated: true)
        {
            
        }
    }
    
    @objc func uploadByLibrary(sender: UIButton)
    {
        let contr = UIImagePickerController()
        contr.delegate = self
        contr.sourceType = UIImagePickerController.SourceType.photoLibrary
        contr.allowsEditing = false
        self.present(contr, animated: true)
        {
            
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
    
}
