//
//  JobsViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu

class JobsViewController: BaseViewController {

    // MARK: IBOutlets
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var thankYouPopUp: UIView!
    @IBOutlet weak var pickupRequestPopUp: UIView!
    @IBOutlet weak var pagerView: UIView!
    @IBOutlet weak var pagerViewLeadingConstant: NSLayoutConstraint!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var completedJobsButton: UIButton!
    @IBOutlet weak var upcomingJobsButton: UIButton!
    
    //MARK:- Properties
    var isPreviousJob = true
    var completedJobsVC: CompletedJobsVC!
    var upComingJobsVC: UPComingJobsVC!


    
    
    // MARK: View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationTitleLabel.text = MY_JOBS.localized
        self.completedJobsButton.setTitle(COMPLETED_JOBS.localized, for: .normal)
        self.upcomingJobsButton.setTitle(UPCOMING_JOBS.localized, for: .normal)
        
        self.pagerViewLeadingConstant.constant = 0
        self.scrollView.delegate = self
        self.navigationView.setMenuButton()
        self.view.bringSubview(toFront: self.popUpView)
        
        self.initialSetup()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    func initialSetup() {
        
        addChildView()

        self.scrollView.frame.size.width = 2*screenWidth
        
    }
    
    
    
    func addChildView(){
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.completedJobsVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletedJobsVC") as! CompletedJobsVC
        self.scrollView.frame = completedJobsVC.view.frame
        self.scrollView.addSubview(completedJobsVC.view)
        completedJobsVC.willMove(toParentViewController: self)
        self.addChildViewController(completedJobsVC)
        
        
        self.upComingJobsVC = self.storyboard?.instantiateViewController(withIdentifier: "UPComingJobsVC") as! UPComingJobsVC
        self.scrollView.frame = upComingJobsVC.view.frame
        self.scrollView.addSubview(upComingJobsVC.view)
        upComingJobsVC.willMove(toParentViewController: self)
        self.addChildViewController(upComingJobsVC)
        self.completedJobsVC.view.frame.size.height = screenHeight
        self.upComingJobsVC.view.frame.size.height = screenHeight
        self.completedJobsVC.view.frame.origin = CGPoint.zero
        self.upComingJobsVC.view.frame.origin = CGPoint(x: screenWidth, y: 0)
        self.scrollView.contentSize = CGSize(width: screenWidth*2.0,height: 1.0)
        self.scrollView.isPagingEnabled = true
        
    }

    
    
    
    
    
    // MARK: IBActions
    @IBAction func completedJobsBtnTapped(_ sender: UIButton) {
        
        self.pagerViewLeadingConstant.constant = self.scrollView.contentOffset.x/2
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)

    }
    
    @IBAction func upcomingJobsBtnTapped(_ sender: UIButton) {
        self.pagerViewLeadingConstant.constant = self.scrollView.contentOffset.x/2
        self.scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width , y: 0), animated: true)
    }
    
    @IBAction func thankYouPopUpCancelBtnTapped(_ sender: UIButton) {
    }
    
    @IBAction func pickupRequestNOBtnTapped(_ sender: UIButton) {
    }
    
    @IBAction func pickupRequestYESBtnTapped(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobToJobDetailsViewController" {
            let jobDetailVC = segue.destination as! JobDetailVC
            jobDetailVC.isPreviousJob = self.isPreviousJob
        }
    }
    
}


extension JobsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pagerViewLeadingConstant.constant = self.scrollView.contentOffset.x/2

//        if self.pagerViewLeadingConstant.constant == screenWidth / 2{
//            self.pagerViewLeadingConstant.constant = 0
//
//        }else if self.pagerViewLeadingConstant.constant == 0{
//            self.pagerViewLeadingConstant.constant = screenWidth / 2
//        }
    }
}
