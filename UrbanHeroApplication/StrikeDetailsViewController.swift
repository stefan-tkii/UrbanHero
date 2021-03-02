//
//  StrikeDetailsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/22/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import SCLAlertView

class StrikeDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var banButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var strikeDescriptionLabel: UILabel!
    
    @IBOutlet weak var strikeReasonLabel: UILabel!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    
    @IBOutlet weak var problemDescriptionLabel: UILabel!
    
    @IBOutlet weak var problemTypeLabel: UILabel!
    
    @IBOutlet weak var problemAddressLabel: UILabel!
    
    @IBOutlet weak var ratingStack: RatingControl!
    
    var strike: PFObject?
    
    var serviceUser: PFObject?
    
    var heroUser: PFObject?
    
    var comments = [PFObject]()
    
    var job: PFObject?
    
    var activityIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(strike!.objectId!)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        topView.layer.shadowColor = UIColor.red.cgColor
        topView.layer.shadowOpacity = 1
        topView.layer.shadowOffset = .zero
        topView.layer.shadowRadius = 10
        commentsTableView.showsVerticalScrollIndicator = false
        commentsTableView.separatorStyle = .none
        commentsTableView.layer.cornerRadius = 25
        topView.layer.cornerRadius = 25
        loadData()
    }
    
    func loadData()
    {
        self.setupActivityIndicator()
        let job = strike!.object(forKey: "reportOn") as? PFObject
        if let j = job
        {
            let query = PFQuery(className: "Job")
            print(j.objectId!)
            query.whereKey("objectId", equalTo: j.objectId!)
            query.includeKey("problem").includeKey("comments")
            query.findObjectsInBackground(block: {
                (objects, error) in
                if let err = error
                {
                    self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                    self.stopActivityIndicator()
                }
                else if let objs = objects
                {
                    if(objs.count > 0)
                    {
                        self.job = objs[0]
                        let rating = self.job!.object(forKey: "rating") as? Int
                        self.ratingStack.setRating(toset: rating!)
                        let desc = self.strike!.object(forKey: "description") as? String
                        self.strikeDescriptionLabel.text = "Description: " + desc!
                        let reason = self.strike!.object(forKey: "reason") as? String
                        self.strikeReasonLabel.text = "Reason: " + reason!
                        let reportAgainst = self.strike!.object(forKey: "reportAgainst") as? PFObject
                        if let r = reportAgainst
                        {
                            self.heroUser = r
                            let em = r.object(forKey: "username") as? String
                            self.userEmailLabel.text = "User email: " + em!
                        }
                        let prob = self.job!.object(forKey: "problem") as? PFObject
                        if let p = prob
                        {
                            let probdesc = p.object(forKey: "description") as? String
                            self.problemDescriptionLabel.text = "Report description: " + probdesc!
                            let probtype = p.object(forKey: "type") as? String
                            self.problemTypeLabel.text = "Problem type: " + probtype!
                            let probaddr = p.object(forKey: "address") as? String
                            self.problemAddressLabel.text = "Location: " + probaddr!
                            let photo = p.object(forKey: "photo") as? PFFileObject
                            if let imag = photo
                            {
                                do
                                {
                                    let data = try imag.getData()
                                    let toset = UIImage(data: data)
                                    self.photoView.image = toset
                                }
                                catch
                                {
                                    self.photoView.image = UIImage(named: "notFound")
                                    print(error.localizedDescription)
                                }
                            }
                            else
                            {
                                self.photoView.image = UIImage(named: "notFound")
                            }
                        }
                        let relation = self.job!.relation(forKey: "comments") as? PFRelation
                        let quer = relation!.query()
                        quer.includeKey("madeBy").addDescendingOrder("createdAt")
                        quer.findObjectsInBackground(block: {
                            (objects, error) in
                            if let err = error
                            {
                                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                                self.stopActivityIndicator()
                            }
                            else if let objs = objects
                            {
                                if(objs.count > 0)
                                {
                                    self.comments = objs
                                    DispatchQueue.main.async {
                                        self.stopActivityIndicator()
                                        self.commentsTableView.reloadData()
                                    }
                                }
                                else
                                {
                                    self.displayAlert(title: "Info", message: "This job has no comments on it.", type: .info)
                                    self.stopActivityIndicator()
                                    self.commentsTableView.reloadData()
                                }
                            }
                            else
                            {
                                self.displayAlert(title: "Error", message: "An unknown error has occured.", type: .failure)
                                self.stopActivityIndicator()
                            }
                        })
                    }
                    else
                    {
                        self.displayAlert(title: "Error", message: "No related job object is found.", type: .failure)
                        self.stopActivityIndicator()
                    }
                }
                else
                {
                    self.displayAlert(title: "Error", message: "An unknown error has occured.", type: .failure)
                    self.stopActivityIndicator()
                }
            })
        }
    }
    
    @IBAction func doBan(_ sender: UIButton)
    {
        let ban = PFObject(className: "Ban")
        ban["toUser"] = self.heroUser!
        let desc = self.strike!.object(forKey: "description") as? String
        ban["description"] = desc!
        let reason = self.strike!.object(forKey: "reason") as? String
        ban["reason"] = reason!
        self.setupActivityIndicator()
        ban.saveInBackground(block: {
            (result, error) in
            if let err = error
            {
                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                self.stopActivityIndicator()
            }
            else if result
            {
                self.strike!.deleteInBackground(block: {
                    (result, error) in
                    if let err = error
                    {
                        self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                        self.stopActivityIndicator()
                    }
                    else if result
                    {
                        self.stopActivityIndicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        self.displayAlert(title: "Error", message: "An unknown error has occured.", type: .failure)
                        self.stopActivityIndicator()
                    }
                })
            }
            else
            {
                self.displayAlert(title: "Error", message: "An unknown error has occured.", type: .failure)
                self.stopActivityIndicator()
            }
        })
    }
    
    @IBAction func doReject(_ sender: UIButton)
    {
        self.setupActivityIndicator()
        self.strike!.deleteInBackground(block: {
            (result, error) in
            if let err = error
            {
                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
                self.stopActivityIndicator()
            }
            else if result
            {
                self.stopActivityIndicator()
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                self.stopActivityIndicator()
                self.displayAlert(title: "Error", message: "An unknown error has occured.", type: .failure)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCommentCell", for: indexPath) as! ReportCommentCell
        cell.mainView.layer.cornerRadius = cell.mainView.frame.height/2
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let comment = self.comments[indexPath.row]
        let desc = comment.object(forKey: "value") as? String
        cell.commentLabel.text = desc!
        let user = comment.object(forKey: "madeBy") as? PFObject
        if let u = user
        {
            let em = u.object(forKey: "username") as? String
            cell.sentLabel.text = "Sent by: " + em!
        }
        let date = comment.createdAt
        let dateString = formatter.string(from: date!)
        cell.dateLabel.text = "Sent at: " + dateString
        return cell
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
