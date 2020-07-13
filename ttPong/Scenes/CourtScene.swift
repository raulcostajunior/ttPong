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
    private var _msgDisp1: SKLabelNode!
    private var _msgDisp2: SKLabelNode!
    
    private var _discAppearance: SKEmitterNode!
    
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
        
        _msgDisp1 = SKLabelNode(fontNamed: "Phosphate")
        _msgDisp1.fontSize = 19
        _msgDisp1.fontColor = UIColor.yellow
        _msgDisp1.position = CGPoint(x: size.width/2,
                                     y: size.height/2 + _msgDisp1.fontSize)
        _msgDisp1.horizontalAlignmentMode = .center
        _msgDisp1.verticalAlignmentMode = .center
        self.addChild(_msgDisp1)
        
        _msgDisp2 = SKLabelNode(fontNamed: "Phosphate")
        _msgDisp2.fontSize = 19
        _msgDisp2.fontColor = UIColor.yellow
        _msgDisp2.position = CGPoint(x: size.width/2,
                                     y: size.height/2 - 8)
        _msgDisp2.horizontalAlignmentMode = .center
        _msgDisp2.verticalAlignmentMode = .center
        self.addChild(_msgDisp2)
        
        let discAppearancePath =
            Bundle.main.path(forResource: "DiscAppearance",
                             ofType: "sks")
        _discAppearance =
            NSKeyedUnarchiver.unarchiveObject(withFile: discAppearancePath!)
            as? SKEmitterNode
        _discAppearance.isHidden = true
        _discAppearance.alpha = 0.0
        self.addChild(_discAppearance)
    }
    
    private func updateSceneState() {
        switch _state {
        case .WaitToStartGame:
            _disc.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start game
                _state = .StartingGame
                let fadeOutMsg = SKAction.fadeOut(withDuration: 2.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                launchDisc()
            }
        case .GameFinished, .GameFinishedNewRecord,
             .GamePaused, .GameAborted:
            _disc.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            if _leftPad.isActive || _rightPad.isActive {
                _state = .GameOngoing
            }
        case .GameOngoing:
            _disc.isHidden = false
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if !_leftPad.isActive && !_rightPad.isActive {
                 // Releasing both pads while match is ongoing, pauses it
                 _state = .GamePaused
             }
        case .StartingGame:
            // TODO: Display the starting particle effect
            // TODO: Define a random disc appearing position and velocity vector
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = false
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
         }
    }
    
    override func didEvaluateActions() {
        updateSceneState()
        _disc.isActive = _leftPad.isActive || _rightPad.isActive
        _scoreDisp.text = scoreBoardText()
        _discsDisp.text = discsText()
        setMsgs()
    }
    
    private func launchDisc() {
        let fromLeft = Bool.random()
        var offsetFromMiddle =
            CGFloat.random(in: 20.0...(self.size.width/2.0-(_leftPad.size.width+5.0)))
        if fromLeft {
            offsetFromMiddle = -offsetFromMiddle
        }
        let initialPos = CGPoint(x: self.size.width/2.0 + offsetFromMiddle,
                                 y: CGFloat.random(in: 10.0...self.size.height - 20.0))
        
        // TODO: initial speed X as positive or negative depending on initial
        //       position. Should be a reasonable constant absolute value.
        var initialSpeedX = 2.0
        // TODO: initial speed Y with slight variation to allow different
        //       trajectory slopes.
        var initialSpeedY = 4.0
        
        _discAppearance.position = initialPos
        _discAppearance.isHidden = false
        let fadeInDisc = SKAction.fadeIn(withDuration: 1.0)
        _discAppearance.run(fadeInDisc)
        
        let _ = Timer.scheduledTimer(
                      withTimeInterval: 2.0,
                      repeats: false,
                      block: { timer in
                          self._discAppearance.alpha = 0.0
                          self._discAppearance.isHidden = true
                          self._state = CourtState.GameOngoing
                          // TODO: start the disc physics
                })
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
    
    private func setMsgs() {
        switch _state {
        case .WaitToStartGame:
            _msgDisp1.text = "To start a new match,"
            _msgDisp2.text = "touch and hold both pads."
        case .GameFinishedNewRecord:
            _msgDisp1.text = "Well done!"
            _msgDisp2.text = "You've set a new record!"
        case .GamePaused:
            _msgDisp1.text = "To resume, touch one or both pads."
            _msgDisp2.text = "To abort, touch anywhere with 3 fingers."
        case .GameAborted:
            _msgDisp1.text = "Game aborted."
            if GameManager.shared.scoreBoard.isNewRecord {
                _msgDisp2.text = "Congrats, you've set a new record!"
            } else {
                _msgDisp2.text = "Hope you come back soon!"
            }
        case .StartingGame:
            _msgDisp1.text = "Get ready to play!"
            _msgDisp2.text = "To pause the match, release both pads."
        case .GameOngoing:
            _msgDisp1.text = ""
            _msgDisp2.text = ""
        case .GameFinished:
            // TODO: think about better finished message - maybe congratulate
            //       if score is above a given threshold; display playing time.
            _msgDisp1.text = "Thanks for playing!"
            _msgDisp2.text = "Touch anywhere to start a new game."
        }
    }

}
