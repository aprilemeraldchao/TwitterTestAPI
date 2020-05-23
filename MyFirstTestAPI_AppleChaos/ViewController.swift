//
//  ViewController.swift
//  MyFirstTestAPI_AppleChaos
//
//  Created by April Chao on 5/22/20.
//  Copyright © 2020 April Chao. All rights reserved.
//

import UIKit
import Foundation
import SwiftCrypto

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tweetPressed(_ sender: Any) {
        if textField.text == ""{
            return
        }
        postTweet(msg: textField.text!)
        textField.text = ""
    }
    
    func postTweet(msg: String){
        
        let allowedCharSet = CharacterSet.init(charactersIn: "0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm-._~")
        
        let processedMsg = msg.addingPercentEncoding(withAllowedCharacters: allowedCharSet) ?? "no msg"
        let processedMsg2 = processedMsg.addingPercentEncoding(withAllowedCharacters: allowedCharSet)!
        let semaphore = DispatchSemaphore (value: 0)
        
        let time = Int(NSDate().timeIntervalSince1970)
        let nonce = randomString(length: 32)
        let consumerKey = ""
        let authToken = ""
        let consumerSecret = ""
        let authTokenSecret = ""
        
        let httpMethod = "POST"
        let baseURL = "https://api.twitter.com/1.1/statuses/update.json"
        let processedBaseURL = baseURL.addingPercentEncoding(withAllowedCharacters: allowedCharSet)!
        let parameterString = "include_entities=true&oauth_consumer_key=\(consumerKey)&oauth_nonce=\(nonce)&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(time)&oauth_token=\(authToken)&oauth_version=1.0&status=\(processedMsg)"
        let processedParameterString = parameterString.addingPercentEncoding(withAllowedCharacters: allowedCharSet)!
        let baseString = "\(httpMethod)&\(processedBaseURL)&\(processedParameterString)"
        
        let signingKey = consumerSecret + "&" + authTokenSecret
        
        let output = baseString.digest(.sha1, key: signingKey)
        
        let binaryData = dataWithHexString(hex: output)
        let signature = binaryData.base64EncodedString()
        let processedSignature = signature.addingPercentEncoding(withAllowedCharacters: allowedCharSet)!
        
        var request = URLRequest(url: URL(string: "https://api.twitter.com/1.1/statuses/update.json?include_entities=true&status=\(processedMsg)")!,timeoutInterval: Double.infinity)
        request.addValue("OAuth oauth_consumer_key=\"\(consumerKey)\",oauth_token=\"\(authToken)\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"\(time)\",oauth_nonce=\"\(nonce)\",oauth_version=\"1.0\",oauth_signature=\"\(processedSignature)\"", forHTTPHeaderField: "Authorization")
        request.addValue("personalization_id=\"v1_juTapGVuQ/y2+eONZTFZYw==\"; guest_id=v1%3A159019926560519562; lang=en", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                self.statusLbl.text = "Status: tweet failed!"
                return
            }
            print(String(data: data, encoding: .utf8)!)
            self.statusLbl.text = "Status: tweet succeeded!"
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}

