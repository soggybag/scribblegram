//
//  SmothView.swift
//  Smooth Drawing Swift
//
//  Created by mitchell hudson on 12/23/14.
//  Copyright (c) 2014 mitchell hudson. All rights reserved.
//

import UIKit

class SmothView: UIView {
    
    var brushSize: CGFloat = 2.0
    var brushAlpha: CGFloat = 1.0
    
    var color = UIColor.blackColor()    // starting color
    var path = UIBezierPath()           // Path to draw
    var incrementalImage = UIImage()    // Temp image holds the current drawing
    // An array of points to create a stroke
    var pts = [CGPoint(), CGPoint(), CGPoint(), CGPoint(), CGPoint()]
    var ctr: Int = 0    // Index of current point as drawing
    
    // Init this view
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.multipleTouchEnabled = false           // Only one finger
        self.backgroundColor = UIColor.whiteColor() // set the background color
        path.lineWidth = 2                          // Set the line width
        path.lineCapStyle = kCGLineCapRound
    }

    
    //
    override func drawRect(rect: CGRect) {
        // Drawing code
        color.setStroke()                   // Set the stroke color fro incremental drawing
        incrementalImage.drawInRect(rect)   // Draw an increment
        path.stroke()                       // Stroke the path
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        ctr = 0
        let touch = touches.anyObject() as UITouch
        pts[0] = touch.locationInView(self)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let p = touch.locationInView(self)
        ctr++
        pts[ctr] = p
        if ctr == 4 {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0)
            path.moveToPoint(pts[0])
            path.addCurveToPoint(pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
            
            self.setNeedsDisplay()
            
            pts[0] = pts[3]
            pts[1] = pts[4]
            ctr = 1
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.drawBitmap()
        self.setNeedsDisplay()
        path.removeAllPoints()
        ctr = 0
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.touchesEnded(touches, withEvent: event)
    }
    
    
    func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        
        let rectPath = UIBezierPath(rect: self.bounds)
        UIColor.whiteColor().setFill()
        rectPath.fill()
        
        incrementalImage.drawAtPoint(CGPoint.zeroPoint)
        color.setStroke()
        path.stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func setColor(newColor: UIColor) {
        color = newColor.colorWithAlphaComponent(brushAlpha)
    }
    
    func setBrush(width: CGFloat, alpha: CGFloat) {
        brushSize = width
        path.lineWidth = width
        brushAlpha = alpha
        color = color.colorWithAlphaComponent(alpha)
    }
}






