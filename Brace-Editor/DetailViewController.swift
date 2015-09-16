
//
//  DetailViewController.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 2/2/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITextViewDelegate, CompileModalDelegate {
    
    var compiler = OnlineCompiler()
    var managedObjectContext: NSManagedObjectContext? = nil
    var compileModal:CompileModal?
    var index: NSIndexPath!
    var codeType: String!
    
    @IBOutlet weak var compileButton: UIBarButtonItem!
    
    var accessoryButtons = ["{", "}", "(", ")", "+", "-", "=", "*", ";", "tab"]
    
    let notificationKey = "com.Danwakeem.compile-output"
    
    var programSorceCode: CYRTextView!
    @IBOutlet weak var programView: UIView!
    
    var inputAccessory: UIView!
    
    var detailItem: [AnyObject]? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var compilerOutput: [String!]? {
        didSet {
            self.modifyModalView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        var asArray = self.detailItem! as Array
        index = asArray[1] as! NSIndexPath
        let detail: AnyObject = asArray[0] as AnyObject
        if let label = self.programSorceCode {
            if let code = detail.valueForKey("code")?.description {
                label.text = code
            }
        }
        codeType = detail.valueForKey("language")?.description
        title = detail.valueForKey("title")?.description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if detailItem != nil {
            setUpTextView()
            //self.navigationController?.hidesBarsWhenKeyboardAppears = true
            //self.navigationController?.hidesBarsOnSwipe = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "modifyModalView", name: self.notificationKey, object: nil)
            
            self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            self.navigationItem.leftItemsSupplementBackButton = true
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            self.managedObjectContext = appDelegate.managedObjectContext!
        } else {
            compileButton.enabled = false
            self.view.backgroundColor = UIColor.grayColor()
        }
    }
    
    func setUpTextView() {
        let arr: NSArray = getSyntax()
        programSorceCode = QEDTextView(programView.frame, language: arr as [AnyObject])
        view.addSubview(programSorceCode)
        configureView()
        programSorceCode.delegate = self
        self.createInputAccessoryView()
        programSorceCode.inputAccessoryView = inputAccessory
        programSorceCode.scrollEnabled = true
    }
    
    func getSyntax() -> NSArray {
        let textViewOptions = NSMutableArray()
        if let path = NSBundle.mainBundle().pathForResource("syntax", ofType: "plist") {
            let syntaxFile = NSDictionary(contentsOfFile: path)
            if let dictionary = syntaxFile {
                let regex = dictionary.valueForKey("RegEx") as! NSDictionary
                let colors = dictionary.valueForKey("Colors") as! NSDictionary
                let regForLanguage = regex.valueForKey(codeType) as! NSDictionary
                
                for (key, expression) in regForLanguage {
                    let keyColors = colors.valueForKey(key as! String) as! Array<CGFloat>
                    let r = keyColors[0] / 255
                    let g = keyColors[1] / 255
                    let b = keyColors[2] / 255
                    let boldFont = UIFont.boldSystemFontOfSize(14.0)
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                    let token = CYRToken(name: (key as! String), expression: (expression as! String) as String, attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: boldFont])
                    textViewOptions.addObject(token)
                }
            }
        }
        
        return NSArray(array: textViewOptions)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if detailItem != nil {
            programSorceCode.frame = programView.frame
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createInputAccessoryView(){
        inputAccessory = UIView(frame: CGRectMake(0, 0, 320, 50))
        inputAccessory.backgroundColor = UIColor.lightGrayColor()
        inputAccessory = rowOfButtons(accessoryButtons)
    }
    
    //Create the rows of buttons
    func rowOfButtons(buttonTitles: [NSString]) -> UIView {
        //Array of buttons that will go in the row
        var buttons = [UIButton]()
        //Setting up the size of the array of keys
        let keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        keyboardRowView.backgroundColor = UIColor(red:0.82, green:0.835, blue:0.859, alpha:1)
        //Create each button in the row
        for buttonTitle in buttonTitles{
            let button = createButtonWithTitle(buttonTitle as String)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        return keyboardRowView
    }
    
    //Creating a button with the title from the button* arrays
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton(type: .System)
        button.frame = CGRectMake(0, 0, 20, 20)
        button.clipsToBounds = true
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        for (index, button) in buttons.enumerate() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 5)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -3)
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -3)
            } else {
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -5)
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 3)
            } else {
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 5)
                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            }
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    //AccessoryView actions
    func buttonTapped(sender: AnyObject?) {
        let button = sender as! UIButton
        if let title = button.titleForState(.Normal) {
            switch title {
                case "tab":
                    self.programSorceCode.insertText("   ")
                default:
                    self.programSorceCode.insertText(title)
            }
        }
    }
    
    // MARK: - run compiler and modal view
    
    @IBAction func runCompiler(sender: AnyObject) {
        self.compiler.compileProgram(self.codeType, sourceCode: self.programSorceCode.text)
        self.modal()
    }
    
    func modifyModalView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.compileModal?.sucesfulCompile.text = "Compile Complete"
            self.compileModal?.outputTextView.text = self.compiler.outPut
        })
    }
    
    func closePop(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func modal() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        self.compileModal = (sb.instantiateViewControllerWithIdentifier("CompileModal") as! CompileModal)
        self.compileModal!.delegate = self
        
        self.compileModal!.modalTransitionStyle = .CoverVertical
        self.compileModal!.modalPresentationStyle = .FullScreen
        
        self.compileModal!.preferredContentSize = CGSize(width:self.view.frame.width * CGFloat(1 / 100.0), height:self.view.frame.height * CGFloat(1 / 100.0))
        
        self.presentViewController(compileModal!, animated: true, completion: {})
    }
    
    // MARK: - CoreData interactions
    
    //Save users program to core data
    func textViewDidEndEditing(textView: UITextView) {
        let object = self.fetchedResultsController.objectAtIndexPath(self.index)
            as! NSManagedObject
        object.setValue(self.programSorceCode.text, forKey: "code")
        do {
            try self.managedObjectContext?.save()
        } catch _ {
        }
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        _ = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
}

