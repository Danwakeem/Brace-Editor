//
//  OnlineCompiler.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 2/2/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import Foundation
import AlamoFire

class OnlineCompiler {
    var program: String!
    var language: String!
    
    let notificationKey = "com.Danwakeem.Brace-Editor"
    
    var outPut: String!
    var compileStatus: String!
    
    var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    var params = ["async": "0", "client_secret": "ceaf93f10f7330318aecc742f76bda4fae74b12e", "input": "<required>", "lang": "C", "memory_limit": "262144", "source": "int main(){   printf(\"Hello World.\\n\");return 0; }", "time_limit": "10"] as Dictionary
    
    var manager: AnyObject!
    
    init (){
        self.defaultHeaders["X-Mashape-Key"] = "yjU6TGrRSjmsh1v2Sipo9fS6SLvQp1iUuXXjsnWmLFshfXUaxy"
        self.defaultHeaders["Content-Type"] = "application/x-www-form-urlencoded"
        self.defaultHeaders["Accept"] = "application/json"
        
        configuration.HTTPAdditionalHeaders = self.defaultHeaders
        self.manager = Alamofire.Manager(configuration: configuration)
        self.program = ""
        self.language = "C"
    }
    
    func compileProgram(targetLanguage: String, sourceCode: String) {
        self.params["lang"] = targetLanguage
        self.params["source"] = sourceCode
        sendToCompile()
    }
    
    func sendToCompile(){
        var request = Alamofire.Manager(configuration: configuration).request(.POST, "https://ideas2it-hackerearth.p.mashape.com/run/", parameters: self.params)
        request.responseString({ (request, response, string, error) in
            //Have to convert the string to NSData then to a JSONObject to run through SwiftyJson
            var asData = (string! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(asData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            var json = JSON(jsonObject)
            
            if let op = json["run_status"]["output"].string {
                self.outPut = op
            }
            if let status = json["compile_status"].string {
                self.compileStatus = status
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: self)
            
        })
    }
    
}
