//
//  XHBubbleView.swift
//  XHBubbleDragDemo
//
//  Created by Henry Huang on 2/19/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

import UIKit

struct BubbleOptions {
    var text: String = ""
    var bubbleWidth: CGFloat = 0.0
    var viscosity: CGFloat = 0.0
    var bubbleColor: UIColor = UIColor.whiteColor()
}

class XHBubbleView: UIView {

    var frontView: UIView?
    var bubbleOptions: BubbleOptions {
        didSet {
            bubbleLabel.text = bubbleOptions.text
        }
    }
    var soundEnable: Bool!
    var disappearEnable: Bool!
    private var bubbleLabel: UILabel!
    private var containerView: UIView!
    private var dragPath: UIBezierPath!
    private var fillColorForDrag: UIColor!
    private var animator: UIDynamicAnimator!
    private var backView: UIView!
    private var shapeLayer: CAShapeLayer!
    
    private var r1: CGFloat = 0.0
    private var r2: CGFloat = 0.0
    private var x1: CGFloat = 0.0
    private var y1: CGFloat = 0.0
    private var x2: CGFloat = 0.0
    private var y2: CGFloat = 0.0
    private var centerDistance: CGFloat = 0.0
    private var cosDigree: CGFloat = 0.0
    private var sinDigree: CGFloat = 0.0
    
    private var pointA = CGPointZero
    private var pointB = CGPointZero
    private var pointC = CGPointZero
    private var pointD = CGPointZero
    private var pointO = CGPointZero
    private var pointP = CGPointZero
    
    private var initialPoint: CGPoint = CGPointZero
    private var oldBackViewFrame: CGRect = CGRectZero
    private var oldBackViewCenter: CGPoint = CGPointZero

    init(point: CGPoint, superView: UIView, options: BubbleOptions, enableSound: Bool, enableDisappear: Bool) {
        bubbleOptions = options
        initialPoint = point
        containerView = superView
        soundEnable = enableSound
        disappearEnable = enableDisappear
        super.init(frame: CGRectMake(point.x, point.y, options.bubbleWidth, options.bubbleWidth))
        containerView.addSubview(self)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        shapeLayer = CAShapeLayer()
        backgroundColor = UIColor.clearColor()
        frontView = UIView(frame: CGRectMake(initialPoint.x, initialPoint.y, bubbleOptions.bubbleWidth, bubbleOptions.bubbleWidth))
        guard let frontView = frontView else {
            print("FrontView is NIL")
            return
        }
        r2 = frontView.bounds.size.width / 2.0
        frontView.layer.cornerRadius = r2
        frontView.backgroundColor = bubbleOptions.bubbleColor
        
        backView = UIView(frame: frontView.frame)
        r1 = backView.bounds.size.width / 2.0
        backView.layer.cornerRadius = r1
        backView.backgroundColor = bubbleOptions.bubbleColor
        
        bubbleLabel = UILabel()
        bubbleLabel.frame = CGRectMake(0, 0, frontView.bounds.width, frontView.bounds.height)
        bubbleLabel.textColor = UIColor.whiteColor()
        bubbleLabel.textAlignment = .Center
        bubbleLabel.text = bubbleOptions.text
        
        frontView.insertSubview(bubbleLabel, atIndex: 0)
        containerView.addSubview(backView)
        containerView.addSubview(frontView)
        
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = frontView.center.x
        y2 = frontView.center.y
        
        pointA = CGPointMake(x1-r1,y1)
        pointB = CGPointMake(x1+r1, y1)
        pointD = CGPointMake(x2-r2, y2)
        pointC = CGPointMake(x2+r2, y2)
        pointO = CGPointMake(x1-r1,y1)
        pointP = CGPointMake(x2+r2, y2)
        
        oldBackViewFrame = backView.frame
        oldBackViewCenter = backView.center
    
        // add bubble animation
        backView.hidden = true // for call the bubble animation 
        addBuubleAnimation()
        
        // add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: "handleDragGesture:")
        frontView.addGestureRecognizer(panGesture)
        
    }
    
