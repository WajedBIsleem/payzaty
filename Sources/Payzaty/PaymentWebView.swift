//
//  PaymentWebView.swift
//  pay
//
//  Created by moumen isawe on 26/09/2021.
//

import UIKit
import WebKit

class PaymentWebView: UIViewController {
    
    
    
    var onCompletePayment:((String)->())?
      var webView:WKWebView!
    var url:String?
    var checkOutUrl:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView   = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        if let urlString  = url , let url = URL(string: urlString){
            
              webView.load(URLRequest(url: url))
              webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)

        }
        
        self.view.addSubview(self.webView  )
 
     }

 

}
extension PaymentWebView{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey]  {
            let currentURL = "\(key)"
             
            if currentURL.lowercased().contains(self.checkOutUrl.lowercased()){
            
                 self.onCompletePayment?(currentURL)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
 }
 
