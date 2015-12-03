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
    
    var currentColor: UIColor! = UIColor.blackColor() {
        didSet{
            if currentColor != oldValue {
                print("Set color \(currentColor) from \(oldValue)")
                setNeedsDisplay()
            }
        }
        
    }
    
    var backgroundImage: UIImage? = nil {
        didSet {
            self.imageView.image = self.backgroundImage
        }
    }
    
    private var imageView: UIImageView = UIImageView()
    
    /// shoes if it was changed
    var isDirty: Bool {
        get {
            return !self.paths.isEmpty
        }
    }
    
    /// shows if is comletely empty
    var isEmpty: Bool {
        get {
            return self.paths.isEmpty && self.backgroundImage == nil
        }
    }
    
// MARK: - init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    private func setUp() {
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        imageView.frame = bounds
        imageView.contentMode = .Center
        addSubview(imageView)
        
        imageView.image = backgroundImage
    }
    
    override public func drawRect(rect: CGRect) {
        for path in paths {
            if path.points.isEmpty {
                continue
            }
            
            drawPath(path)
        }
    }

    /// should be run only in main thread
    func compact() -> UIImage? {
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

    private func drawPath(path: Path) {
        let context = UIGraphicsGetCurrentContext()
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
