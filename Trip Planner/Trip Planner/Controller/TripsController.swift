//
//  ViewController.swift
//  Trip Planner
//
//  Created by Fernando on 10/13/17.
//  Copyright © 2017 Specialist. All rights reserved.
//

import UIKit

class TripsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var refresher: UIRefreshControl!
    var trips = [Trip]() {
        didSet{
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = UIColor(red: 1.00, green: 130/255, blue: 45/255, alpha: 0.8)
        refresher.addTarget(self, action: #selector(getTrips), for: .valueChanged)
        getTrips()
    }
    
    @objc func getTrips() {
        let defaults = UserDefaults.standard
        guard let email = defaults.string(forKey: "Email"),
            let password = defaults.string(forKey: "Password")
            else {return}
        
        let basicHeader = BasicAuth.generateBasicAuthHeader(username: email, password: password)
        
        Networking.instance.fetch(route: Route.trips, method: "GET", headers: ["Authorization": basicHeader], data: nil) { (data) in
            
            let trips = try? JSONDecoder().decode([Trip].self, from: data)
            guard let trip_list = trips else {return}
            DispatchQueue.main.async {
                self.trips = trip_list
                self.refresher.endRefreshing()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TripsController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        
        let trip = trips[indexPath.row]
        cell.configureCell(trip: trip)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        print("Bregó la cosa")
        
        performSegue(withIdentifier: "ViewTrip", sender: trip)
    }
}

extension TripsController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTrip" {
            if let destinationVC = segue.destination as? TripViewController{
                if let trip = sender as? Trip {
                    destinationVC.trip = trip
                }
            }
        }
    }
}
