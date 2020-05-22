//
//  GameScene.swift
//  ttPong
//
//  Created by Raul Costa Junior on 18.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    static let PAD_INSET = CGFloat(12.0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var disc: DiscSprite!
    private var leftPad: PadSprite!
    private var rightPad: PadSprite!
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue:0.0, alpha: 1.0)
        
        disc = DiscSprite(for: size)
        disc.position = CGPoint(x: size.width/2.0, y: 100.0)
        self.addChild(disc)

        leftPad = PadSprite(for: size)
        let lHPos = leftPad.size.width/2.0 + GameScene.PAD_INSET
        let vPos = size.height/2.0
        leftPad.position = CGPoint(x: lHPos, y: vPos)
        self.addChild(leftPad)

        rightPad = PadSprite(for: size)
        let rHPos = size.width - rightPad.size.width/2.0 - GameScene.PAD_INSET
        rightPad.position = CGPoint(x: rHPos, y: vPos)
        self.addChild(rightPad)       
    }
    
    override func didEvaluateActions() {
        disc.isActive = leftPad.isActive || rightPad.isActive
    }

}
