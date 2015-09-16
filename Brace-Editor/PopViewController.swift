//
//  PopViewController.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 9/10/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import UIKit

protocol PopViewControllerDelegate {
    func closePop(_: AnyObject)
    func insertNewObject(_: [String?])
}

class PopViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var language: UIPickerView!
    @IBOutlet weak var programTitle: UITextField!
    
    var delegate: PopViewControllerDelegate?
    
    let supportedLang = ["C", "C++", "PHP", "Ruby", "Python"]
    var selectedLanguage = "C"

    override func viewDidLoad() {
        super.viewDidLoad()
        language.delegate = self
        language.dataSource = self
        programTitle.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(sender: AnyObject) {
        insertNewObject("add")
        closePop("close")
    }

    @IBAction func closePop(sender: AnyObject) {
        delegate?.closePop(sender)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportedLang.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportedLang[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = supportedLang[row]
    }
    
    func insertNewObject(sender: AnyObject) {
        let arr = [programTitle.text,selectedLanguage]
        delegate?.insertNewObject(arr)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        programTitle.resignFirstResponder()
        return false
    }

}
