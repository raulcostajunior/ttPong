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
        if GameManager.shared.gameCenterSessionActive {
            // Perform a pulsating effect on the button - the rendering of the
            // score board takes a while to take over the screen and the user
            // needs some feedback that the tool button has been activated.
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let fadeIn = SKAction.fadeIn(withDuration: 0.8)
            self.run(fadeOut, completion: {
                self.run(fadeIn, completion: {
                    self.run(fadeOut, completion: {
                        self.run(fadeIn)
                    })
                })
            })
        }
        GameManager.shared.displayRecords()
        super.touchesEnded(touches, with: event)
    }

}
