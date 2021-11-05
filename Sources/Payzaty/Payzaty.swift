import Foundation
 
import UIKit
import WebKit

open class Payzaty{
    
    
    private  var merchantNo:String = ""
    private  var sandbox:Bool = false
    private  var secretKey:String = ""
    private var language:String = "En"
    
    private let url = "https://www.payzaty.com"
    private let sandboxUrl = "https://sandbox.payzaty.com"
    private var currentVC:UIViewController!
   
    
  public  init
     (currentVC:UIViewController,merchantNo:String,secretKey:String,language:String,sandbox:Bool){
        self.currentVC = currentVC
        self.merchantNo = merchantNo
        self.sandbox = sandbox
        self.secretKey = secretKey
        self.language = language
        
    }
    func getUrl()->String{
        return self.sandbox ? self.sandboxUrl : self.url
    }
        
    private func createHeader()->[String:String]{
        var headers:[String:String] = [:]
        headers["X-Source"] = "3"
        headers["X-Build"] = "1"
        headers["X-Version"] = "1"
        headers["X-Language"] = "\(self.language)"
        headers["X-MerchantNo"] = self.merchantNo
        headers["X-SecretKey"] = self.secretKey
        
      
        return headers
        
    }
    
    private func shwoPaymentView(url:String,redirectUrl:String ,onSuccess:@escaping((CheckoutResponse)->Void),onFailure:@escaping((PayzatyError)->Void)) {
        DispatchQueue.main.async {
            
        
    
            
             // topController should now be your topmost view controller
            let vc = PaymentWebView()
            vc.checkOutUrl = redirectUrl
            vc.url = url
            vc.onCompletePayment = { fullUrl in
              print("Payment done with \(fullUrl)")
                guard    let id = URL(string: fullUrl)?.valueOf("checkoutId") else {
                    
                
                    return
                }
                self.checkStatus(id: id,onSuccess: onSuccess,onFailure: onFailure)
                
            }
            self.currentVC.present(vc, animated: true, completion: nil)
      
        }
    }
    
  public  func checkout(name:String
                  ,email:String
                  ,phoneCode:String
                  ,PhoneNumber:String
                  ,amount:Double
                  ,currencyID:Int
                  ,responseUrl:String
                  ,UDF1:String? = nil
                  ,UDF2:String? = nil
                  ,UDF3:String? = nil
                  ,onSuccess:@escaping ((CheckoutResponse)->Void),onFailure:@escaping ((PayzatyError)->Void)){
        if merchantNo.isEmpty{
            onFailure(.noMerchantNo)
            
            return
        }
        if secretKey.isEmpty{
            onFailure(.noSecretKey)
            
            return
        }
        
        
        var urlBuilder = URLComponents(string: "\(getUrl())/payment/checkout")
          urlBuilder?.queryItems = [
              URLQueryItem(name: "Name", value: name),
              URLQueryItem(name: "Email", value: email)
              ,URLQueryItem(name: "PhoneCode", value: phoneCode)
              ,URLQueryItem(name: "PhoneNumber", value: PhoneNumber),
              URLQueryItem(name: "Amount", value: "\(amount)")
              
              
              ,URLQueryItem(name: "CurrencyID", value: "\(currencyID)")
              ,URLQueryItem(name: "ResponseUrl", value: responseUrl)
              ,              URLQueryItem(name: "UDF1", value: UDF1)
              ,URLQueryItem(name: "UDF2", value: UDF2)
              ,URLQueryItem(name: "UDF3", value: UDF3)
              

              
          ]

        guard let url = urlBuilder?.url else { return }

          var request = URLRequest(url: url)
          request.httpMethod = "POST"
        request.httpBody  = urlBuilder?.query?.data(using: .utf8)
 
        createHeader().forEach { (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        


        


          URLSession.shared.dataTask(with: request) { (data, response, error) in
              guard let data = data else {
                   return
              }
               if let result = PaymentResponse(data:data){
                   if  !result.success{
                       let result  = CheckoutResponse(success: result.success, paid: false, status: "", udf1: "", udf2: "", udf3: "", error: result.error, errorText: result.errorText)
                       onSuccess(result)
                        return
                   }else{
                self.shwoPaymentView(url:result.checkoutUrl ?? "",redirectUrl: responseUrl ,onSuccess: onSuccess,onFailure: onFailure)
                       
                   }
                   

               }else{
                    print(String(data: data, encoding: .utf8)!)
               }
           }.resume()
        
    }
    
    public enum PayzatyError:Error{
        case noMerchantNo
        case noSecretKey
        
    }
    
    private func checkStatus(id:String,onSuccess:@escaping((CheckoutResponse)->Void),onFailure:@escaping((PayzatyError)->Void)){
 
        var request = URLRequest(url: URL(string: "\(getUrl())/payment/status/\(id)")!,timeoutInterval: Double.infinity)
        createHeader().forEach { (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              
               
             return
          }
            if let checkout = CheckoutResponse(data: data){
                print(checkout.paid)
                
                
                let result  = CheckoutResponse(success: checkout.success, paid: checkout.paid, status:checkout.status, udf1: checkout.udf1, udf2: checkout.udf2, udf3: checkout.udf3, error: "", errorText:"")
                onSuccess(result)
             }
           
         }

        task.resume()
    }
    
  
   
    
    
    
}
extension Payzaty.PayzatyError: CustomStringConvertible {
   public var description: String {
       switch self {
       case .noSecretKey:
           return "Secret Key can't be empty"
       case .noMerchantNo:
           return "Merchant No. can't be empty"
       }
   }
}
 
 
struct PaymentResponse: Codable, CodableInitializable {
    let success: Bool
    let checkoutId: String?
    let checkoutUrl: String?
    let error : String?
    let errorText:String?
     
}
 
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
public struct CheckoutResponse: Codable,CodableInitializable {
    let success, paid: Bool
    let status, udf1, udf2, udf3: String
    let error,errorText:String?
     
}
 
