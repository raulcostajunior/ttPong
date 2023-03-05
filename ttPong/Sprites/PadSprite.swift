//
//  PadSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 19.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

class PadSprite: SKSpriteNode {
    
    // Width set to the minimum recommended width for touch interactive
    // elements.
    static let WIDTH = 44

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var _active = false
    
    private var _activeTexture: SKTexture!
    private var _inactiveTexture: SKTexture!

    // Reference to the container scene used internally to refer to the
    // container scene's coordinate system. Computed once in the lifetime
    // of the pad sprite - safe as long the same pad sprite is not reused
    // across multiple scenes.
    private weak var _sceneNode: SKNode?
    private var sceneNode: SKNode? {
        if let sn = _sceneNode {
            return sn
        }
        var pn = self.parent
        while let sn = pn, !(sn is SKScene) {
            pn = self.parent
        }
        return pn
    }

    /**
     A pad is active while it is touched.
     
     An active pad is fully opaque. An inactive pad is
     partially transparent.
     */
    var isActive: Bool { _active }
    
    /**
     A pad is movable or not depending on an external
     stimulus.
     While the game is paused, a pad can be active or not
     depending only on whether it is touched. It will be
     movable only when the game is not paused.
     */
    var movable: Bool = false
    
    /**
     The collision category common to all pads.
     */
    static let CollisionCateg: UInt32 = 0x1 << 1
    
    init(for sceneSize:CGSize) {
        let height = Int(round(sceneSize.height/3.2))
            
        super.init(texture: nil, color: UIColor.clear,
                   size: CGSize(width: PadSprite.WIDTH, height: height))

        _inactiveTexture = initTexture(width: PadSprite.WIDTH, height: height,
                                       active: false)
        _activeTexture = initTexture(width: PadSprite.WIDTH, height: height,
                                     active: true)
        
        texture = _inactiveTexture
        
        isUserInteractionEnabled = true
        
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody!.isDynamic = false
        physicsBody!.restitution = 1.0
        physicsBody!.categoryBitMask = PadSprite.CollisionCateg
    }

    private func initTexture(width: Int, height: Int,
                             active: Bool) -> SKTexture? {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let ctxt: CGContext! = UIGraphicsGetCurrentContext()
        let rectPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0,
                                                        width: width,
                                                        height: height),
                                    cornerRadius: 4.0)
        if active {
            ctxt.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        } else {
            ctxt.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.3)
        }
        rectPath.fill()
        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: textureImg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _active = true
        texture = _activeTexture
        if movable {
            // Forced unwrap of sceneNode at this point is safe - the sprite must
            // be a node in some scene to receive touch events.
            self.position =
                CGPoint(x: self.position.x,
                        y: touches[touches.startIndex].location(in:self.sceneNode!).y)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _active = false
        texture = _inactiveTexture
        super.touchesEnded(touches, with:event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard movable else { return };
        // Forced unwrap of sceneNode at this point is safe - the sprite must
        // be a node in some scene to receive touch events.
        self.position =
            CGPoint(x: self.position.x,
                    y: touches[touches.startIndex].location(in: self.sceneNode!).y)
    }

}
