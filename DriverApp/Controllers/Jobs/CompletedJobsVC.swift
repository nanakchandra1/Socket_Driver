//
//  CompletedJobsVC.swift
//  DriverApp
//
//  Created by Appinventiv on 17/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class CompletedJobsVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- ===========================================
    
    @IBOutlet weak var completedjosTableView: UITableView!
    
    
    //MARK:- Properties
    //MARK:- ===========================================
    
    var completedJobs = JSONDictionaryArray()

    
    //MARK:- view life cycle
    //MARK:- ===========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        self.completedjosTableView.register(UINib(nibName: "JobsTableViewCell", bundle: nil), forCellReuseIdentifier: "JobsTableViewCell")
        self.completedjosTableView.dataSource = self
        self.completedjosTableView.delegate = self

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCompletedJobs()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    //MARK:- Methods
    //MARK:- ===========================================

    
    func getCompletedJobs(){
    
        showLoader()
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        
        myJobsApi(params, SuccessBlock: { (result: JSONDictionary) in
            
            printlnDebug(result)
            if let jobs = result["history"] as? JSONDictionaryArray{
                self.completedJobs = jobs
                self.completedjosTableView.reloadData()
            }
            hideLoader()
        })
    }
    
}

extension CompletedJobsVC: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.completedJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobsTableViewCell", for: indexPath) as! JobsTableViewCell
        cell.populateData(self.completedJobs[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let jobsVC = self.parent as? JobsViewController
        driverSharedInstance.rideDetail = self.completedJobs[indexPath.row]
        jobsVC?.isPreviousJob = true
        jobsVC?.performSegue(withIdentifier: "jobToJobDetailsViewController", sender: jobsVC)
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

    
}
