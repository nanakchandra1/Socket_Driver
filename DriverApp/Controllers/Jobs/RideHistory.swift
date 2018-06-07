//
//  PreBookingVC.swift
//  UserApp
//
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class RideHistory: UIViewController {
    
    //MARK:- IBOutelets
    //MARK:- =================================================

    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var rideHistoryTableView: UITableView!
    
   
    
    //MARK:- Properties
    //MARK:- =================================================

    
    var ridrHistory = JSONDictionaryArray()
    

    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationTitle.text = RIDE_HISTORY.localized
        
        
        self.rideHistoryTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.rideHistoryTableView.delegate = self
        self.rideHistoryTableView.dataSource = self
        self.rideHistoryTableView.register(UINib(nibName: "RideHistoryDetailCell" ,bundle: nil), forCellReuseIdentifier: "RideHistoryDetailCell")
        self.navigationView.setMenuButton()
        self.getRideHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getRideHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 
    
    //MARK:- Methods
    //MARK:- =================================================

    func getRideHistory(){
        
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        showLoader()
        
        getHistoryApi(params) { (historyResult: JSONDictionary) in
            
            printlnDebug(historyResult)
            hideLoader()
            if let history = historyResult["history"] as? JSONDictionaryArray{
                self.ridrHistory = history
                self.rideHistoryTableView.reloadData()
            }
        }
        
        
    }

    
    
}


//MARK:- Tableview dalegate and datasource
//MARK:- =================================================

