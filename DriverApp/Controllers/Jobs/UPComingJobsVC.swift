//
//  UPComingJobsVC.swift
//  DriverApp
//
//  Created by Appinventiv on 17/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class UPComingJobsVC: UIViewController {

    //MARK:- IBOutlets
    
    @IBOutlet weak var upcomingjobsTableView: UITableView!
    
    
    //MARK:- Properties
    //MARK:- =======================================================================

    var upcomingJobs = JSONDictionaryArray()
    
    
    
    //MARK:- View life cycle
    //MARK:- =======================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.upcomingjobsTableView.dataSource = self
        self.upcomingjobsTableView.delegate = self

        self.upcomingjobsTableView.register(UINib(nibName: "JobsTableViewCell", bundle: nil), forCellReuseIdentifier: "JobsTableViewCell")
        self.upComingJobs()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    //MARK:- Mthods
    //MARK:- =======================================================================

    func upComingJobs(){
        
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        
        myJobsApi(params, SuccessBlock: { (result: JSONDictionary) in
            
            printlnDebug(result)
            if let jobs = result["upcoming"] as? JSONDictionaryArray{
                self.upcomingJobs = jobs
                self.upcomingjobsTableView.reloadData()
            }
            hideLoader()
        })
    }


}


//MARK:- Tableview delegate and datsource
//MARK:- =======================================================================

extension UPComingJobsVC: UITableViewDataSource ,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
            return upcomingJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobsTableViewCell", for: indexPath) as! JobsTableViewCell
        cell.populateData(self.upcomingJobs[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let jobsVC = self.parent as? JobsViewController
        jobsVC?.isPreviousJob = false
        jobsVC?.performSegue(withIdentifier: "jobToJobDetailsViewController", sender: jobsVC)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

}
