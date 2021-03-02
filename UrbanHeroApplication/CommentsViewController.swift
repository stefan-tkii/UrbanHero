//
//  CommentsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/15/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var workDateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var commentInputField: UITextField!
    
    @IBOutlet weak var ratingStack: RatingControl!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    var loggedUser: PFObject?
    
    var report: PFObject?
    
    var job: PFObject?
    
    var service: PFObject?
    
    var commentsArray = [PFObject]()
    
    var toDelete: IndexPath?
    
    var loggedEmail: String?
    
    var changeRating: Bool = false
    
    var workPhoto: UIImage?
    
    var activityIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.layer.cornerRadius = 10
        commentTableView.showsVerticalScrollIndicator = false
        commentTableView.separatorStyle = .none
        commentInputField.text = ""
        getRelatedJob()
    }
    
    func getRelatedJob()
    {
        let query = PFQuery(className: "Job")
        .whereKey("problem", equalTo: report!)
            .includeKey("service").includeKey("comments")
        self.setupActivityIndicator()
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
                    self.job = objs[0]
                    let serv = self.job!.object(forKey: "service") as? PFObject
                    if let s = serv
                    {
                        let photo = self.job!.object(forKey: "workPhoto") as? PFFileObject
                        if let p = photo
                        {
                            do
                            {
                                let data = try p.getData()
                                let img = UIImage(data: data)
                                self.workPhoto = img
                            }
                            catch
                            {
                                self.workPhoto = UIImage(named: "notFound")
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            self.workPhoto = UIImage(named: "notFound")
                        }
                        self.service = s
                            self.fillData()
                    }
                }
                else
                {
                    print("Error no job found.")
                }
            }
            else
            {
                fatalError("The app has encountered a fatal error and will crash.")
            }
        })
    }
    
    func disableButtons()
    {
        self.ratingStack.isUserInteractionEnabled = false
        self.submitButton.isEnabled = false
        self.commentInputField.isEnabled = false
        self.searchButton.isEnabled = false
        self.composeButton.isEnabled = false
    }
    
    func enableButtons()
    {
        self.ratingStack.isUserInteractionEnabled = true
        self.submitButton.isEnabled = true
        self.commentInputField.isEnabled = true
        self.searchButton.isEnabled = true
        self.composeButton.isEnabled = true
    }
    
    @IBAction func doComment(_ sender: UIButton)
    {
        if(commentInputField.text == "")
        {
            self.displayAlert(title: "Warning", message: "Please fill out the input field, before submitting a comment.", type: .failure)
            return
        }
        else
        {
            let comment = PFObject(className: "Comment")
            comment["value"] = self.commentInputField.text
            comment["madeBy"] = self.loggedUser!
            self.disableButtons()
            self.setupActivityIndicator()
            comment.saveInBackground(block: {
                (result, error) in
                if let err = error
                {
                    self.enableButtons()
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                }
                else if result
                {
                    DispatchQueue.main.async {
                        self.continueWithChanges()
                    }
                }
                else
                {
                    self.enableButtons()
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Failed to save the comment, due to an uknown error.", type: .failure)
                }
            })
        }
    }
    
    @IBAction func doCompose(_ sender: UIBarButtonItem)
    {
        let rating = self.job!.object(forKey: "rating") as? Int
        let toComp = self.ratingStack.getRating()
        if(rating! == toComp)
        {
            self.displayAlert(title: "Warning", message: "If you wish to change the rating then select a different number of stars.", type: .info)
            return
        }
        else
        {
            self.job!["rating"] = toComp
            self.disableButtons()
            self.setupActivityIndicator()
            self.job!.saveInBackground(block: {
                (result, error) in
                if let err = error
                {
                    self.enableButtons()
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                }
                else if result
                {
                    self.enableButtons()
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Success", message: "Your rating has been updated.", type: .success)
                }
                else
                {
                    self.enableButtons()
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Failed to update the rating, due to an unknown error.", type: .failure)
                }
            })
        }
    }
    
    @IBAction func doSearchPhoto(_ sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "Uploaded photo", message: "The photo uploaded by the service.", preferredStyle: .alert)
        alertController.addImage(image: self.workPhoto!)
        alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupActivityIndicator()
    {
            self.activityIndicator = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .blue, padding: 0)
            self.activityIndicator!.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(activityIndicator!)
            NSLayoutConstraint.activate([
            self.activityIndicator!.widthAnchor.constraint(equalToConstant:
                    40),
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
    
    func fillData()
    {
        let rating = self.job!.object(forKey: "rating") as? Int
        self.ratingStack.setRating(toset: rating!)
        let status = self.job!.object(forKey: "Status") as? String
        self.statusLabel.text = "Status: " + status!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = self.job!.object(forKey: "workDate") as? Date
        if let dat = date
        {
            let dateString = formatter.string(from: dat)
            if(dateString == "")
            {
                self.workDateLabel.text = "Scheduled date: N/A"
            }
            else
            {
                self.workDateLabel.text = "Scheduled date: " + dateString
            }
        }
        else
        {
            self.workDateLabel.text = "Scheduled date: N/A"
        }
            self.getAllComments()
    }
    
    func getAllComments()
    {
        let comments = self.job!.relation(forKey: "comments") as? PFRelation
        if let comm = comments
        {
            let query = comm.query()
            query.addDescendingOrder("createdAt").includeKey("madeBy")
                .findObjectsInBackground(block: {
                (objects, error) in
                if let err = error
                {
                    self.displayAlert(title: "Error", message: "Could not get the comments.", type: .failure)
                    self.stopActivityIndicator()
                    print(err.localizedDescription)
                }
                else if let objs = objects
                {
                    if(objs.count > 0)
                    {
                        self.commentsArray = objs
                        self.stopActivityIndicator()
                        self.commentTableView.reloadData()
                    }
                    else
                    {
                       self.stopActivityIndicator()
                       self.displayAlert(title: "Notification", message: "There are currently no comments associated with this report, be the first to make a statement.", type: .info)
                    }
                }
                else
                {
                    self.stopActivityIndicator()
                    self.displayAlert(title: "Error", message: "Could not get the comments.", type: .failure)
                }
            })
        }
        else
        {
            self.stopActivityIndicator()
            self.displayAlert(title: "Notification", message: "There are currently no comments associated with this report, be the first to make a statement.", type: .info)
        }
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentInputField.resignFirstResponder()
    }
    
    func continueWithChanges()
    {
        let query = PFQuery(className: "Comment")
        query.whereKey("value", equalTo: self.commentInputField.text!)
            .whereKey("madeBy", equalTo: self.loggedUser!)
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
                    let com = objs[0]
                    let comments = self.job!.relation(forKey: "comments") as? PFRelation
                    if let coms = comments
                    {
                        coms.add(com)
                        self.job!.saveInBackground(block: {
                            (result, error) in
                            if let err = error
                            {
                                print(err.localizedDescription)
                            }
                            else if result
                            {
                                DispatchQueue.main.async {
                                    self.updateData()
                                }
                            }
                            else
                            {
                                print("Could not update the job.")
                            }
                        })
                    }
                }
                else
                {
                    print("Error, could not fetch latest comment.")
                }
            }
            else
            {
                print("An unkown error has occured.")
            }
        })
    }
    
    func updateData()
    {
         let query = PFQuery(className: "Job")
               .whereKey("problem", equalTo: report!)
            .includeKey("service").includeKey("comments").addDescendingOrder("createdAt")
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
                           self.job = objs[0]
                           let serv = self.job!.object(forKey: "service") as? PFObject
                           if let s = serv
                           {
                               self.service = s
                                let comments = self.job!.relation(forKey: "comments") as? PFRelation
                                if let comms = comments
                                {
                                    let q = comms.query()
                                    q.addDescendingOrder("createdAt").includeKey("madeBy")
                                    q.findObjectsInBackground(block: {
                                        (objects, error) in
                                        if let err = error
                                        {
                                            print(err.localizedDescription)
                                        }
                                        else if let objs = objects
                                        {
                                            self.commentsArray = objs
                                            self.enableButtons()
                                            self.stopActivityIndicator()
                                            self.commentInputField.text = ""
                                            self.commentTableView.reloadData()
                                        }
                                    })
                                }
                           }
                       }
                       else
                       {
                           print("Error no job found.")
                       }
                   }
                   else
                   {
                       fatalError("The app has encountered a fatal error and will crash.")
                   }
               })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        cell.mainView.layer.cornerRadius = cell.mainView.frame.height/2
        let comment = self.commentsArray[indexPath.row]
        let value = comment.object(forKey: "value") as? String
        cell.titleLabel.text = value!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = comment.createdAt
        let dateString = formatter.string(from: date!)
        cell.dateLabel.text = "Sent at: " + dateString
        let made = comment.object(forKey: "madeBy") as? PFObject
        if let m = made
        {
            let usn = m.object(forKey: "username") as? String
            if usn! == self.loggedEmail!
            {
                cell.subtitleLabel.text = "From: You"
            }
            else
            {
                let name = self.service!.object(forKey: "fullName") as? String
                cell.subtitleLabel.text = "From: " + name!
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let comment = self.commentsArray[indexPath.row]
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
        self.commentTableView.beginUpdates()
        let todel = self.commentsArray[self.toDelete!.row]
        todel.deleteInBackground(block: {
            (result, error) in
            if let err = error
            {
                print(err.localizedDescription)
            }
            else if result
            {
                self.commentsArray.remove(at: self.toDelete!.row)
                self.commentTableView.deleteRows(at: [self.toDelete!], with: .fade)
                self.commentTableView.endUpdates()
            }
            else
            {
                fatalError("An unkown error has occured, and the app will crash.")
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

extension UIAlertController {
    func addImage(image: UIImage)
    {
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image.size
        var ratio: CGFloat!
        if(imgSize.width > imgSize.height)
        {
            ratio = maxSize.width / imgSize.width
        }
        else
        {
            ratio = maxSize.height / imgSize.height
        }
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        let resizedImage = image.imageWithSize(scaledSize)
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}

extension UIImage
{
    func imageWithSize(_ size: CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
