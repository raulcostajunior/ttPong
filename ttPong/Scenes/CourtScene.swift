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
    }
    
    static let PAD_INSET = CGFloat(12.0)
    static let ICON_H_SPACING = CGFloat(36.0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _disc: Disc!
    private var _leftPad: PadSprite!
    private var _rightPad: PadSprite!
    private var _soundOption: SoundOptionSprite!
    private var _gameInfo: HelpSprite!
    
    private var _scoreDisp: SKLabelNode!
    private var _discsDisp: SKLabelNode!
    private var _msgDisp1: SKLabelNode!
    private var _msgDisp2: SKLabelNode!
    private var _msgPaused: SKLabelNode!
    
    private var _discAppearance: SKEmitterNode!
    
    private var _state = CourtState.WaitToStartGame
      
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue:0.0, alpha: 1.0)
        
        _disc = Disc(with: DiscSprite(for: size))
        _disc.sprite.position = CGPoint(x: size.width/2.0, y: 100.0)
        self.addChild(_disc.sprite)

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
        
        _msgPaused = SKLabelNode(fontNamed: "Phosphate")
        _msgPaused.fontSize = 19
        _msgPaused.fontColor = UIColor.white
        _msgPaused.position = CGPoint(x: _rightPad.position.x - 50.0,
                                      y: sndOptVPos)
        _msgPaused.horizontalAlignmentMode = .right
        _msgPaused.verticalAlignmentMode = .center
        _msgPaused.text = "Game Paused"
        self.addChild(_msgPaused)
        
        let discAppearancePath =
            Bundle.main.path(forResource: "DiscAppearance",
                             ofType: "sks")
        _discAppearance =
            NSKeyedUnarchiver.unarchiveObject(withFile: discAppearancePath!)
            as? SKEmitterNode
        _discAppearance.isHidden = true
        _discAppearance.alpha = 0.0
        self.addChild(_discAppearance)
        
        // Physics related initializations
        // Court has no gravity affecting it
        self.physicsWorld.gravity = CGVector(dx:0.0, dy:0.0)
    }
    
    internal func gotoInitialState() {
        _state = .WaitToStartGame
    }
    
    private func updateSceneState() {
        switch _state {
        case .WaitToStartGame:
            _disc.sprite.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            let lHPos = _leftPad.size.width/2.0 + CourtScene.PAD_INSET
            let vPos = size.height/2.0
            _leftPad.position = CGPoint(x: lHPos, y: vPos)
            let rHPos = self.size.width - CourtScene.PAD_INSET - _rightPad.size.width/2.0
            _rightPad.position = CGPoint(x: rHPos, y: vPos)
            _leftPad.isHidden = false
            _rightPad.isHidden = false
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start game
                _state = .StartingGame
                let fadeOutMsg = SKAction.fadeOut(withDuration: 3.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                launchDisc()
            }
        case .StartingGame:
            _disc.sprite.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
        case .GameOngoing:
            _disc.sprite.isHidden = false
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = true
            _msgDisp2.isHidden = true
            _msgPaused.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if !_leftPad.isActive && !_rightPad.isActive {
                // Releasing both pads while match is ongoing, pauses it
                _state = .GamePaused
                _disc.pauseDisc()
            }
        case .GamePaused:
            _disc.sprite.isHidden = false
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = false
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            if _leftPad.isActive || _rightPad.isActive {
                _state = .GameOngoing
                _disc.resumeDisc()
            }
        case .GameFinished, .GameFinishedNewRecord:
            // TODO: Give NewRecord case its own handler - has to navigate to
            //       new record entry string.
            _disc.sprite.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 3 && _state == .GamePaused {
            // User chose to abort game
            self.alpha = 0.0
            let fadeInScene = SKAction.fadeIn(withDuration: 1.5)
            self.run(fadeInScene)
            _state = .WaitToStartGame
            GameManager.shared.startNewGame()
        }
    }
    
    override func didEvaluateActions() {
        updateSceneState()
        _disc.sprite.isActive = _leftPad.isActive || _rightPad.isActive
        _scoreDisp.text = scoreBoardText()
        _discsDisp.text = discsText()
        setMsgs()
    }
    
    private func launchDisc() {
        let fromRight = Bool.random()
        let leftLimit = _leftPad.size.width + 40.0
        let rightLimit = self.size.width/2 - 40.0
        var xOffset =
            CGFloat.random(in: leftLimit...rightLimit)
        if fromRight {
            // When the disk is comming from right, the x offset is relative to
            // the middle of the court, not to its left border.
            xOffset += self.size.width/2.0
        }
        let initialPos =
            CGPoint(x: xOffset,
                    y: CGFloat.random(
                        in: CourtScene.PAD_INSET...size.height - CourtScene.PAD_INSET))
        _discAppearance.position = initialPos
        _discAppearance.isHidden = false
        let fadeInDisc = SKAction.fadeIn(withDuration: 1.5)
        _discAppearance.run(fadeInDisc)
        
        Timer.scheduledTimer(
            withTimeInterval: 1.5,
            repeats: false,
            block: { timer in
                self._discAppearance.alpha = 0.0
                self._discAppearance.isHidden = true
                self._state = CourtState.GameOngoing
                var xVelocity = CGFloat(500.0)
                if fromRight {
                    xVelocity = -xVelocity
                }
                let yVelocity = CGFloat.random(in:-500.0...500.0)
                self._disc.sprite.position = initialPos
                self._disc.velocity =
                    CGVector(dx: xVelocity, dy: yVelocity)
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
