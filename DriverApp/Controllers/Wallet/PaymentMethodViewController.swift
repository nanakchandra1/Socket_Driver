//
//  PaymentMethodViewController.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

enum Sender {
    case choosePayment
    case sideMenu
}

enum CouponCodeStatus {
    
    case apply, change
    
}


class PaymentMethodViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addCardBtn: UIButton!
    @IBOutlet var makePayHeightConstraint: NSLayoutConstraint!
    @IBOutlet var makePaymentBtn: UIButton!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var yourPaymentMethodLabel: UILabel!
    
    // MARK: Constants
    //MARK:- =================================================
    
    var selectedIndex: IndexPath?
    var editedIndex: IndexPath?
    var filledCircle = UIImage(named: "booking_circle_filled")
    var blankCircle = UIImage(named: "booking_circle")
    var isSidemenu = true
    var payAmount = ""
    var card_token = ""
    
    
    // MARK: Variables
    //MARK:- =================================================
    
   // weak var delegate: SetPaymentModeDelegate?
    
    var cardDetail = JSONDictionaryArray()
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let stripe =  CurrentUser.stripe_id, stripe != ""{
            
            self.getCardDetails(stripe)
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
    }
    
    
    
    // MARK: IBActions
    //MARK:- =================================================
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addCardBtnTapped(_ sender: UIButton) {
        
        let obj = getStoryboard(StoryboardName.Wallet).instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
        obj.isCardAdd = true
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    @IBAction func makePaymentBtnTapped(_ sender: UIButton) {
        
        if self.card_token != ""{
            
            self.addAmountToWallet()

        }else{
        
            showToastWithMessage("Please select card")
        }
        
    }
    
    
    // MARK: Prvarte Methods
    //MARK:- =================================================
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }
    
    
    
    func initialSetup() {
        
        self.navigationTitleLabel.text = PAYMENT_METHODS.localized
        self.yourPaymentMethodLabel.text = YOUR_PAYMENT_METHODS.localized
        self.makePaymentBtn.setTitle(MAKE_PAYMENT.localized, for: .normal)
        
        if CurrentUser.card_token != nil{
            self.card_token = CurrentUser.card_token!
        }
        self.paymentTableView.dataSource = self
        self.paymentTableView.delegate = self
        
        if self.isSidemenu{
            
            self.navigationView.setMenuButton()
            self.makePaymentBtn.isHidden = true
            self.backBtn.isHidden = true
            self.makePayHeightConstraint.constant = 0
            
        }else{
            
            self.makePaymentBtn.isHidden = false
            self.makePayHeightConstraint.constant = 45
            self.backBtn.isHidden = false

        }
    }
    
    
    
    func getCardDetails(_ stripe: String){
        
        var params = JSONDictionary()
        showLoader()
        params["stripe"] = stripe as AnyObject
        saveCardDetailAPI(params, SuccessBlock: { (result: JSONDictionaryArray) in
            printlnDebug(result)
            self.cardDetail = result
            self.paymentTableView.reloadData()
            hideLoader()
        }) { (error: NSError) in
            printlnDebug(error)
            hideLoader()
        }
        
    }
    
    
    
    func removeCard(_ index: Int){
        
        var cardDetail = JSONDictionaryArray()
        cardDetail = self.cardDetail
        cardDetail.remove(at: index)
        var params = JSONDictionary()
        if let stripe = CurrentUser.stripe_id, stripe != "" {
            
            params["stripe"] = stripe as AnyObject
            if let cardId = self.cardDetail[index]["id"]{
                params["cardID"] = cardId
            }
        }
        
        showLoader()
        removeSaveCardApi(params, SuccessBlock: { (result: Bool) in
            hideLoader()
            self.cardDetail.remove(at: index)
            self.paymentTableView.reloadData()
        }) { (error: NSError) in
            printlnDebug(error)
            hideLoader()

        }
    }
    
    
    
    
    
    func setDefaultPaymentMethod(_ p_mode: String){
        
        var params = JSONDictionary()
        params["p_mode"] = p_mode as AnyObject
        showLoader()
        
        ServiceClass.setDefaultPayMethodAPI(params) { (success) in
            
            if let card_token = self.cardDetail[(self.selectedIndex?.row)!]["id"] as? String{
                
                UserDefaults.save(card_token as AnyObject, forKey: NSUserDefaultKey.CARD_TOKEN)
            }
            
            self.paymentTableView.reloadData()

        }
        
//        setDefaultPayMethodAPI(params, SuccessBlock: { (data) in
//            hideLoader()
//            printlnDebug(data)
//            
//            if let card_token = self.cardDetail[(self.selectedIndex?.row)!]["id"] as? String{
//                
//                UserDefaults.save(card_token as AnyObject, forKey: NSUserDefaultKey.CARD_TOKEN)
//
//            }
//
//                self.paymentTableView.reloadData()
//                
//        }) { (error: NSError) in
//            
//            printlnDebug(error)
//            hideLoader()
//            
//        }
    }
    
    func addAmountToWallet(){
        
        var params = JSONDictionary()
        
        params["action"] = "save_card" as AnyObject
        params["stripe_id"] = CurrentUser.stripe_id! as AnyObject
        params["token"] = self.card_token as AnyObject
        params["amount"] = self.payAmount as AnyObject
        printlnDebug(params)
        
        showLoader()
        addMoneyApi(params, SuccessBlock: { (data) in
            
            hideLoader()
            if let amnt = data["balance"]{
                UserDefaults.save("\(amnt)" as AnyObject, forKey: NSUserDefaultKey.AMOUNT)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
        })

    }
    
}


