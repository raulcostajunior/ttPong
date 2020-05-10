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
    
    // Creates the disc sprite from a dynamically generated image of the disc.
    init(for sceneSize:CGSize) {
        let diameter = Double(sceneSize.height/12.0)
        let intDiameter = Int(round(diameter))
        UIGraphicsBeginImageContext(CGSize(width: intDiameter,
                                           height: intDiameter))
        let ctxt: CGContext! = UIGraphicsGetCurrentContext()
        // The disc body.
        ctxt.setFillColor(red: 1.0, green: 234.0/255.0, blue: 0.0,
                          alpha: 1.0)
        ctxt.addEllipse(in: CGRect(x: 0.0, y: 0.0,
                                   width: Double(diameter),
                                   height:Double(diameter)))
        ctxt.drawPath(using: .fill)
        // The border arcs - provide feedback on rotation.
        ctxt.setStrokeColor(red: 1.0, green: 106.0/255.0,
                            blue: 0.0, alpha: 1.0)
        let radius = CGFloat(diameter/2.0)
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

        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        let texture = SKTexture(image: textureImg)
        UIGraphicsEndImageContext()
        
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    

}
