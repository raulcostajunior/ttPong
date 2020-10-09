//
//  LeaderboardSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 09.10.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

class LeaderBoardSprite: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(texture: nil,
                   color: UIColor.clear,
                   size: CGSize(width:40, height:40))
        let rosetteImg = UIImage(named: "rosette")
        texture = SKTexture.init(image: rosetteImg!)
        
        isUserInteractionEnabled = true
    }
     
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        GameManager.shared.displayRecords()
        super.touchesEnded(touches, with: event)
    }

}
