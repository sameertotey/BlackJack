//
//  MKLayer.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/15/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit
import QuartzCore

enum MKTimingFunction {
    case Linear
    case EaseIn
    case EaseOut
    case Custom(Float, Float, Float, Float)
    
    var function : CAMediaTimingFunction {
        switch self {
        case .Linear:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "linear"))
        case .EaseIn:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeIn"))
        case .EaseOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeOut"))
        case .Custom(let cpx1, let cpy1, let cpx2, let cpy2):
            return CAMediaTimingFunction(controlPoints: cpx1, cpy1, cpx2, cpy2)
        }
    }
}

enum MKRippleLocation {
    case Center
    case Left
    case Right
    case TapLocation
}

class MKLayer {
    private var superLayer: CALayer!
    private let circleLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let maskLayer = CAShapeLayer()
    var rippleLocation: MKRippleLocation = .TapLocation {
        didSet {
            var origin: CGPoint?
            switch rippleLocation {
            case .Center:
                origin = CGPoint(x: superLayer.bounds.width/2, y: superLayer.bounds.height/2)
            case .Left:
                origin = CGPoint(x: superLayer.bounds.width * 0.25, y: superLayer.bounds.height/2)
            case .Right:
                origin = CGPoint(x: superLayer.bounds.width * 0.75, y: superLayer.bounds.height/2)
            default:
                origin = nil
            }
            if let originPoint = origin {
                setCircleLayerLocationAt(center: originPoint)
            }
        }
    }
    
    var circleGrowRatioMax: Float = 0.9 {
        didSet {
            if circleGrowRatioMax > 0 {
                let superLayerWidth = superLayer.bounds.width
                let superLayerHeight = superLayer.bounds.height
                let circleSize = CGFloat(max(superLayerWidth, superLayerHeight)) * CGFloat(circleGrowRatioMax)
                let circleCornerRadius = circleSize/2
                
                circleLayer.cornerRadius = circleCornerRadius
                setCircleLayerLocationAt(center: CGPoint(x: superLayerWidth/2, y: superLayerHeight/2))
            }
        }
    }
    
    init(superLayer: CALayer) {
        self.superLayer = superLayer
        
        let superLayerWidth = superLayer.bounds.width
        let superLayerHeight = superLayer.bounds.height
        
        // background layer
        backgroundLayer.frame = superLayer.bounds
        backgroundLayer.opacity = 0.0
        superLayer.addSublayer(backgroundLayer)
        
        // circlelayer
        let circleSize = CGFloat(max(superLayerWidth, superLayerHeight)) * CGFloat(circleGrowRatioMax)
        let circleCornerRadius = circleSize/2
       
        circleLayer.opacity = 0.0
        circleLayer.cornerRadius = circleCornerRadius
        setCircleLayerLocationAt(center: CGPoint(x: superLayerWidth/2, y: superLayerHeight/2))
        backgroundLayer.addSublayer(circleLayer)
        
        // mask layer
        setMaskLayerCornerRadius(cornerRadius: superLayer.cornerRadius)
        backgroundLayer.mask = maskLayer
    }
    
    func superLayerDidResize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = superLayer.bounds
        setMaskLayerCornerRadius(cornerRadius: superLayer.cornerRadius)
        CATransaction.commit()
        setCircleLayerLocationAt(center: CGPoint(x: superLayer.bounds.width/2, y: superLayer.bounds.height/2))
    }
    
    func enableOnlyCircleLayer() {
        backgroundLayer.removeFromSuperlayer()
        superLayer.addSublayer(circleLayer)
    }
    
    func setBackgroundLayerColor(color: UIColor) {
        backgroundLayer.backgroundColor = color.cgColor
    }
    
    func setCircleLayerColor(color: UIColor) {
        circleLayer.backgroundColor = color.cgColor
    }
    
    func didChangeTapLocation(location: CGPoint) {
        if rippleLocation == .TapLocation {
            self.setCircleLayerLocationAt(center: location)
        }
    }
    
    func setMaskLayerCornerRadius(cornerRadius: CGFloat) {
        maskLayer.path = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: cornerRadius).cgPath
    }
   
    func enableMask(enable: Bool = true) {
        backgroundLayer.mask = enable ? maskLayer : nil
    }
    
    func setBackgroundLayerCornerRadius(cornerRadius: CGFloat) {
        backgroundLayer.cornerRadius = cornerRadius
    }
    
    private func setCircleLayerLocationAt(center: CGPoint) {
        let bounds = superLayer.bounds
        let width = bounds.width
        let height = bounds.height
        let subSize = CGFloat(max(width, height)) * CGFloat(circleGrowRatioMax)
        let subX = center.x - subSize/2
        let subY = center.y - subSize/2
        
        // disable animation when changing layer frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleLayer.cornerRadius = subSize / 2
        circleLayer.frame = CGRect(x: subX, y: subY, width: subSize, height: subSize)
        CATransaction.commit()
    }
    
    // MARK - Animation
    func animateScaleForCircleLayer(fromScale: Float, toScale: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let circleLayerAnim = CABasicAnimation(keyPath: "transform.scale")
        circleLayerAnim.fromValue = fromScale
        circleLayerAnim.toValue = toScale
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.0
        
        let groupAnim = CAAnimationGroup()
        groupAnim.duration = duration
        groupAnim.timingFunction = timingFunction.function
        groupAnim.isRemovedOnCompletion = false
        groupAnim.fillMode = CAMediaTimingFillMode.forwards
        
        groupAnim.animations = [circleLayerAnim, opacityAnim]
    
        circleLayer.add(groupAnim, forKey: nil)
    }
    
    func animateAlphaForBackgroundLayer(timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let backgroundLayerAnim = CABasicAnimation(keyPath: "opacity")
        backgroundLayerAnim.fromValue = 1.0
        backgroundLayerAnim.toValue = 0.0
        backgroundLayerAnim.duration = duration
        backgroundLayerAnim.timingFunction = timingFunction.function
        backgroundLayer.add(backgroundLayerAnim, forKey: nil)
    }
    
    func animateSuperLayerShadow(fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        animateShadowForLayer(layer: superLayer, fromRadius: fromRadius, toRadius: toRadius, fromOpacity: fromOpacity, toOpacity: toOpacity, timingFunction: timingFunction, duration: duration)
    }
    
    func animateMaskLayerShadow() {
        
    }
    
    private func animateShadowForLayer(layer: CALayer, fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = fromRadius
        radiusAnimation.toValue = toRadius
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.timingFunction = timingFunction.function
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.animations = [radiusAnimation, opacityAnimation]
        
        layer.add(groupAnimation, forKey: nil)
    }
}
