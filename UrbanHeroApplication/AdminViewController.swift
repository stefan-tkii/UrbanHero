//
//  AdminViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/13/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import SCLAlertView

class AdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var usersTableView = UITableView()
    
    var tableColor: UIColor?
    
    var pendingColor: UIColor?
    
    var banColor: UIColor?
    
    var bansArray = [PFObject]()
    
    var indexBansArray = [Int]()
    
    var usersArray = [PFObject]()
    
    var strikesArray = [PFObject]()
    
    var indexFlagArray = [Int]()
    
    var strikesToSend = [PFObject]()
    
    var activityIndicator: NVActivityIndicatorView?
    
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableColor = UIColor(red: 1, green: 0.818654706, blue: 0.7097274883, alpha: 1)
        pendingColor = UIColor(red: 0.5426073252, green: 0.6791680323, blue: 1, alpha: 1)
        banColor = UIColor(red: 1, green: 0.3491693455, blue: 0.2426392692, alpha: 1)
        setTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationItem.title = "Admin view"
        strikesToSend.removeAll()
        indexFlagArray.removeAll()
        indexBansArray.removeAll()
        bansArray.removeAll()
        strikesArray.removeAll()
        getUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.strikesArray.removeAll()
        self.bansArray.removeAll()
        self.indexBansArray.removeAll()
        self.indexFlagArray.removeAll()
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
    
    func getUsers()
    {
        let query = PFQuery(className: "_User")
        query.whereKey("type", notEqualTo: "control")
        query.addAscendingOrder("createdAt")
        self.setupActivityIndicator()
        query.findObjectsInBackground(block: {
            (objetcs, error) in
            if let err = error
            {
                self.stopActivityIndicator()
                self.displayAlert(title: "Error", message: err.localizedDescription, type: .failure)
            }
            else if let objs = objetcs
            {
                self.usersArray = objs
                self.getAllStrikes()
            }
            else
            {
                self.stopActivityIndicator()
                self.displayAlert(title: "Error", message: "An unknown error has occured and the users could not be loaded.", type: .failure)
            }
        })
    }
    
    func getAllStrikes()
    {
        let query = PFQuery(className: "Strike")
        query.includeKey("reportedBy").includeKey("reportAgainst").includeKey("reportOn").addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                self.stopActivityIndicator()
                print(err.localizedDescription)
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.strikesArray = objs
                    self.checkForStrikes()
                }
                else
                {
                    self.getAllBans()
                }
            }
            else
            {
                self.stopActivityIndicator()
                print("An unknown error has occured.")
            }
        })
    }
    
    func checkForStrikes()
    {
        var i: Int = 0
        for user in self.usersArray
        {
            for strike in self.strikesArray
            {
                let reporter = strike.object(forKey: "reportedBy") as? PFObject
                if let r = reporter
                {
                    let username1 = r.object(forKey: "username") as? String
                    let username2 = user.object(forKey: "username") as? String
                    if(username1! == username2!)
                    {
                        print("Found " + String(i))
                        self.indexFlagArray.append(i)
                    }
                }
            }
            i = i + 1
        }
        self.getAllBans()
    }
    
    func getAllBans()
    {
        let query = PFQuery(className: "Ban")
        query.includeKey("toUser")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.stopActivityIndicator()
                self.usersTableView.reloadData()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.bansArray = objs
                    self.checkBans()
                }
                else
                {
                    self.stopActivityIndicator()
                    self.usersTableView.reloadData()
                }
            }
            else
            {
                print("An unknown error has occured.")
                self.stopActivityIndicator()
                self.usersTableView.reloadData()
            }
        })
    }
    
    func checkBans()
    {
        var j: Int = 0
        for user in self.usersArray
        {
            for ban in self.bansArray
            {
                print("ban found")
                let comp = ban.object(forKey: "toUser") as? PFObject
                if let c = comp
                {
                    let username1 = user.object(forKey: "username") as? String
                    let username2 = c.object(forKey: "username") as? String
                    if(username1! == username2!)
                    {
                        self.indexBansArray.append(j)
                    }
                }
            }
            j = j + 1
        }
        self.stopActivityIndicator()
        self.usersTableView.reloadData()
    }

    func setTableView()
    {
        usersTableView.frame = self.view.frame
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.separatorColor = UIColor.clear
        usersTableView.backgroundColor = tableColor!
        self.view.addSubview(usersTableView)
        usersTableView.register(UserCell.self, forCellReuseIdentifier: "userCell")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
         let editAction = UITableViewRowAction(style: .normal, title: "Details", handler: {
                   (rowAction, indexPath) in
                self.selectedIndexPath = indexPath
                self.doSegue()
               })
               editAction.backgroundColor = .blue
               return [editAction]
    }
    
    func doSegue()
    {
       performSegue(withIdentifier: "gotoAdminDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        if(segue.identifier == "gotoAdminDetails")
        {
            let vc = segue.destination as! AdminDetailsViewController
            vc.user = self.usersArray[self.selectedIndexPath!.row]
            var flag: Bool = false
            for index in self.indexFlagArray
            {
                if(index == self.selectedIndexPath!.row)
                {
                    flag = true
                }
            }
            if(flag)
            {
                getStrikes()
                print(self.strikesToSend.count)
                vc.strikes = self.strikesToSend
            }
        }
    }
    
    func getStrikes()
    {
        let user = self.usersArray[self.selectedIndexPath!.row]
        for strike in self.strikesArray
        {
            let found = strike.object(forKey: "reportedBy") as? PFObject
            if let f = found
            {
                let username1 = f.object(forKey: "username") as? String
                let username2 = user.object(forKey: "username") as? String
                if(username1! == username2!)
                {
                    self.strikesToSend.append(strike)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        let user = self.usersArray[indexPath.row]
        let username = user.object(forKey: "username") as? String
        cell.userImage.image = UIImage(named: "walterIcon")
        cell.nameLabel.text = username!
        let type = user.object(forKey: "type") as? String
        cell.typeLabel.text = "Type: " + type!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = user.createdAt
        let dateString = formatter.string(from: date!)
        cell.dateLabel.text = "Registered at: " + dateString
        var flag: Bool = false
        cell.backView.backgroundColor = UIColor.white
        for index in self.indexFlagArray
        {
            if(index == indexPath.row)
            {
                flag = true
            }
        }
        if flag
        {
            cell.backView.backgroundColor = self.pendingColor!
        }
        var flag2: Bool = false
        for index in self.indexBansArray
        {
            if(index == indexPath.row)
            {
                print(index)
                flag2 = true
            }
            print(index)
        }
        if flag2
        {
            cell.backView.backgroundColor = self.banColor!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
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
