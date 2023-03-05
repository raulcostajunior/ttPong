//
//  DiscSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 19.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit


class DiscSprite: SKSpriteNode {
    
    static let CollisionCateg: UInt32 = 0x1 << 2
    
    private var _activeTexture: SKTexture!
    private var _inactiveTexture: SKTexture!
    
    private var _paused = false
    private var _resumeVelocity: CGVector?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(for sceneSize:CGSize) {
        let diameter = Double(sceneSize.height/12.0)
        let intDiameter = Int(round(diameter))
       
        super.init(texture: nil, color: UIColor.clear,
                   size: CGSize(width: intDiameter, height: intDiameter))
        
        _inactiveTexture = initTexture(diameter: intDiameter, active: false)
        _activeTexture = initTexture(diameter: intDiameter, active: true)
        
        texture = _activeTexture
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2.0)
        physicsBody!.isDynamic = true
        physicsBody!.linearDamping = 0.0   // No friction force actuating
        physicsBody!.restitution = 1.0     // No speed loss on collision
        physicsBody!.allowsRotation = true
        physicsBody!.angularDamping = 0.1
        physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
        physicsBody!.categoryBitMask = DiscSprite.CollisionCateg
    }
    
    private func initTexture(diameter: Int, active: Bool) -> SKTexture? {
        UIGraphicsBeginImageContext(CGSize(width: diameter,
                                           height: diameter))
        let discAlpha = CGFloat(active ? 1.0 : 0.2)
        
        let ctxt: CGContext! = UIGraphicsGetCurrentContext()
        // The disc body.
        ctxt.setFillColor(red: 1.0, green: 234.0/255.0, blue: 0.0,
                          alpha: discAlpha)
        ctxt.addEllipse(in: CGRect(x: 0.0, y: 0.0,
                                   width: Double(diameter),
                                   height:Double(diameter)))
        ctxt.drawPath(using: .fill)      
        // The border arcs - provide feedback on rotation - only when active.
        if active {
            ctxt.setStrokeColor(red: 1.0, green: 106.0/255.0,
                                blue: 0.0, alpha: discAlpha)
            let radius = CGFloat(Double(diameter)/2.0)
            let center = CGPoint(x: radius, y: radius)
            ctxt.setLineWidth(4.0)
            ctxt.addArc(center: center, radius: radius - 4.0,
                        startAngle: 0.0, endAngle: 1.0472, clockwise: false)
            ctxt.drawPath(using: .stroke)
            ctxt.addArc(center: center, radius: radius - 4.0,
                        startAngle: 2.0944, endAngle: 3.14159, clockwise: false)
            ctxt.drawPath(using: .stroke)
            ctxt.addArc(center: center, radius: radius - 4.0,
                        startAngle: 4.1887, endAngle: 5.23599, clockwise: false)
            ctxt.drawPath(using: .stroke)
        }

        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: textureImg)
    }
    
    func pause() {
        _paused = true
        self.isPaused = true
        _resumeVelocity = physicsBody!.velocity
        texture = _inactiveTexture
        physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    func resume() {
        assert(_resumeVelocity != nil,
               "A paused disc must have a defined _resumeVelocity!")
        physicsBody!.velocity = _resumeVelocity!
        _paused = false
        self.isPaused = false
        texture = _activeTexture
    }

    /// Resets the disc to its initial state - non paused but with zero velocity.
    func reset() {
        _paused = false
        self.isPaused = false
        texture = _activeTexture
        physicsBody!.velocity = CGVector(dx:0.0, dy: 0.0)
    }
    
    var isActive: Bool { !_paused }
    
    var velocity: CGVector {
        get {
            return physicsBody!.velocity
        }
        
        set {
            physicsBody!.velocity = newValue
        }
    }
    
}