extension RideHistory: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.ridrHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryCell", for: indexPath) as! RideHistoryCell
        
        delay(0.1) {
            cell.setUpView()
        }
        
        if let name = self.ridrHistory[indexPath.row]["user_name"] as? String{
            cell.userName.text = name
        }
        if let status = self.ridrHistory[indexPath.row]["status"]{
            
            if "\(status)" == Status.five{
                cell.rideStatus.text = "On Ride".uppercased()

            }else if "\(status)" == Status.one{
                cell.rideStatus.text = "Arriving Noe".uppercased()

            }else if "\(status)" == Status.seven{
                cell.rideStatus.text = "Cancelled".uppercased()

            }else if "\(status)" == Status.six{
                cell.rideStatus.text = "Completed".uppercased()
            }
        }

        
        if let image = self.ridrHistory[indexPath.row]["user_image"] as? String{
            
            let imageUrlStr = imgUrl+image
            if let imageUrl = URL(string: imageUrlStr){
                cell.userImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
        
        if let pic = self.ridrHistory[indexPath.row]["pickup"]!["address"] as? String{
            
            cell.fromAddressLabel.text = pic
        }
        
        if let rate = self.ridrHistory[indexPath.row]["p_amount"]{
            
            cell.rateLbl.text = "$\(rate)"
        }
        
        if let date = self.ridrHistory[indexPath.row]["start_time"]{
            
            cell.datelbl.text = "\(covert_UTC_to_Local_WithTime(date as! String))"
        }
        
        
        if let drop = self.ridrHistory[indexPath.row]["drop"] as? JSONDictionaryArray{


            if drop.count == 1{
                
                cell.toAddressLabel1.text = drop[0]["address"] as? String
                
                cell.hideShow(false, second: true, third: true, fourth: true)

                
            }else if drop.count == 2{
                cell.toAddressLabel1.text = drop[0]["address"] as? String
                cell.toAddressLabel2.text = drop[1]["address"] as? String
                
                cell.hideShow(false, second: false, third: true, fourth: true)

                
            }else if drop.count == 3{
                cell.toAddressLabel1.text = drop[0]["address"] as? String
                cell.toAddressLabel2.text = drop[1]["address"] as? String
                cell.toAddressLabel3.text = drop[2]["address"] as? String
                
                cell.hideShow(false, second: false, third: false, fourth: true)

                
            }else{
                cell.toAddressLabel1.text = drop[0]["address"] as? String
                cell.toAddressLabel2.text = drop[1]["address"] as? String
                cell.toAddressLabel3.text = drop[2]["address"] as? String
                cell.toAddressLabel4.text = drop[3]["address"] as? String
                
                cell.hideShow(false, second: false, third: false, fourth: false)
                cell.toAddressLabel1.isHidden = false
                cell.toAddressLabel2.isHidden = false
                cell.toAddressLabel3.isHidden = false
                cell.toAddressLabel4.isHidden = false

                
                cell.toCircleView1.isHidden = false
                cell.toCircleView2.isHidden = false
                cell.toCircleView3.isHidden = false
                cell.toCircleView4.isHidden = false

            }
        }

        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if let drop = self.ridrHistory[indexPath.row]["drop"] as? JSONDictionaryArray{
            if drop.count == 1{
                
                let pic = "\(self.ridrHistory[indexPath.row]["pickup"]!["address"])".boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let title = "\(drop[0]["address"])".boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let heiht = title.height + pic.height + 180
                
                return heiht

            }else if drop.count == 2{
                let pic = "\(self.ridrHistory[indexPath.row]["pickup"]!["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let title = "\(drop[0]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title2 = "\(drop[1]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let heiht = title.height + title2.height + pic.height + 180

                return heiht

            
            }else if drop.count == 3{
                
                let pic = "\(self.ridrHistory[indexPath.row]["pickup"]!["address"])".boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let title = "\(drop[0]["address"])".boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title2 = "\(drop[1]["address"])".boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title3 = "\(drop[2]["address"])".boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let heiht = title.height + title2.height + title3.height + pic.height + 180

                return heiht

            }else{
                
                let pic = "\(self.ridrHistory[indexPath.row]["pickup"]!["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)

                let title = "\(drop[0]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title2 = "\(drop[1]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title3 = "\(drop[2]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                let title4 = "\(drop[3]["address"])".boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
                
                let heiht = title.height + title2.height + title3.height + title4.height + pic.height + 180
                return heiht
            }
        }
        return 0
    }
    
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
//    }
    
}



//MARK:- UITableview cell classess



class RideHistoryCell: UITableViewCell {
    
    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var fromCircleView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var toCircleView1: UIView!
    @IBOutlet weak var toAddressLabel1: UILabel!
    
    @IBOutlet weak var toCircleView2: UIView!
    @IBOutlet weak var toAddressLabel2: UILabel!
    
    @IBOutlet weak var toCircleView3: UIView!
    @IBOutlet weak var toAddressLabel3: UILabel!
    
    @IBOutlet weak var toCircleView4: UIView!
    @IBOutlet weak var toAddressLabel4: UILabel!
    @IBOutlet weak var rideStatus: UILabel!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.fromLabel.text = FROM.localized
        self.toLabel.text = TO.localized
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: =========
    // MARK: Private Methods
    
    func setUpView(){
        
        self.fromCircleView.layer.cornerRadius = 4
        self.toCircleView1.layer.cornerRadius = 4
        self.toCircleView2.layer.cornerRadius = 4
        self.toCircleView3.layer.cornerRadius = 4
        self.toCircleView4.layer.cornerRadius = 4
        
        self.toCircleView1.layer.masksToBounds = true
        self.toCircleView2.layer.masksToBounds = true
        self.toCircleView3.layer.masksToBounds = true
        self.toCircleView4.layer.masksToBounds = true


        self.userImg.layer.cornerRadius = self.userImg.bounds.height / 2
        self.userImg.layer.borderWidth = 3
        self.userImg.layer.borderColor = RED_BUTTON_COLOR.cgColor
        self.userImg.layer.masksToBounds = true
        
    }
    
    
    
    func hideShow(_ first: Bool, second: Bool, third: Bool, fourth: Bool){
        
        self.toAddressLabel1.isHidden = first
        self.toAddressLabel2.isHidden = second
        self.toAddressLabel3.isHidden = third
        self.toAddressLabel4.isHidden = fourth
        
        self.toCircleView1.isHidden = first
        self.toCircleView2.isHidden = second
        self.toCircleView3.isHidden = third
        self.toCircleView4.isHidden = fourth

    }
    
    
    func populate(at index: Int, with fromAddress: String, with toAddress: String) {
        
        self.fromCircleView.layer.cornerRadius = self.fromCircleView.bounds.height / 2
        self.fromAddressLabel.text = fromAddress
        
        
    }
    
    
}




