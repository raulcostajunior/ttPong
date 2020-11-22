//
//  AboutGameSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 06.07.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit


class AboutGameSprite: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(texture: nil,
                   color: UIColor.clear,
                   size: CGSize(width:40, height:40))
        
        let infoImg = UIImage(named: "help")
        texture = SKTexture.init(image: infoImg!)

        isUserInteractionEnabled = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event:UIEvent?) {
        GameManager.shared.displayAboutInfo()
        super.touchesEnded(touches, with: event)
    }
    
}
