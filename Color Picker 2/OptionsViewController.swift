//
//  OptionsViewController.swift
//  Color Picker 2
//
//  Created by mitchell hudson on 12/29/14.
//  Copyright (c) 2014 mitchell hudson. All rights reserved.
//

import UIKit


protocol OptionsViewControllerDelegate {
    func optionsViewControllerDone(_ controller: OptionsViewController)
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
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.optionsViewControllerDone(self)
        }
    }
    
    
    // MARK: - View Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(OptionsViewController.onPan(_:)))
        self.view.addGestureRecognizer(pan)
        drawBrushOutline()
        updateBrush()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Touch handlers
    
    
    
    // MARK: - UIGesture handlers 
    
    func onPan(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        
        if panGesture.state == UIGestureRecognizerState.began {
            lastBrushAlpha = brushAlpha
            lastBrushSize = brushSize
        }
        
        if panGesture.state == UIGestureRecognizerState.changed {
            // print("tx: \(translation.x) ty:\(translation.y)")
            
            let newSize = lastBrushSize + translation.x
            let newAlpha = lastBrushAlpha + (translation.y / 200)
            
            if newSize < 1 {
                brushSize = 1
            } else if newSize > maxBrushSize {
                brushSize = maxBrushSize
            } else {
                brushSize = newSize
            }
            
            if newAlpha < 0.01 {
                brushAlpha = 0.01
            } else if newAlpha > 1.0 {
                brushAlpha = 1.0
            } else {
                brushAlpha = newAlpha
            }
            
            print("\(newAlpha) \(brushAlpha)")
            
            updateBrush()
        }
        
        
        
        
        
        // brushSize = lastBrushSize - (point.y / 2)
        
        // let newAlpha = max(0, min(point.x / 200, 1))
        // newAlpha = newAlpha + lastBrushAlpha
        // println("\(newAlpha) \(lastBrushAlpha)")
        
        // brushAlpha = newAlpha
        
        
    }
    
    
    // MARK: - Draw brush preview
   
    func updateBrush() {
        let centerX = brushPreview.frame.size.width / 2
        let centerY = brushPreview.frame.size.height / 2
        
        UIGraphicsBeginImageContext(brushPreview.frame.size)
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(brushSize)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: brushAlpha)
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: centerX, y: centerY))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: centerX, y: centerY))
        UIGraphicsGetCurrentContext()?.strokePath()
        brushPreview.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func drawBrushOutline() {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Unable to get graphics context for brush outline.")
            return
        }
        
        let centerX: CGFloat = brushOutline.frame.size.width / 2
        let centerY: CGFloat = brushOutline.frame.size.height / 2
        
        UIGraphicsBeginImageContext(brushOutline.frame.size)
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(1.0)
        context.setStrokeColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        context.move(to: CGPoint(x: centerX + (maxBrushSize / 2), y: centerY))
        
        
        
       //  CGContextAddArc(UIGraphicsGetCurrentContext(), centerX, centerY, CGFloat(maxBrushSize / 2), CGFloat(0.0), CGFloat(Float(M_PI) * 2.0), 1)
        
        UIGraphicsGetCurrentContext()?.strokePath()
        brushOutline.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
  
    //
    
    func setBrush(_ newSize: CGFloat, newAlpha: CGFloat) {
        self.brushAlpha = newAlpha
        self.brushSize = newSize
        self.lastBrushAlpha = self.brushAlpha
        self.lastBrushSize = self.brushSize
        print("size \(self.brushSize) alpha \(self.brushAlpha)")
    }
}






