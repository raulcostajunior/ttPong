//
//  CourtScene.swift
//  ttPong
//
//  Created by Raul Costa Junior on 18.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit
import GameplayKit


class CourtScene: SKScene {
    
    static let PAD_INSET = CGFloat(12.0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var disc: DiscSprite!
    private var leftPad: PadSprite!
    private var rightPad: PadSprite!
    
    private var scoreDisp: SKLabelNode!
    private var discsDisp: SKLabelNode!
      
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue:0.0, alpha: 1.0)
        
        disc = DiscSprite(for: size)
        disc.position = CGPoint(x: size.width/2.0, y: 100.0)
        self.addChild(disc)

        leftPad = PadSprite(for: size)
        let lHPos = leftPad.size.width/2.0 + CourtScene.PAD_INSET
        let vPos = size.height/2.0
        leftPad.position = CGPoint(x: lHPos, y: vPos)
        self.addChild(leftPad)

        rightPad = PadSprite(for: size)
        let rHPos = size.width - rightPad.size.width/2.0 - CourtScene.PAD_INSET
        rightPad.position = CGPoint(x: rHPos, y: vPos)
        self.addChild(rightPad)
        
        scoreDisp = SKLabelNode(fontNamed: "Phosphate")
        scoreDisp.fontSize = 18
        scoreDisp.position = CGPoint(x: rightPad.position.x - 50.0,
                                     y: size.height - CourtScene.PAD_INSET)
        scoreDisp.horizontalAlignmentMode = .right
        scoreDisp.verticalAlignmentMode = .top
        self.addChild(scoreDisp)
        
        discsDisp = SKLabelNode(fontNamed: "Phosphate")
        discsDisp.fontSize = 18
        discsDisp.position = CGPoint(x: size.width/4,
                                     y: size.height - CourtScene.PAD_INSET)
        discsDisp.horizontalAlignmentMode = .center
        discsDisp.verticalAlignmentMode = .top
        self.addChild(discsDisp)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // TODO: display top menu if state is WaitingForStart or Paused
    }
    
    override func didEvaluateActions() {
        disc.isActive = leftPad.isActive || rightPad.isActive
        
        scoreDisp.text = scoreBoardText()
        scoreDisp.fontColor =
            (disc.isActive ? UIColor.white : UIColor.systemGray)
        
        discsDisp.text = discsText()
        discsDisp.fontColor =
            (disc.isActive ? UIColor.white : UIColor.systemGray)
    }
    
    private func scoreBoardText() -> String {
        let fmtScore = String(format:"%04d",
                              GameManager.shared.scoreBoard.score)
        let fmtHighScore = String(format:"%04d",
                                  GameManager.shared.scoreBoard.highScore)
        return "SCORE - \(fmtScore)      HIGH - \(fmtHighScore)"
    }
    
    private func discsText() -> String {
        let adsks = GameManager.shared.availableDiscs
        var txt = ""
        switch adsks {
        case 0: txt = "LAST DISC"
        case 1: txt = "1 X DISC"
        default: txt = "\(adsks) X DISCS"
        }
        return txt
    }

}
