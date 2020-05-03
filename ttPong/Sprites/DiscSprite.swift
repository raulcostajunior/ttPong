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
        ctxt.setFillColor(red: 255.0, green: 234.0, blue: 0.0, alpha: 1.0)
        ctxt.setStrokeColor(red: 255.0, green: 234.0, blue: 0.0, alpha: 1.0)
        ctxt.addEllipse(in: CGRect(x: 0.0, y: 0.0,
                                   width: Double(diameter),
                                   height:Double(diameter)))
        ctxt.drawPath(using: .fillStroke)
        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        let texture = SKTexture(image: textureImg)
        
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    

}
