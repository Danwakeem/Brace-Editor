//
//  OnlineCompiler.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 2/2/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import Foundation
import Kanna

class OnlineCompiler {
    var program: String!
    var language: String!
    let specialEncoding = ["simiCol": "%3B", "plus": "%2B", "backSlash": "%5C"]
    let notificationKey = "com.Danwakeem.compile-output"
    var outPut: String!
    var compileStatus: String!
    let url = NSURL(string: "http://codepad.org/")
    var manager: AnyObject!
    
    init (){
        self.program = ""
        self.language = "C"
    }
    
    func encodeSourceCode(sourceCode: String) -> String {
        var source = sourceCode
        for (key, val) in specialEncoding {
            switch(key) {
            case "simiCol":
                source = source.stringByReplacingOccurrencesOfString(";", withString: val)
            case "plus" :
                source = source.stringByReplacingOccurrencesOfString("+", withString: val)
            case "backSlash":
                source = source.stringByReplacingOccurrencesOfString("\\", withString: val)
            default:
                println("Did not find encoding")
            }
        }
        return source
    }
    
    func compileProgram(targetLanguage: String, sourceCode: String) {
        language = targetLanguage
        let source = encodeSourceCode(sourceCode)
        
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        var body = "lang=\(language)&code=\(source)&run=True&submit=Submit"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var url = response as! NSHTTPURLResponse
            println(url.URL!)
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            if let doc: HTMLDocument = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding){
                let result = doc.xpath("/html/body/div/table/tr/td/div[2]/table/tr/td[2]/div")
                if result.text != nil {
                    self.outPut = result.text
                    NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: result.text as? AnyObject)
                } else {
                    self.outPut = "Network connection problem. Try again."
                    NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: "Sorry")
                }
                
            }
        })
        
        task.resume()
    }
    
}
