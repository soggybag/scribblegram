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
    
    var color = UIColor.black    // starting color
    var path = UIBezierPath()           // Path to draw
    var incrementalImage = UIImage()    // Temp image holds the current drawing
    // An array of points to create a stroke
    var pts = [CGPoint(), CGPoint(), CGPoint(), CGPoint(), CGPoint()]
    var ctr: Int = 0    // Index of current point as drawing
    
    // Init this view
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isMultipleTouchEnabled = false           // Only one finger
        self.backgroundColor = UIColor.white // set the background color
        path.lineWidth = 2                          // Set the line width
        path.lineCapStyle = CGLineCap.round
    }

    
    //
    override func draw(_ rect: CGRect) {
        // Drawing code
        color.setStroke()                   // Set the stroke color fro incremental drawing
        incrementalImage.draw(in: rect)   // Draw an increment
        path.stroke()                       // Stroke the path
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            ctr = 0
            // let touch = touches.anyObject() as! UITouch
            pts[0] = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // let touch = touches.anyObject() as! UITouch
        if let touch = touches.first {
            let p = touch.location(in: self)
            ctr += 1
            pts[ctr] = p
            if ctr == 4 {
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                path.move(to: pts[0])
                path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
                
                self.setNeedsDisplay()
                
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.drawBitmap()
        self.setNeedsDisplay()
        path.removeAllPoints()
        ctr = 0

    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    
    func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        
        let rectPath = UIBezierPath(rect: self.bounds)
        UIColor.white.setFill()
        rectPath.fill()
        
        incrementalImage.draw(at: CGPoint.zero)
        color.setStroke()
        path.stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    func setNewColor(_ newColor: UIColor) {
        color = newColor.withAlphaComponent(brushAlpha)
    }
    
    func setBrush(_ width: CGFloat, alpha: CGFloat) {
        brushSize = width
        path.lineWidth = width
        brushAlpha = alpha
        color = color.withAlphaComponent(alpha)
    }
}






