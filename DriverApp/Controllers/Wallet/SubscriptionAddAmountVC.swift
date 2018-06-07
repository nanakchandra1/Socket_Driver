//
//  SubscriptionAddAmountVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SubscriptionAddAmountVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet var availableAmtLbl: UILabel!
    @IBOutlet var amtLbl: UILabel!
    @IBOutlet var enterAmntTextField: UITextField!
    @IBOutlet var addAmntBtn: UIButton!
    @IBOutlet weak var enterAmnBgView: UIView!
    @IBOutlet var backBtn: UIButton!
    
    //MARK:- Properties
    //MARK:- =================================================

    var amountstr:String!
    
    
    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationTitle.text = ADD_BALANCE.localized
        self.availableAmtLbl.text = WALLET_BALANCE.localized
        self.addAmntBtn.setTitle(ADD_MONEY.localized, for: .normal)
        
        self.enterAmntTextField.delegate = self
        if let amnt = CurrentUser.amount{
            self.amtLbl.text = "$" + "\(Double(amnt)!.roundTo(places: 2))"
        }else{
            self.amtLbl.text = "$0"
        }
        
        self.enterAmnBgView.layer.borderWidth = 1
         self.enterAmnBgView.layer.borderColor = UIColor.white.cgColor
        self.enterAmnBgView.layer.cornerRadius = 5
        self.enterAmntTextField.attributedPlaceholder = NSAttributedString(string:"ENTER AMOUNT",
        attributes:[NSForegroundColorAttributeName: UIColor.darkGray])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- IBActions
    //MARK:- =================================================


    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addAmntTapped(_ sender: UIButton) {
        
   if self.enterAmntTextField.text == "0" || self.enterAmntTextField.text == "1"{
            showToastWithMessage(WalletStrings.lessAmount)
    
   }else if self.enterAmntTextField.text != ""{
    
    
    let obj = getStoryboard(StoryboardName.Wallet).instantiateViewController(withIdentifier: "PaymentMethodID") as! PaymentMethodViewController
    obj.payAmount = self.enterAmntTextField.text!
    obj.isSidemenu = false
    self.navigationController?.pushViewController(obj, animated: true)
    
   }
    
        else{
    
            showToastWithMessage(WalletStrings.enterAmount)
    
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

//MARK:- TextField Delegate
//MARK:- =================================================


extension SubscriptionAddAmountVC: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