// MARK: Table View Delegate and datasource
//MARK:- =================================================

extension PaymentMethodViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return self.cardDetail.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
        
        let card = self.cardDetail[indexPath.row]
        
        let id = card["id"] as? String ?? ""
        
        if CurrentUser.card_token != nil{
        
            if CurrentUser.card_token == id{
                
                cell.checkImage.image = self.filledCircle

            }else{
                
                cell.checkImage.image = self.blankCircle

            }
            
        }else{
            cell.checkImage.image = self.blankCircle

        }
        
        cell.tapEditBtn.isHidden = false
        
        if self.editedIndex == indexPath {
            cell.deleleBtn.isHidden = false
        }
        else{
            
            cell.deleleBtn.isHidden = true
        }
        
        cell.tapEditBtn.addTarget(self, action: #selector(self.editBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.deleleBtn.addTarget(self, action: #selector(self.deleteBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        
        
        cell.paymentTypeLabel.text = "Card :  **** \(self.cardDetail[indexPath.row]["last4"]!)"
        cell.paymentTypeImageView.image = UIImage(named: "payment_method_card")
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 60
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            self.selectedIndex = indexPath
        
        
            self.setDefaultPaymentMethod(self.cardDetail[indexPath.row]["id"] as? String ?? "")
        
            self.card_token = self.cardDetail[indexPath.row]["id"] as? String ?? ""
            
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.8, animations: {
            cell.contentView.alpha = 1.0
        })
        
    }
    
    
    func deleteBtnTapped(_ sender: UIButton){
        
        if let indexPath = sender.tableViewIndexPath(self.paymentTableView) {
            
            self.removeCard(indexPath.row)
            self.editedIndex = nil
            self.paymentTableView.reloadData()
            
        }
        
    }
    
    func editBtnTapped(_ sender: UIButton){
        
        self.selectedIndex = nil
        if let indexPath = sender.tableViewIndexPath(self.paymentTableView) {
            sender.isSelected = !sender.isSelected
            
            if self.editedIndex == indexPath{
                
                self.editedIndex = nil

            }else{
                self.editedIndex = indexPath

            }
            self.paymentTableView.reloadData()
        }
        
    }
    
    
    
}



//MARK:- Tableview cell classess
//MARK:- =================================================
class PaymentTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var paymentTypeImageView: UIImageView!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var checkImage: UIImageView!
    
    @IBOutlet weak var deleleBtn: UIButton!
    @IBOutlet weak var tapEditBtn: UIButton!
    
    
    // MARK: Table View Cell Life Cycle Methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.deleleBtn.setTitle(S_DELETE.localized, for: .normal)
        
        self.bgView.layer.cornerRadius = 3
        
    }
    
    // MARK: Private Methods
    func populateCell(withPaymentType paymentName: String, paymentTypeImage imageName: String) {
        
        self.paymentTypeLabel.text = paymentName
        self.paymentTypeImageView.image = UIImage(named: imageName)
    }
}

class PromoCodeBtnCell: UITableViewCell {
    
    @IBOutlet weak var promoCodeBtn: UIButton!
    @IBOutlet weak var couponCodeTextField: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var appliedLbl: UILabel!
    @IBOutlet weak var applyCouponCodeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.appliedLbl.text = APPLIED.localized
        self.applyCouponCodeBtn.setTitle(APPLY.localized, for: .normal)
    }
}

