//
//  AboutViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationLbl: UILabel!
    
    
    var str = ""
    var action = ""
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationLbl.text = ABOUT.localized
        
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {

//        if self.str != "ABOUT"{
//            setMenuButton(self)
//            self.backBtn.hidden = true
//        }
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        self.navigationLbl.text = self.str
        
        self.showTermAndConditions()
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    //MARK:- Functions
    //MARK:- =================================================
    
    func showTermAndConditions() {
        let params = ["action": self.action] as JSONDictionary
        
        showLoader()
        
        ServiceClass.staticPagesApi(params) { (data) in
            
            let html = data["pg_content"].stringValue

            let str1 = html.replacingOccurrences(of: "&lt;", with: "<")
            let str2 = str1.replacingOccurrences(of: "&gt;", with: ">")
            let str3 = str2.replacingOccurrences(of: "&amp;nbsp;", with: " ")
            let str4 = str3.replacingOccurrences(of: "&amp;rsquo;", with: "'")
            let str5 = str4.replacingOccurrences(of: "&amp;ldquo;", with: "\"")
            let str6 = str5.replacingOccurrences(of: "&amp;rdquo;", with: "\"")
            
            self.webView.loadHTMLString(str6, baseURL: nil)
        }
    }
}

    
