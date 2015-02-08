//
//  CompileModal.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 2/3/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import UIKit

protocol CompileModalDelegate {
    func closePop(sender:AnyObject)
}

class CompileModal: UIViewController {
    var delegate:CompileModalDelegate?
    
    @IBOutlet var sucesfulCompile: UILabel!
    
    @IBOutlet var outputLabel: UILabel!
    
    @IBOutlet var outputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "closeButton:")
        swipeDown.direction = .Down
        swipeDown.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.delegate?.closePop(self)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
