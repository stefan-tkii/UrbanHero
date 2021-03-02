//
//  MapsViewController.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/23/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import NVActivityIndicatorView

class MapsViewController: UIViewController {
    
    var loggedUser: PFObject?
    
    var report: PFObject?
    
    var activityIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func initMap()
    {
        self.setupActivityIndicator()
        let long = report!.object(forKey: "longitude") as? Double
        let lat = report!.object(forKey: "latitude") as? Double
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        do
        {
            if let styleUrl = Bundle.main.url(forResource: "style", withExtension: "json")
            {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleUrl)
            }
            else
            {
                print("Unable to find the style.json file.")
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        self.view.addSubview(mapView)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.title = "User's report"
        marker.snippet = "Location of issue"
        marker.map = mapView
        self.stopActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initMap()
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
