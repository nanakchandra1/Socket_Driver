

import Foundation
import UIKit
import MFSideMenu


//MARK:- Common Keys

let deviceTokenn = "123456"
let TIMEOUT_INTERVAL = 30.0
let OS_PLATEFORM = "ios"
let LOCATION_UPDATED = "LOCATION_UPDATED"
let NOTIFICATION = "NOTIFICATIONS"
let SATRTANIMATE = "SATRTANIMATE"
let LOCATION_NOT_UPDATED = "LOCATION_NOT_UPDATED"

let baseUrl = "http://52.8.169.78:7029/"

let imgUrl = "http://52.76.76.250/"
var topViewController:UIViewController!
var mfSideMenuContainerViewController:MFSideMenuContainerViewController!
var appName = "Driver App"
var noNetwork = "Not connected to network"
var baseTabBarController: BaseTabBarController? {

    if let mfsisideVC = mfSideMenuContainerViewController {
        
        let navVC = mfsisideVC.centerViewController as! UINavigationController
        let rootVC = navVC.viewControllers.first
        
        if rootVC is BaseTabBarController {
            return rootVC as? BaseTabBarController
        }
    }
    return nil
}

let alertMessageTrip = "Are you sure, you want to cancel trip?"
let alertMessageRide = "Are you sure, you want to cancel ride?"


//MARK:- API Keys


struct API_Keys {

    static let googleApiKey = "AIzaSyCpvhVhEb0N4ihzWh8FA3FIVsdBEBGuESU"
    static let stripeApiKey = "pk_live_48UGAiSE7wjqd8K4zYyTmnms"

}


//MARK:- Storyboard Names
//MARK:-


struct StoryboardName {
    
    static let Main = "Main"
    static let Jobs = "Jobs"
    static let Wallet = "MyWallet"
    static let Setting = "Settings"
   
}

//MARK:- Static Keys
//MARK:-

struct NSUserDefaultKey{
    
    static let LOGIN = "isLoggedIn"
    static let CODE = "code"
    static let DeviceTokenn = "deviceTokenn"
    static let SystemVersion = "systemVersion"
    static let UserId = "userId"
    static let ride_State = "ridestate"
    static let ride_id = "rideId"
    static let FULL_NAME = "full_name"
    static let MOBILE = "mobile"
    static let EMAIL = "email"
    static let TOKEN = "token"
    static let COUNTRY_CODE = "country_code"
    static let USER_IMAGE = "user_image"
    static let ONLINE_FOR = "online_for"
    static let STOP_ACCEPTING = "stop_accepting"
    static let AMOUNT = "amount"
    static let VEHICLE = "vehicle"
    static let V_MODEL = "vmodel"
    static let PLATE_NO = "plate_no"
    static var STRIPE_ID = "strip_id"
    static let SKILLS = "skills"
    static let TYPE = "type"
    static let D_TYPE = "d_type"
    static let R_TYPE = "R_type"
    static let SEATING = "seating"
    static let UID = "uid"
    static let NOTIFICATION_STATUS = "notification_status"
    static let AVERAGE_RATING = "average_rating"
    static let PICKUP = "pickup"
    static let GENDER = "gender"
    static let DLN = "dl_no"
    static let TRIP_STATE = "trip_state"
    static let DRIVER_ARRIVING_STATE = "driver_arriving_state"
    static let ARRIVED = "arrived"
    static let CARD_TOKEN = "card_token"
    static let P_MODE = "p_mode"
    
}


//MARK:- Image Names
//MARK:-

struct ImageName{
    
    static let UNCHECK_IMAGE_STR = "UncheckRememberMe"
    static let CHECH_IMAGE_STR = "CheckRememberMe"
    
}

//MARK:- Static Fonts
//MARK:-

struct FontName{
    
    static let APP_COMMONFONT_BOLD = "aquawax-bold"
    static let APP_COMMONFONT_REGULAR = "aquawax-book"
    
}


//MARK:- Web Service URLs
//MARK:-


struct  URLName{
    
    static let LoginApiUrl = baseUrl+"driver/login"
    static let ForgotPasswordApiUrl = baseUrl+"driver/forgotpassword"
    static let VerifyOtpApiUrl = baseUrl+"driver/verifyotp"
    static let ChangePasswordUrl = baseUrl+"driver/changepassword"
    static let SendOTPUrl = baseUrl+"driver/resendotp"
    static let SetStatusUrl = baseUrl+"driver/setstatus"
    static let LogoutUrl = baseUrl+"driver/logout"
    static let UpdateLocationUrl = baseUrl+"api/updateloc"
    static let rideActionUrl = baseUrl+"api/rideaction"
    static let pickupActionUrl = baseUrl+"api/pickupaction"

    static let startRideUrl = baseUrl+"api/starttrip"
    static let startpickRideUrl = baseUrl+"api/startpickuptrip"
    static let endRideUrl = baseUrl+"api/endtrip"
    static let endPickUpRideUrl = baseUrl+"api/endpickuptrip"
    static let pickuprequestURL = baseUrl+"api/pickuprequest"
    static let arrivedURL = baseUrl+"api/arrived"

    static let driverStatusUrl = baseUrl+"api/currentstatus"
    static let driverRateUrl = baseUrl+"driver/rate"
    static let removeSaveCardDetailURL = baseUrl+"api/removeCard"
    static let setDefaultPaymentMethodURL = baseUrl+"driver/setdefaultpayment"

    static let earningsUrl = baseUrl+"api/earningsv1"
    static let dateearningUrl = baseUrl+"api/dateearning"
    static let saveCardDetailURL = baseUrl+"api/saveCards"

