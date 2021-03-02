//
//  AdminDetailsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/20/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class AdminDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var strikes = [PFObject]()
    
    var user: PFObject?
    
    var jobs = [PFObject]()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var statisticsLabel: UILabel!
    
    @IBOutlet weak var submitsLabel: UILabel!
    
    @IBOutlet weak var strikesTableView: UITableView!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var revokeBanButton: UIBarButtonItem!
    
    @IBOutlet weak var mainStack: UIStackView!
    
    var selectedRow: Int?
    
    var ban: PFObject?
    
    var activityIndicator: NVActivityIndicatorView?
    
    var isHero: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.title = "User details"
        topView.layer.shadowColor = UIColor.red.cgColor
        topView.layer.shadowOpacity = 1
        topView.layer.shadowOffset = .zero
        topView.layer.shadowRadius = 10
        let type = user!.object(forKey: "type") as? String
        if(type! == "hero")
        {
            isHero = true
            revokeBanButton.isEnabled = false
        }
        else
        {
            isHero = false
            revokeBanButton.isEnabled = false
        }
        if(isHero!)
        {
            loadHeroView()
        }
        else
        {
            loadServiceView()
        }
    }
    
    @IBAction func revokeBan(_ sender: UIBarButtonItem)
    {
        if let b = self.ban
        {
            b.deleteInBackground(block: {
                (result, error) in
                if let err = error
                {
                    print(err.localizedDescription)
                }
                else if result
                {
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    print("An unknown error has occured.")
                }
            })
        }
    }
    
    func loadHeroView()
    {
        self.setupActivityIndicator()
        strikesTableView.delegate = self
        strikesTableView.dataSource = self
        strikesTableView.isHidden = true
        topView.layer.cornerRadius = 35
        titleLabel.text = "User details"
        let email = user!.object(forKey: "username") as? String
        emailLabel.text = "Email: " + email!
        let name = user!.object(forKey: "fullName") as? String
        fullNameLabel.text = "Name: " + name!
        let type = user!.object(forKey: "type") as? String
        typeLabel.text = "Account type: " + type!
        let addr = user!.object(forKey: "address") as? String
        addressLabel.text = "Address: " + addr!
        loadUserDetails1()
    }
    
    func loadServiceView()
    {
        self.setupActivityIndicator()
        strikesTableView.delegate = self
        strikesTableView.dataSource = self
        strikesTableView.showsVerticalScrollIndicator = false
        strikesTableView.separatorStyle = .none
        strikesTableView.layer.cornerRadius = 25
        topView.layer.cornerRadius = 35
        titleLabel.text = "User details"
        let email = user!.object(forKey: "username") as? String
        emailLabel.text = "Email: " + email!
        let name = user!.object(forKey: "fullName") as? String
        fullNameLabel.text = "Name: " + name!
        let type = user!.object(forKey: "type") as? String
        let servicetype = user!.object(forKey: "serviceType") as? String
        typeLabel.text = "Account type: " + type! + ", " +
        "subtype: " + servicetype!
        let addr = user!.object(forKey: "address") as? String
        addressLabel.text = "Address: " + addr!
        loadServiceDetails1()
    }
    
    func loadUserDetails1()
    {
        let query = PFQuery(className: "Report")
        query.whereKey("reportedBy", equalTo: self.user!)
        .includeKey("reportedBy")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.submitsLabel.text = "Submitted reports: N/A"
                self.statisticsLabel.text = "Strikes against: N/A"
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.submitsLabel.text = "Submitted reports: \(objs.count)"
                    self.loadUserDetails2()
                }
                else
                {
                    self.submitsLabel.text = "Submitted reports: 0"
                    self.loadUserDetails2()
                }
            }
            else
            {
                print("Unknown error.")
                self.submitsLabel.text = "Submitted reports: N/A"
                self.statisticsLabel.text = "Strikes against: N/A"
                self.stopActivityIndicator()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.strikes.removeAll()
    }
    
    func loadUserDetails2()
    {
        let query = PFQuery(className: "Strike")
        query.whereKey("reportAgainst", equalTo: self.user!)
        query.includeKey("reportAgainst")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.statisticsLabel.text = "Strikes against: N/A"
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.statisticsLabel.text = "Strikes against: \(objs.count)"
                    self.getBan()
                }
                else
                {
                    self.statisticsLabel.text = "Strikes against: 0"
                    self.getBan()
                }
            }
            else
            {
                print("Unknown error.")
                self.statisticsLabel.text = "Strikes against: N/A"
                self.stopActivityIndicator()
            }
        })
    }
    
    func getBan()
    {
        let query = PFQuery(className: "Ban")
        query.whereKey("toUser", equalTo: self.user!)
        .includeKey("toUser")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.ban = objs[0]
                    self.revokeBanButton.isEnabled = true
                    self.stopActivityIndicator()
                }
                else
                {
                    self.stopActivityIndicator()
                    self.revokeBanButton.isEnabled = false
                }
            }
            else
            {
                print("An unknown error has occured.")
                self.stopActivityIndicator()
            }
        })
    }
    
    func getStrikes()
    {
        let query = PFQuery(className: "Strike")
        query.whereKey("reportedBy", equalTo: self.user!)
            .includeKey("reportedBy").includeKey("reportAgainst").includeKey("reportOn")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.strikes = objs
                    self.stopActivityIndicator()
                    self.strikesTableView.reloadData()
                }
                else
                {
                    self.stopActivityIndicator()
                    self.strikesTableView.reloadData()
                }
            }
            else
            {
                print("An unknown error has occured.")
                self.stopActivityIndicator()
            }
        })
    }
    
    func loadServiceDetails1()
    {
        let query = PFQuery(className: "Job")
        query.whereKey("service", equalTo: self.user!)
            .includeKey("service").includeKey("problem").includeKey("comments")
        query.findObjectsInBackground(block: {
            (objects, error) in
            if let err = error
            {
                print(err.localizedDescription)
                self.submitsLabel.text = "Number of assignments: N/A"
                self.statisticsLabel.text = "Average rating: N/A"
                self.stopActivityIndicator()
            }
            else if let objs = objects
            {
                if(objs.count > 0)
                {
                    self.submitsLabel.text = "Number of assignments: \(objs.count)"
                    self.jobs = objs
                    var sum: Int = 0
                    for job in self.jobs
                    {
                        let rating = job.object(forKey: "rating") as? Int
                        sum = sum + rating!
                    }
                    let average: Float = Float(sum/objs.count)
                    self.statisticsLabel.text = "Average rating: \(average) stars"
                    self.getStrikes()
                }
                else
                {
                    self.submitsLabel.text = "Number of assignments: 0"
                    self.statisticsLabel.text = "Average rating: 0 stars (not rated yet)"
                    self.stopActivityIndicator()
                    self.strikesTableView.reloadData()
                }
            }
            else
            {
                print("Unknown error.")
                self.submitsLabel.text = "Number of assignments: N/A"
                self.statisticsLabel.text = "Average rating: N/A"
                self.stopActivityIndicator()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        if(segue.identifier == "gotoStrikeDetails")
        {
            let vc = segue.destination as! StrikeDetailsViewController
            let str = self.strikes[self.selectedRow!]
            vc.strike = str
            vc.serviceUser = self.user!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "gotoStrikeDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.isHero!)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "strikeCell", for: indexPath) as! StrikeCell
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "strikeCell", for: indexPath) as! StrikeCell
            cell.mainView.layer.cornerRadius = 25
            let strike = self.strikes[indexPath.row]
            let reportAgainst = strike.object(forKey: "reportAgainst") as? PFObject
            if let r = reportAgainst
            {
                let email = r.object(forKey: "username") as? String
                cell.emailLabel.text = "Email: " + email!
            }
            else
            {
                cell.emailLabel.text = "Email: N/A"
            }
            let reason = strike.object(forKey: "reason") as? String
            cell.reasonLabel.text = "Reason: " + reason!
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            let date = strike.createdAt as? Date
            let dateString = formatter.string(from: date!)
            cell.dateLabel.text = "Report date: " + dateString
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.isHero!)
        {
            return 0
        }
        else
        {
            return strikes.count
        }
    }
    
}
