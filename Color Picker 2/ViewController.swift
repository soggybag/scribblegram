//
//  ViewController.swift
//  Color Picker 2
//
//  Created by mitchell hudson on 12/28/14.
//  Copyright (c) 2014 mitchell hudson. All rights reserved.
//


// Update UIActionSheet and UIAlert with UIAlertController
// https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertController_class/


// TODO:
// Adjust UIView Canvas to height just above color picker

// Look for color picker bug
    // Happened after options screen
// Work on brush size and alpha setting the interaction is not great
// Post an update with the #scribblegram hash tag for twitter
// Add login for FaceBook/Parse 
    // Create a login controller
    // Add Parse backend for saving images. 
    // Need a Scribblegram browser to show scribbles 



import UIKit
import Social

class ViewController: UIViewController, OptionsViewControllerDelegate, UIActionSheetDelegate {
    
    // Default colors
    
    let colors = [
        UIColor.redColor(),
        UIColor.orangeColor(),
        UIColor.yellowColor(),
        UIColor.greenColor(),
        UIColor.cyanColor(),
        UIColor.blueColor(),
        UIColor.purpleColor(),
        UIColor.magentaColor(),
        UIColor.grayColor(),
        UIColor.blackColor(),
        UIColor.whiteColor()
    ]
    
    // variables
    var boxes = [UIView]()
    var brushSize: CGFloat = 2.0
    var brushAlpha: CGFloat = 1.0

    
    // MARK: - IBOutlets
    
    // UIView 
    @IBOutlet weak var canvasView: SmothView!
    
    
    // MARK: - IBActions
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Share your image", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save to Camera roll", "Tweet it!", "Facebook")
        actionSheet.showInView(self.view)
    }
    
    // MARK: ActionSheet delegate methods
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, true, 0.0)
        self.canvasView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        switch buttonIndex {
        case 0:                 // ???
            print("button 0")
            
        case 1:                 // Camera Roll
            print("button 1")
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            
            
        case 2:                 // Tweet
            print("Button 2")
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let tweetVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetVC.setInitialText("#scribblegram")
                tweetVC.addImage(image)
                self.presentViewController(tweetVC, animated: true, completion: {() in
                    
                })
            } else {
                let alertView = UIAlertView(title: "Alert", message: "Twitter service unavailable. Login to Twitter in settings and try again.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
            
        case 3:
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fbVC.setInitialText("Doodlegram")
                fbVC.addImage(image)
                self.presentViewController(fbVC, animated: true, completion: {() in
                
                })
            } else {
                let alertView = UIAlertView(title: "Alert", message: "Facebook service unavailable. Login to Facebook in settings and try again.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
        
        default:
            break
        }
        
    }
    
    
    func actionSheetCancel(actionSheet: UIActionSheet) {
        print("Actionsheet cancel")
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()> ) {
        if error != nil {
            print("Error saving image to camera roll \(error.debugDescription)")
        } else {
            let alertView = UIAlertView(title: "", message: "Image saved to camera roll", delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        makeBoxes()
        setupGestures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    // MARK: - Setup Getsures
    
    func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: "onPress:")
        longPress.minimumPressDuration = 0.2
        longPress.cancelsTouchesInView = true
        longPress.delaysTouchesBegan = false
        longPress.delaysTouchesEnded = false
        // self.view.addGestureRecognizer(longPress)
    }
    
    func onPress(longPress: UILongPressGestureRecognizer) {
        let loc = longPress.locationInView(self.view)
        switch longPress.state {
        case .Began:
            selectColor(loc)
            
        case .Changed:
            selectColor(loc)
            
        case .Ended:
            // selectColor(nil)
            finishedSelectingColor(loc)
            
        case .Cancelled:
            // selectColor(nil)
            finishedSelectingColor(loc)
            
        default:
            break
        }
    }
    
    
    
    
    // MARK: - Touch handlers 
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            // let touch = touches.anyObject() as! UITouch
            let loc = touch.locationInView(self.view)
            selectColor(loc)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // let touch = touches.anyObject() as! UITouch
        if let touch = touches.first {
            let loc = touch.locationInView(self.view)
            selectColor(loc)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // let touch = touches.anyObject() as! UITouch
        if let touch = touches.first {
            let loc = touch.locationInView(self.view)
            finishedSelectingColor(loc)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }

    
    
    
    func touchInColorBoxes(point: CGPoint?) -> Bool {
        if let point = point {
            for box in boxes {
                if box.frame.contains(point) {
                    return true
                }
            }
        }
        return false
    }
    
    
    func selectColor(point: CGPoint?) {
        let colorBoxIsTouched = touchInColorBoxes(point)
        var distances = [CGFloat]()
        
        let baseY = self.view.frame.height - 100
        let xRange: CGFloat = 100
        
        for box in boxes {
            if colorBoxIsTouched {
                let distance = abs(point!.x - box.center.x)
                distances.append(distance)
                
                //
                let adjustedDistance = xRange - min(xRange, distance)
                let distanceScale = adjustedDistance / xRange
                let height = 100 + (distanceScale * 50)
                let newRect = CGRectMake(box.frame.origin.x, baseY - adjustedDistance, box.frame.width, height)
                
                let yscale = 1 + (distanceScale * 1.5)
                box.transform = CGAffineTransformMakeScale(1, yscale)
            }
        }
    }
    
    
    func finishedSelectingColor(point: CGPoint?) {
        let duration = NSTimeInterval(0.3)
        let delay = NSTimeInterval(0.0)
        let options = UIViewAnimationOptions.CurveEaseOut
        
        print("finish Selecting color: \(boxes.count) \(colors.count)")
        
        // get selected color 
        if let point = point {
            print("\(point)")
            for i in 0..<boxes.count {
                if boxes[i].frame.contains(point) {
                    print("\(i)")
                    if i >= 0 && i < colors.count {
                        canvasView.setNewColor(colors[i])
                    }
                }
            }
        }

        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: options, animations: {
            for box in self.boxes {
                box.transform = CGAffineTransformMakeScale(1, 1)
            }
        }, completion: nil)
    }
    
    
    
    // Color Picker boxes
    
    func makeBoxes() {
        var count:CGFloat = 0
        let height: CGFloat = 150
        let distanceFromBottom: CGFloat = 60
        let width:CGFloat = self.view.frame.width / CGFloat(colors.count)
        let y: CGFloat = self.view.frame.height - distanceFromBottom
        
        print("Make boxes:")
        
        for color in colors {
            print("adding a colored box \(color)")
            let rect = CGRectMake(count * width, y, width, height)
            let box = UIView(frame: rect)
            // box.alpha = 0.5
            box.backgroundColor = color
            self.view.addSubview(box)
            boxes.append(box)
            count++
        }
    }
    
    
    // MARK: - Segue handlers 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(OptionsViewController) {
            let optionsVC = segue.destinationViewController as! OptionsViewController
            optionsVC.delegate = self
            optionsVC.setBrush(brushSize, newAlpha: brushAlpha)
        }
    }
    
    
    // MARK: - OptionsViewControllerDelegate methods
    
    func optionsViewControllerDone(controller: OptionsViewController) {
        self.brushSize = controller.brushSize
        self.brushAlpha = controller.brushAlpha
        self.dismissViewControllerAnimated(true, completion: {})
        canvasView.setBrush(self.brushSize, alpha: self.brushAlpha)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}













