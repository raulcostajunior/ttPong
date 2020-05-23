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

    /**
     A pad is active while it is touched.
     
     An active pad is fully opaque. An inactive pad is
     partially transparent.
     */
    var isActive: Bool { _active }
    
    init(for sceneSize:CGSize) {
        let height = Int(round(sceneSize.height/3.6))
            
        super.init(texture: nil, color: UIColor.clear,
                   size: CGSize(width: PadSprite.WIDTH, height: height))

        _inactiveTexture = initTexture(width: PadSprite.WIDTH, height: height,
                                       active: false)
        _activeTexture = initTexture(width: PadSprite.WIDTH, height: height,
                                     active: true)
        
        texture = _inactiveTexture
        
        isUserInteractionEnabled = true
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
            ctxt.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.4)
        }
        rectPath.fill()
        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: textureImg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _active = true
        texture = _activeTexture
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _active = false
        texture = _inactiveTexture
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: Limit the pad vertical position so it doesn't go beyond the
        //       screen viewport.
        for touch in touches {
            self.position =
                CGPoint(x: self.position.x,
                        y: self.position.y + touch.location(in: self).y)
        }
    }

}
