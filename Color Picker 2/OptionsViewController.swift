//
//  OptionsViewController.swift
//  Color Picker 2
//
//  Created by mitchell hudson on 12/29/14.
//  Copyright (c) 2014 mitchell hudson. All rights reserved.
//

import UIKit


protocol OptionsViewControllerDelegate {
    func optionsViewControllerDone(controller: OptionsViewController)
}


class OptionsViewController: UIViewController {
    
    let maxBrushSize: CGFloat = 120.0
    let minBrushSize: CGFloat = 1.0

    var delegate: OptionsViewControllerDelegate?
    
    var brushSize: CGFloat = 10.0 {
        didSet {
            brushSize = min(maxBrushSize, abs(brushSize))
        }
    }
    
    var brushAlpha: CGFloat = 1.0 {
        didSet {
            brushAlpha = min(1.0, abs(brushAlpha))
        }
    }
    
    var lastBrushSize: CGFloat = 0
    var lastBrushAlpha: CGFloat = 0
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var brushPreview: UIImageView!
    @IBOutlet weak var brushOutline: UIImageView!
    
    
    // MARK: - IBActions
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if delegate != nil {
            delegate?.optionsViewControllerDone(self)
        }
    }
    
    
    // MARK: - View Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let pan = UIPanGestureRecognizer(target: self, action: "onPan:")
        self.view.addGestureRecognizer(pan)
        drawBrushOutline()
        updateBrush()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Touch handlers
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        
        lastBrushAlpha = brushAlpha
        lastBrushSize = brushSize
    }
    
    
    // MARK: - UIGesture handlers 
    
    func onPan(panGesture: UIPanGestureRecognizer) {
        let point = panGesture.translationInView(self.view)
        
        brushSize = lastBrushSize - (point.y / 2)
        
        var newAlpha = max(0, min(point.x / 200, 1))
        // newAlpha = newAlpha + lastBrushAlpha
        // println("\(newAlpha) \(lastBrushAlpha)")
        
        brushAlpha = newAlpha
        
        updateBrush()
    }
    
    
    // MARK: - Draw brush preview
   
    func updateBrush() {
        let centerX = brushPreview.frame.size.width / 2
        let centerY = brushPreview.frame.size.height / 2
        
        UIGraphicsBeginImageContext(brushPreview.frame.size)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, brushAlpha)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), centerX, centerY)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), centerX, centerY)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        brushPreview.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func drawBrushOutline() {
        let centerX: CGFloat = brushOutline.frame.size.width / 2
        let centerY: CGFloat = brushOutline.frame.size.height / 2
        
        UIGraphicsBeginImageContext(brushOutline.frame.size)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.5, 0.5, 0.5, 1.0)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), centerX + (maxBrushSize / 2), centerY)
        CGContextAddArc(UIGraphicsGetCurrentContext(), centerX, centerY, CGFloat(maxBrushSize / 2), CGFloat(0.0), CGFloat(Float(M_PI) * 2.0), 1)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        brushOutline.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
  
    //
    
    func setBrush(newSize: CGFloat, newAlpha: CGFloat) {
        self.brushAlpha = newAlpha
        self.brushSize = newSize
        self.lastBrushAlpha = self.brushAlpha
        self.lastBrushSize = self.brushSize
        println("size \(self.brushSize) alpha \(self.brushAlpha)")
    }
}






