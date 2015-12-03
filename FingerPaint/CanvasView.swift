//
//  CanvasView.swift
//  FingerPaint
//
//  Created by yrom on 14-10-31.
//  Copyright (c) 2014年 yrom. All rights reserved.
//

import UIKit

public class CanvasView: UIView {

    private var paths = [Path]()
    
    public var currentColor: UIColor! = UIColor.blackColor() {
        didSet{
            if currentColor != oldValue {
                print("Set color \(currentColor) from \(oldValue)")
                setNeedsDisplay()
            }
        }
        
    }
    
    public var backgroundImage: UIImage? = nil {
        didSet {
            self.imageView.image = self.backgroundImage
        }
    }
    
    private var imageView: UIImageView = UIImageView()
    
    /// shoes if it was changed
    public var isDirty: Bool {
        get {
            return !self.paths.isEmpty
        }
    }
    
    /// shows if is comletely empty
    public var isEmpty: Bool {
        get {
            return self.paths.isEmpty && self.backgroundImage == nil
        }
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        backgroundImage?.drawAtPoint(CGPointZero)
        
        for path in paths {
            guard !path.points.isEmpty else {
                continue
            }
            
            drawPath(path, context: context)
        }
    }

    private func drawPath(path: Path, context: CGContextRef?) {
//        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, path.points.first!.x, path.points.first!.y)
        
        for index in 1..<path.points.count {
            let point: CGPoint = path.points[index]
            CGContextAddLineToPoint(context, point.x, point.y)
        }
        CGContextSetStrokeColorWithColor(context, path.color.CGColor)
        CGContextStrokePath(context)
    }
    
    func clearPaths(){
        paths.removeAll(keepCapacity: false)
        // redrawn
        setNeedsDisplay()
    }
    
    /// should be run only in main thread
    public func compact() -> UIImage? {
        guard !paths.isEmpty else {
            return backgroundImage
        }
        
        objc_sync_enter(paths)
        defer { objc_sync_exit(paths) }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, window!.screen.scale)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        let res = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backgroundImage = res
        clearPaths()
        
        return res
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        
        let point = t.locationInView(self)
        let newPath = Path(color: currentColor)
        newPath.add(point)
        paths.append(newPath)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        
        let point = t.locationInView(self)
        let path = paths.last
        path?.add(point)
        setNeedsDisplay()
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        
        let point = t.locationInView(self)
        let path = paths.last
        path?.add(point)
        setNeedsDisplay()
    }
}
