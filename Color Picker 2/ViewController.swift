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
        UIColor.red,
        UIColor.orange,
        UIColor.yellow,
        UIColor.green,
        UIColor.cyan,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.gray,
        UIColor.black,
        UIColor.white
    ]
    
    // variables
    var boxes = [UIView]()
    var brushSize: CGFloat = 2.0
    var brushAlpha: CGFloat = 1.0

    
    // MARK: - IBOutlets
    
    // UIView 
    @IBOutlet weak var canvasView: SmothView!
    
    
    // MARK: - IBActions
    
    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Share your image", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save to Camera roll", "Tweet it!", "Facebook")
        actionSheet.show(in: self.view)
    }
    
    // MARK: ActionSheet delegate methods
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, true, 0.0)
        self.canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        switch buttonIndex {
        case 0:                 // ???
            print("button 0")
            
        case 1:                 // Camera Roll
            print("button 1")
            
            UIImageWriteToSavedPhotosAlbum(image!,
                                           self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
            
            // UIImageWriteToSavedPhotosAlbum(image!, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            
        case 2:                 // Tweet
            print("Button 2")
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let tweetVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetVC?.setInitialText("#scribblegram")
                tweetVC?.add(image)
                self.present(tweetVC!, animated: true, completion: {() in
                    
                })
            } else {
                let alertView = UIAlertView(title: "Alert", message: "Twitter service unavailable. Login to Twitter in settings and try again.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
            
        case 3:
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fbVC?.setInitialText("Doodlegram")
                fbVC?.add(image)
                self.present(fbVC!, animated: true, completion: {() in
                
                })
            } else {
                let alertView = UIAlertView(title: "Alert", message: "Facebook service unavailable. Login to Facebook in settings and try again.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
        
        default:
            break
        }
        
    }
    
    
    func actionSheetCancel(_ actionSheet: UIActionSheet) {
        print("Actionsheet cancel")
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError, contextInfo: UnsafeRawPointer ) {
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

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    // MARK: - Setup Getsures
    
    func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.onPress(_:)))
        longPress.minimumPressDuration = 0.2
        longPress.cancelsTouchesInView = true
        longPress.delaysTouchesBegan = false
        longPress.delaysTouchesEnded = false
        // self.view.addGestureRecognizer(longPress)
    }
    
    func onPress(_ longPress: UILongPressGestureRecognizer) {
        let loc = longPress.location(in: self.view)
        switch longPress.state {
        case .began:
            selectColor(loc)
            
        case .changed:
            selectColor(loc)
            
        case .ended:
            // selectColor(nil)
            finishedSelectingColor(loc)
            
        case .cancelled:
            // selectColor(nil)
            finishedSelectingColor(loc)
            
        default:
            break
        }
    }
    
    
    
    
    // MARK: - Touch handlers 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // let touch = touches.anyObject() as! UITouch
            let loc = touch.location(in: self.view)
            selectColor(loc)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // let touch = touches.anyObject() as! UITouch
        if let touch = touches.first {
            let loc = touch.location(in: self.view)
            selectColor(loc)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // let touch = touches.anyObject() as! UITouch
        if let touch = touches.first {
            let loc = touch.location(in: self.view)
            finishedSelectingColor(loc)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    
    
    
    func touchInColorBoxes(_ point: CGPoint?) -> Bool {
        if let point = point {
            for box in boxes {
                if box.frame.contains(point) {
                    return true
                }
            }
        }
        return false
    }
    
    
    func selectColor(_ point: CGPoint?) {
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
                _ = CGRect(x: box.frame.origin.x, y: baseY - adjustedDistance, width: box.frame.width, height: height)
                
                let yscale = 1 + (distanceScale * 1.5)
                box.transform = CGAffineTransform(scaleX: 1, y: yscale)
            }
        }
    }
    
    
    func finishedSelectingColor(_ point: CGPoint?) {
        let duration = TimeInterval(0.3)
        let delay = TimeInterval(0.0)
        let options = UIViewAnimationOptions.curveEaseOut
        
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

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: options, animations: {
            for box in self.boxes {
                box.transform = CGAffineTransform(scaleX: 1, y: 1)
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
            let rect = CGRect(x: count * width, y: y, width: width, height: height)
            let box = UIView(frame: rect)
            // box.alpha = 0.5
            box.backgroundColor = color
            self.view.addSubview(box)
            boxes.append(box)
            count += 1
        }
    }
    
    
    // MARK: - Segue handlers 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: OptionsViewController.self) {
            let optionsVC = segue.destination as! OptionsViewController
            optionsVC.delegate = self
            optionsVC.setBrush(brushSize, newAlpha: brushAlpha)
        }
    }
    
    
    // MARK: - OptionsViewControllerDelegate methods
    
    func optionsViewControllerDone(_ controller: OptionsViewController) {
        self.brushSize = controller.brushSize
        self.brushAlpha = controller.brushAlpha
        self.dismiss(animated: true, completion: {})
        canvasView.setBrush(self.brushSize, alpha: self.brushAlpha)
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}













