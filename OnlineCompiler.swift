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
    let specialEncoding = [";": "%3B", "+": "%2B", "\\": "%5C"]
    let otherEncoding = ["$": "%24", "?": "%3F", "<": "%3C", ">": "%3E", "@": "%40", ":": "%3A", "/": "%2F", ",": "%2C", "'": "%27", "&": "%26", "#": "%23", "!": "%21", "%": "%25", "_": "%5F", "^": "%5E", "[": "%5E", "]": "%5D"]
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
            source = source.stringByReplacingOccurrencesOfString(key, withString: val)
        }
        return source
    }
    
    func compileProgram(targetLanguage: String, sourceCode: String) {
        language = targetLanguage
        let source = encodeSourceCode(sourceCode)
        language = encodeSourceCode(language)
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let body = "lang=\(language)&code=\(source)&run=True&submit=Submit"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        print(body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data: NSData?,  response: NSURLResponse?, error: NSError?) -> Void in
            if data != nil {
                if let doc: HTMLDocument = Kanna.HTML(html: data!, encoding: NSUTF8StringEncoding){
                    let result = doc.xpath("/html/body/div/table/tr/td/div[2]/table/tr/td[2]/div")
                    if result.text != nil {
                        self.outPut = result.text
                        NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: result.text as? AnyObject)
                    } else {
                        self.outPut = "Network connection problem. Try again."
                        NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: "Sorry")
                    }
                    
                }
            } else {
                print("Data was nil")
            }
        })
        
        task.resume()
    }
    
}
