//
//  PadSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 19.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

class PadSprite: SKSpriteNode {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(for sceneSize:CGSize) {
        let height = Int(round(sceneSize.height/4.0))
        let width = Int(round(sceneSize.width*2.5 / 60.0))
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let ctxt: CGContext! = UIGraphicsGetCurrentContext()
        ctxt.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let rectPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0,
                                                        width: width,
                                                        height: height),
                                    cornerRadius: 4.0)
        rectPath.fill()
        let textureImg: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        let texture = SKTexture(image: textureImg)
        UIGraphicsEndImageContext()

        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }

}
