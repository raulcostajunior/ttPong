//
//  DiscSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 19.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

class DiscSprite: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _active = false
    
    private var _activeTexture: SKTexture!
    private var _inactiveTexture: SKTexture!
    
    /**
     The disc is active when at least one of the pads is active.
     
     When the disc is active it is fully opaque, otherwise it is
     partially transparent.
     
     The disc depends on an external stimulus to be active or inactive.
     */
    var isActive: Bool {
        get {
            _active
        }
        set {
            _active = newValue
            texture = _active ? _activeTexture : _inactiveTexture
        }
    }
    
    init(for sceneSize:CGSize) {
        let diameter = Double(sceneSize.height/12.0)
        let intDiameter = Int(round(diameter))
       
        super.init(texture: nil, color: UIColor.clear,
                   size: CGSize(width: intDiameter, height: intDiameter))
        
        _inactiveTexture = initTexture(diameter: intDiameter, active: false)
        _activeTexture = initTexture(diameter: intDiameter, active: true)
        
        texture = _inactiveTexture
    }
    
    private func initTexture(diameter: Int, active: Bool) -> SKTexture? {
        UIGraphicsBeginImageContext(CGSize(width: diameter,
                                           height: diameter))
        let discAlpha = CGFloat(active ? 1.0 : 0.5)
        
        let ctxt: CGContext! = UIGraphicsGetCurrentContext()
        // The disc body.
        ctxt.setFillColor(red: 1.0, green: 234.0/255.0, blue: 0.0,
                          alpha: discAlpha)
        ctxt.addEllipse(in: CGRect(x: 0.0, y: 0.0,
                                   width: Double(diameter),
                                   height:Double(diameter)))
        ctxt.drawPath(using: .fill)
        // TODO: Uncomment drawing of border arcs as soon as disc torque simulation
        //       is in place.
        
        // The border arcs - provide feedback on rotation - only when active.
//        if active {
//            ctxt.setStrokeColor(red: 1.0, green: 106.0/255.0,
//                                blue: 0.0, alpha: discAlpha)
//            let radius = CGFloat(Double(diameter)/2.0)
//            let center = CGPoint(x: radius, y: radius)
//            ctxt.setLineWidth(4.0)
//            ctxt.addArc(center: center, radius: radius - 4.0,
//                        startAngle: 0.0, endAngle: 1.0472, clockwise: false)
//            ctxt.drawPath(using: .stroke)
//            ctxt.addArc(center: center, radius: radius - 4.0,
//                        startAngle: 2.0944, endAngle: 3.14159, clockwise: false)
//            ctxt.drawPath(using: .stroke)
//            ctxt.addArc(center: center, radius: radius - 4.0,
//                        startAngle: 4.1887, endAngle: 5.23599, clockwise: false)
//            ctxt.drawPath(using: .stroke)
//        }

        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: textureImg)
    }
    

}
