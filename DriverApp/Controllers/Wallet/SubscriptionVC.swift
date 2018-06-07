//
//  SubscriptionVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet weak var navigationView: UIView!
    
    @IBOutlet var availableamnttextLbl: UILabel!
    @IBOutlet var availableAmntLbl: UILabel!
    @IBOutlet var addAmntBtn: UIButton!
    @IBOutlet var couponCountLbl: UILabel!
    @IBOutlet var lastTransactionLbl: UILabel!
    @IBOutlet var lastTransTableView: UITableView!
    
    
    //MARK:- properties
    //MARK:- =================================================

    
    var myTrasactions = JSONDictionaryArray()
    
    
    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationTitle.text = MY_WALLET.localized
        self.availableAmntLbl.text = WALLET_BALANCE.localized
        self.lastTransactionLbl.text = C_LAST_TRANSACTIONS.localized
        self.addAmntBtn.setTitle(ADD_BALANCE.localized, for: .normal)
        
        self.lastTransTableView.delegate = self
        self.lastTransTableView.dataSource = self
        self.addAmntBtn.layer.borderWidth = 2
        self.addAmntBtn.layer.borderColor = UIColor(red: 194 / 255, green: 0 / 255, blue: 52 / 255, alpha: 1).cgColor
        self.addAmntBtn.layer.cornerRadius = 55 / 2
        self.navigationView.setMenuButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        if let amnt = CurrentUser.amount{
            self.availableAmntLbl.text = "$" + "\(Double(amnt)!.roundTo(places: 2))"
        }else{
            self.availableAmntLbl.text = "$0"
        }
        self.getMyTransactions()

    }

    //MARK:- IBActions
    //MARK:- =================================================

    
    
    @IBAction func addAmountTapped(_ sender: UIButton) {
        
        let objVC = getStoryboard(StoryboardName.Wallet).instantiateViewController(withIdentifier: "SubscriptionAddAmountVC") as! SubscriptionAddAmountVC
        objVC.amountstr = self.availableAmntLbl.text
        self.navigationController?.pushViewController(objVC, animated: true)
        
    }
    
    
    //MARK:- Functions
    //MARK:- =================================================

    
    func getMyTransactions(){
        showLoader()
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        
        ServiceClass.myTransactionAPI(params) { (result, amount) in
            
            self.myTrasactions = result.arrayObject as! JSONDictionaryArray
            self.availableAmntLbl.text = "$" + amount
            self.lastTransTableView.reloadData()

        }
        

        
//        ServiceController.myTransactionApi(params, SuccessBlock: { (result:JSONDictionaryArray) in
//            printlnDebug(result)
//            self.myTrasactions = result
//            CommonClass.stopLoader()
//            self.lastTransTableView.reloadData()
//        }) { (error: NSError) in
//            CommonClass.stopLoader()
//            printlnDebug(error)
//        }
    }
}


//MARK:- TableView Delegate Datasource
//MARK:- =================================================


extension SubscriptionVC: UITableViewDelegate, UITableViewDataSource{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myTrasactions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionLastTransactionCell", for: indexPath) as! SubscriptionLastTransactionCell
        
        if let desc = self.myTrasactions[indexPath.row]["description"] as? String{
            let str = desc.replacingOccurrences(of: "$", with: "")
            cell.codeLbl.text = "$\(str)"
        }
        if let amnt = self.myTrasactions[indexPath.row]["amount"]{
            cell.amntLbl.text = "$\(amnt)"
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }


}


//MARK:- TableView Cell Class
//MARK:- =================================================


class SubscriptionLastTransactionCell: UITableViewCell {
    
    @IBOutlet weak var amntLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