    private func drawRect() {
        guard let frontView = frontView else {
            return
        }
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = frontView.center.x
        y2 = frontView.center.y
        
        centerDistance = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        if centerDistance == 0 {
            cosDigree = 1
            sinDigree = 0
        } else {
            cosDigree = (y2 - y1) / centerDistance
            sinDigree = (x2 - x1) / centerDistance
        }
        
        r1 = oldBackViewFrame.size.width / 2 - centerDistance / bubbleOptions.viscosity
        
        pointA = CGPointMake(x1-r1*cosDigree, y1+r1*sinDigree)
        pointB = CGPointMake(x1+r1*cosDigree, y1-r1*sinDigree)
        pointD = CGPointMake(x2-r2*cosDigree, y2+r2*sinDigree)
        pointC = CGPointMake(x2+r2*cosDigree, y2-r2*sinDigree)
        pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree)
        pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree)
        
        backView.center = oldBackViewCenter
        backView.bounds = CGRectMake(0, 0, r1 * 2, r1 * 2)
        backView.layer.cornerRadius = r1;
        
        dragPath = UIBezierPath()
        dragPath.moveToPoint(pointA)
        dragPath.addQuadCurveToPoint(pointD, controlPoint: pointO)
        dragPath.addLineToPoint(pointC)
        dragPath.addQuadCurveToPoint(pointB, controlPoint: pointP)
        dragPath.closePath()
        
        if backView.hidden == false {
            shapeLayer.path = dragPath.CGPath
            shapeLayer.fillColor = fillColorForDrag.CGColor
            containerView.layer.insertSublayer(shapeLayer, below: frontView.layer)
        }
    }
        
    @objc private func handleDragGesture(gesture: UIPanGestureRecognizer) {
        let dragPoint = gesture.locationInView(containerView)
        if gesture.state == .Began {
            backView.hidden = false
            fillColorForDrag = bubbleOptions.bubbleColor
            removeBubbleAnimation()
        } else if gesture.state == .Changed {
            frontView?.center = dragPoint
            if r1 <= 6 {
                fillColorForDrag = UIColor.clearColor()
                backView.hidden = true
                shapeLayer.removeFromSuperlayer()
            }
            drawRect()
        } else if gesture.state == .Ended || gesture.state == .Cancelled || gesture.state == .Failed {
            
            if r1 > 6 || !disappearEnable {
                backView.hidden = true
                fillColorForDrag = UIColor.clearColor()
                shapeLayer.removeFromSuperlayer()
            
                UIView.animateWithDuration(0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 0.0,
                    options: .CurveEaseInOut,
                    animations: { () -> Void in
                        self.frontView?.center = self.oldBackViewCenter
                    },
                    completion: { (Bool) -> Void in
                        self.drawRect()
                        self.addBuubleAnimation()
                })
            } else {
                // add animationImageView to superview
                let animationImageView: XHSmokePuffImageView = XHSmokePuffImageView(frame: frontView!.frame)
                frontView?.superview?.addSubview(animationImageView)
                frontView?.hidden = true
                if soundEnable == true {
                    animationImageView.playAudio()
                }
                animationImageView.playAnimation(withCompletionHandler: { () -> Void in
                    animationImageView.removeFromSuperview()
                    self.removeFromSuperview()
                })
            }
        }
    }
    
    func clean() {
        self.removeBubbleAnimation()
        self.shapeLayer.removeFromSuperlayer()
        self.layer.removeFromSuperlayer()
        self.frontView?.removeFromSuperview()
        self.backView.removeFromSuperview()
        // self.removeFromSuperview()
    }
}

// MARK: GameCenter Bubble Animation

extension XHBubbleView {
    private func addBuubleAnimation() {
        
        // circle (postion) animation
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        pathAnimation.repeatCount = Float.infinity
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pathAnimation.duration = 5.0
        
        let curvePath = CGPathCreateMutable()
        guard let frontView = frontView else {
            print("FrontView is NIL")
            return
        }
        let circleContainer = CGRectInset(frontView.frame, frontView.bounds.width / 2 - 3, frontView.bounds.height / 2 - 3)
        CGPathAddEllipseInRect(curvePath, nil, circleContainer)
        
        pathAnimation.path = curvePath
        frontView.layer.addAnimation(pathAnimation, forKey: "circleAnimation")
        
        // x scale (transform.scale.x) animation
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1.0
        scaleX.values = [1.0, 1.1, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.autoreverses = true
        
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontView.layer.addAnimation(scaleX, forKey: "scaleXAnimation")
        
        // y scale (transform.scale.y) animation
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.1, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.autoreverses = true
        
        scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontView.layer.addAnimation(scaleY, forKey: "scaleYAnimation")
    }
    
    private func removeBubbleAnimation() {
        if let frontView = frontView {
            frontView.layer.removeAllAnimations()
        }
    }
}