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
    
    enum CourtState {
        case WaitToStartGame
        case StartingGame
        case GameOngoing
        case GamePaused
        case GameFinished
        case GameFinishedNewRecord
        case GameAborted
    }
    
    static let PAD_INSET = CGFloat(12.0)
    static let ICON_H_SPACING = CGFloat(36.0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _disc: DiscSprite!
    private var _leftPad: PadSprite!
    private var _rightPad: PadSprite!
    private var _soundOption: SoundOptionSprite!
    private var _gameInfo: HelpSprite!
    
    private var _scoreDisp: SKLabelNode!
    private var _discsDisp: SKLabelNode!
    private var _msgDisp: SKLabelNode!
    
    private var _state = CourtState.WaitToStartGame
      
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue:0.0, alpha: 1.0)
        
        _disc = DiscSprite(for: size)
        _disc.position = CGPoint(x: size.width/2.0, y: 100.0)
        self.addChild(_disc)

        _leftPad = PadSprite(for: size)
        let lHPos = _leftPad.size.width/2.0 + CourtScene.PAD_INSET
        let vPos = size.height/2.0
        _leftPad.position = CGPoint(x: lHPos, y: vPos)
        self.addChild(_leftPad)

        _rightPad = PadSprite(for: size)
        let rHPos = self.size.width - CourtScene.PAD_INSET - _rightPad.size.width/2.0
        _rightPad.position = CGPoint(x: rHPos, y: vPos)
        self.addChild(_rightPad)
        
        _soundOption = SoundOptionSprite()
        let sndOptHPos = lHPos
        let sndOptVPos =
            self.size.height - (CourtScene.PAD_INSET + _soundOption.size.height/2)
        _soundOption.position = CGPoint(x: sndOptHPos, y: sndOptVPos)
        self.addChild(_soundOption)
        
        _gameInfo = HelpSprite()
        let infoHPos = sndOptHPos + _soundOption.size.width/2 + CourtScene.ICON_H_SPACING
        let infoVPos = sndOptVPos
        _gameInfo.position = CGPoint(x: infoHPos, y: infoVPos)
        self.addChild(_gameInfo)
        
        _scoreDisp = SKLabelNode(fontNamed: "Phosphate")
        _scoreDisp.fontSize = 16
        _scoreDisp.position = CGPoint(x: _rightPad.position.x - 50.0,
                                     y: size.height - CourtScene.PAD_INSET)
        _scoreDisp.horizontalAlignmentMode = .right
        _scoreDisp.verticalAlignmentMode = .top
        self.addChild(_scoreDisp)
        
        _discsDisp = SKLabelNode(fontNamed: "Phosphate")
        _discsDisp.fontSize = 16
        _discsDisp.position = CGPoint(x: size.width/4,
                                     y: size.height - CourtScene.PAD_INSET)
        _discsDisp.horizontalAlignmentMode = .center
        _discsDisp.verticalAlignmentMode = .top
        self.addChild(_discsDisp)
        
        _msgDisp = SKLabelNode(fontNamed: "Phosphate")
        _msgDisp.fontSize = 19
        _msgDisp.fontColor = UIColor.yellow
        _msgDisp.position = CGPoint(x: size.width/2,
                                   y: size.height/2)
        _msgDisp.horizontalAlignmentMode = .center
        _msgDisp.verticalAlignmentMode = .center
        self.addChild(_msgDisp)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // TODO: display top menu if state is WaitingForStart or Paused
        switch _state {
        case .WaitToStartGame, .GameFinished,
             .GameFinishedNewRecord, .GamePaused,
             .GameAborted:
            _disc.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp.isHidden = false
            _soundOption.isHidden = false
        case .GameOngoing:
            _disc.isHidden = false
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp.isHidden = true
            _soundOption.isHidden = true
        case .StartingGame:
            // TODO: Display the starting particle effect
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp.isHidden = false
            _soundOption.isHidden = true
        }
    }
    
    override func didEvaluateActions() {
        _disc.isActive = _leftPad.isActive || _rightPad.isActive
        _scoreDisp.text = scoreBoardText()
        _discsDisp.text = discsText()
        _msgDisp.text = msgText()
    }
    
    private func scoreBoardText() -> String {
        let fmtScore = String(format:"%03d",
                              GameManager.shared.scoreBoard.score)
        let fmtHighScore = String(format:"%03d",
                                  GameManager.shared.scoreBoard.highScore)
        return "SCORE - \(fmtScore)      HIGH - \(fmtHighScore)"
    }
    
    private func discsText() -> String {
        let adsks = GameManager.shared.availableDiscs
        var txt = ""
        switch adsks {
        case 0: txt = "LAST DISC"
        case 1: txt = "DISC - 1"
        default: txt = "DISCS - \(adsks)"
        }
        return txt
    }
    
    private func msgText() -> String {
        switch _state {
        case .WaitToStartGame:
            return "Touch and hold both pads to start a new game."
        case .GameFinishedNewRecord:
            return "Well done! You've set a new record!"
        case .GamePaused:
            return "Touch one or both pads to resume the game.\nTouch anywhere with 3 fingers to abort."
        case .GameAborted:
            return "Game aborted."
        case .StartingGame:
            return "Game starting - Get Ready!\nRelease both pads to pause the match."
        case .GameOngoing:
            return ""
        case .GameFinished:
            // TODO: think about better finished message - maybe congratulate
            //       if score is above a given threshold; display playing time.
            return "Thanks for playing!\nTouch anywhere to start a new game."
        }
    }

}