    static let myTransURL = baseUrl+"driver/mytransactions"
    static let rideHistoryURL = baseUrl+"api/ridehistory"
    static let paymentURL = baseUrl+"api/addMoneyDriverWallet"
    static let regainstateURL = baseUrl+"api/regainstate"
    static let staticPagesUrl = baseUrl+"driver/getpage"
    static let getFareUrl = baseUrl+"api/estimatedfare"
    static let stopAcceptingReqstUrl = baseUrl+"api/stopaccepting"
    static let changeLocgReqstUrl = baseUrl+"api/acceptchangeloc"
    static let notificationstatusURL = baseUrl+"driver/setNotificationStatus"
    static let notificationsURL = baseUrl+"api/notifications"
    static let addDriverCardURL = baseUrl+"driver/addCard"
    static let googlePlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let googleGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
    static let placeDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json"
    static let real_Time_navigate_URL = "https://itunes.apple.com/in/app/google-maps-real-time-navigation/id585027354?mt=8"

}


struct RegainRideActionString {
    
    static let driver = "driver"
    static let pickup_driver = "pickupdriver"
    static let pickup_user = "pickupuser"

}


struct DriverType {
    static let pickup_user = "p_user"
    static let pickup_driver = "p_driver"
}


struct Status {
    
    static let one = "1"
    static let two = "2"
    static let three = "3"
    static let four = "4"
    static let five = "5"
    static let six = "6"
    static let seven = "7"
    static let eight = "8"
    static let nine = "9"
    static let zero = "0"
}

struct PaymentMode {
    static let card = "Card"
    static let cash = "Cash"
}

struct VehicleType {
    static let car = "Car"
    static let bike = "Bike"
}

struct RequestType {
    static let pickup = "pickup"
    static let valet = "valet"
}


struct LocationTypeString {
    static let pickUp = "Pick Up"
    static let dropOff = "Drop Off"
}

struct NavigationTitle {
    
    static let arrivalNow = "ARRIVING NOW"
    static let onRide = "ON TRIP"
    static let onTheWay = "ON THE WAY"

    
}

struct RideStateString {
    
    static let onTrip = "OnTrip"
    static let tripDetail = "tripDetail"
    static let arrivalNow = "arrivalNow"
    static let rating = "rating"
    static let payment = "payment"
    static let pickup = "pickup"
    static let cancel = "CANCEL"
    static let changeDest = "CHANGE DESTINATION"
    static let onride = "onride"

}


struct AppConstantString {
    
    static let rideCancel = "Ride Cancelled"
}


struct RatingParameters{
    
    static let terrible = "Terrible"
    static let bad = "Bad"
    static let ok = "Ok"
    static let good = "Good"
    static let excellent = "Excellent"
    
    static let ratingAlert = "Please Rate the driver"
    
    // service parameter
    static let cleanliness = "Cleanliness"
    static let pickup = "Pickup"
    static let service = "Service"
    static let navigation = "Navigation"
    static let driving = "Driving"
    static let other = "Other"

}

struct RatingDescription{
    
    static let rate1 = "WHAT WENT WRONG?"
    static let rate2 = "WHAT WENT WRONG?"
    static let rate3 = "WHAT WENT WRONG?"
    static let rate4 = "WHAT COULD BE BETTER?"
    static let rate5 = "WHAT WENT WELL?"
}


struct WalletStrings {
    
    static let enterAmount = "Please Enter Amount"
    static let lessAmount = "Amount cannot be less than $1"
    static let enterCardNo = "Enter Card Number"
    static let validCardNo = "Please enter valid Card Number"

    static let enterName = "Please enter Name on your card"
    static let enterMonth = "Enter Expiry Month"
    static let enterYear = "Enter Expiry Year"
    static let enterCvv = "Enter CVV"
    static let validCvv = "Please enter valid CVV number"

}


struct ChangePasswordStrings {
    
    static let currentPass = "Please fill the current Password"
    static let newPass = "Please fill New password"
    static let confirmPass = "Confirm New Password"
//    static let confirmPass = "Confirm New Password"

    static let passMinLength = "password length should be more than 6 characters"
    static let passMaxLength = "password length should not be more than 32 characters"
    static let matchPass = "Current password and Confirm password cannot be same"
    static let notMatchPass = "Current password and New password cannot be same"

    static let newPassNotMatch = "New password and Confirm password are not same"

}


struct ForgotPasswordStrings {
    
    static let countryCodeRequired = "Country code is required"
    static let mobileRequired = "Mobile number is required"
    static let invalidMobile = "Invalid Mobile number"
    
}

struct LoginVCStrings {
    
    static let emailRequired = "Email Address is required"
    static let passRequired = "Password is required"
    static let invalidEmail = "Invalid Email address"
    static let passLength = "Password must be of atleast 6 characters"
    
    //myprofile string
    
    static let genderRequired = "Gender is required"
    static let d_l_no_Required = "Driving Licence Number is required"
    static let driving_skill_Required = "Driver Skills is required"

    // otp viewcontroller strings
    static let otpREquired = "PIN is required"
    static let invalidPin = "Invalid PIN"

}

struct ServiceStrings {
    
    static let failure = "Failure"

}

struct RideStrings {
    
    static let choosePic = "Choose your Pick Up"
    static let addLocLimit = "Cannot add more location"
    
    static let share_eta_Msg = "You'll reach to your destination in"
    static let arrivalnow_share_eta_Msg = "Your driver will reach in"


}




//MARK:- Array of Type
//MARK:-



//Categories Types
