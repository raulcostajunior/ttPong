//
//  CourtScene.swift
//  ttPong
//
//  Created by Raul Costa Junior on 18.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit
import GameplayKit


class CourtScene: SKScene, SKPhysicsContactDelegate {
    
    enum CourtState {
        case WaitToStartMatch
        case LaunchingDisk
        case GameOngoing
        case LostDisc
        case LostLastDisc
        case WaitToStartNewRally
        case GamePaused
        case MatchFinished
        case MatchFinishedNewRecord
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
    private var _msgPaused: SKLabelNode!
    
    private var _discAppearance: SKEmitterNode!
    
    // A disc whose x position is outside the limits below is
    // considered lost.
    private var _leftLimit: CGFloat!
    private var _rightLimit: CGFloat!
    
    // A disc whose x position is within the limits below is
    // considered in court.
    private var _leftLimitIn: CGFloat!
    private var _rightLimitIn: CGFloat!
    
    private var _state: CourtState = .WaitToStartMatch
      
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue:0.0, alpha: 1.0)
        
        _disc = DiscSprite(for: size)
        _disc.name = "Disc"
        _disc.position = CGPoint(x: size.width/2.0, y: 100.0)
        self.addChild(_disc)

        _leftPad = PadSprite(for: size)
        _leftPad.name = "LeftPad"
        let lHPos = _leftPad.size.width/2.0 + CourtScene.PAD_INSET
        let vPos = size.height/2.0
        _leftPad.position = CGPoint(x: lHPos, y: vPos)
        self.addChild(_leftPad)

        _rightPad = PadSprite(for: size)
        _rightPad.name = "RightPad"
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
        _scoreDisp.fontSize = 19
        _scoreDisp.position = CGPoint(x: _rightPad.position.x - 50.0,
                                     y: size.height - CourtScene.PAD_INSET)
        _scoreDisp.horizontalAlignmentMode = .right
        _scoreDisp.verticalAlignmentMode = .top
        self.addChild(_scoreDisp)
        
        _discsDisp = SKLabelNode(fontNamed: "Phosphate")
        _discsDisp.fontSize = 19
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
        // Court has no gravity affecting it.
        self.physicsWorld.gravity = CGVector(dx:0.0, dy:0.0)
        // Limits the court with the scenes edges.
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.restitution = 1.0
        self.physicsWorld.contactDelegate = self
        // Pads and discs collide with each other
        _disc.physicsBody!.contactTestBitMask = PadSprite.CollisionCateg
        _leftPad.physicsBody!.contactTestBitMask = DiscSprite.CollisionCateg
        _rightPad.physicsBody!.contactTestBitMask = DiscSprite.CollisionCateg
        
        _leftLimit = _leftPad.position.x - _disc.size.width/2
        _rightLimit = _rightPad.position.x + _disc.size.width/2
        _leftLimitIn = _leftPad.position.x + _leftPad.size.width/2
        _rightLimitIn = _rightPad.position.x - _rightPad.size.width/2
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact:SKPhysicsContact) {
        guard _state == .GameOngoing && _disc.position.x > _leftLimitIn &&
            _disc.position.x < _rightLimitIn
            else {
            // We're only interested in collisions while game is ongoing
            // and the disc in court
            return
        }
        let contactMask =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == DiscSprite.CollisionCateg | PadSprite.CollisionCateg {
            // TODO: play sound effect for disc hitting a pad.
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard _state == .GameOngoing && _disc.position.x > _leftLimitIn &&
            _disc.position.x < _rightLimit
            else {
            // We're only interested in collisions while game is ongoing
            // and the disc in court
            return
        }
        let contactMask =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == DiscSprite.CollisionCateg | PadSprite.CollisionCateg {
            // If a few milliseconds after hitting the pad the disc had it
            // horizontal velocity component reverted, it is still in game.
            let hitLeftPad = (_disc.position.x < self.size.width/2)
            Timer.scheduledTimer(
                withTimeInterval: 0.15,
                repeats: false,
                block: { timer in
                    if (hitLeftPad && self._disc.velocity.dx > 0.0) ||
                        (!hitLeftPad && self._disc.velocity.dx < 0.0) {
                        GameManager.shared.scoreBoard.increaseScore(by: 1)
                    }
                }
            )
        }
    }
    
    // MARK: - Scene State handling
    
    func gotoInitialState() {
        _state = .WaitToStartMatch
        GameManager.shared.startNewGame()
    }
    
    private func updateSceneState() {
        switch _state {
        case .WaitToStartMatch:
            _disc.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            resetPadsPositions()
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start game
                _state = .LaunchingDisk
                let fadeOutMsg = SKAction.fadeOut(withDuration: 3.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                launchDisc()
            }
        case .LaunchingDisk:
            // Transient state - display timed message while
            // some actions are executed.
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
        case .LostDisc, .LostLastDisc:
            // Transient state - display timed message while
            // some actions are executed.
            _disc.isHidden = true
            // Hides the number of discs available as this could lead
            // to confusion. This number is shown in the message.
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
        case .WaitToStartNewRally:
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = true
            _gameInfo.isHidden = true
            resetPadsPositions()
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start new rally.
                _state = .LaunchingDisk
                let fadeOutMsg = SKAction.fadeOut(withDuration: 3.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                launchDisc()
            }
        case .GameOngoing:
            _disc.isHidden = false
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
                _disc.pause()
            }
        case .GamePaused:
            _disc.isHidden = false
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = false
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            if _leftPad.isActive || _rightPad.isActive {
                _state = .GameOngoing
                _disc.resume()
            }
        case .MatchFinished, .MatchFinishedNewRecord:
            // TODO: Give NewRecord case its own handler - has to navigate to
            //       new record entry string.
            _disc.isHidden = true
            _discsDisp.isHidden = true
            _scoreDisp.isHidden = true
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgPaused.isHidden = true
            _soundOption.isHidden = false
            _gameInfo.isHidden = false
            gotoInitialState()
        }
    }
    
    // MARK: - SKScene overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 3 &&
            (_state == .GamePaused  || _state == .LostDisc || _state == .WaitToStartNewRally) {
            // User chose to abort game
            self.alpha = 0.0
            let fadeInScene = SKAction.fadeIn(withDuration: 1.5)
            self.run(fadeInScene)
            self.gotoInitialState()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateSceneState()
        _disc.isActive = _leftPad.isActive || _rightPad.isActive

        if (_state == .GameOngoing) {
            // Guarantees the mininal disc horizontal and vertical speeds
            // (avoid edge cases where the game would be too boring).
            // The ratio between the minimum Vx/Vy is the minimal disc slope.
            if let phys = _disc.physicsBody {
                if abs(phys.velocity.dx) < 501.0 {
                    phys.velocity.dx = (phys.velocity.dx < 0 ? -501.0 : 501.0)
                }
                if abs(phys.velocity.dy) < 80.0 {
                    phys.velocity.dy = (phys.velocity.dy < 0 ? -83.0 : 83.0)
                }
            }
        }
    }
    
    override func didEvaluateActions() {
        if _state == .GameOngoing {
            // Detects and processes disc loss
            if _disc.position.x - _disc.size.width/2 < _leftLimit || _disc.position.x + _disc.size.width/2 > _rightLimit {
                // Disc is completely to the left or to the right of the scene - player lost rally.
                // TODO: Add disc lost sound effect!
                 _msgDisp1.alpha = 0.0
                _msgDisp2.alpha = 0.0
                let fadeInMsg = SKAction.fadeIn(withDuration: 0.5)
                _msgDisp1.run(fadeInMsg)
                _msgDisp2.run(fadeInMsg)
                if GameManager.shared.availableDiscs > 1 {
                    // There's at least one disc left; let user start
                    // a new rally
                    _state = .LostDisc
                    GameManager.shared.pickUpDisc()
                    Timer.scheduledTimer(withTimeInterval: 3.0,
                                         repeats: false,
                                         block: { timer in
                                            self._state = .WaitToStartNewRally
                    })
                } else {
                    // Lost rally for the last disc
                    _state = .LostLastDisc
                    var nextState: CourtState!
                    if GameManager.shared.scoreBoard.isNewRecord {
                        // TODO: Add congratulation sound effect
                        nextState = .MatchFinishedNewRecord
                    } else {
                        // TODO: Add game finished sound effect
                        nextState = .MatchFinished
                    }
                    Timer.scheduledTimer(withTimeInterval: 3.0,
                                         repeats: false,
                                         block: { timer in
                                            self._state = nextState
                    })
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        _scoreDisp.text = scoreBoardText()
        _discsDisp.text = discsText()
        setMsgs()
    }
    
    // MARK: - Private helper methods
    
    private func resetPadsPositions() {
        let lHPos = _leftPad.size.width/2.0 + CourtScene.PAD_INSET
        let vPos = size.height/2.0
        _leftPad.position = CGPoint(x: lHPos, y: vPos)
        let rHPos = self.size.width - CourtScene.PAD_INSET - _rightPad.size.width/2.0
        _rightPad.position = CGPoint(x: rHPos, y: vPos)
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
                        in: _disc.size.height*2...size.height - _disc.size.height*2))
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
                var xVelocity = CGFloat(501.0)
                if fromRight {
                    xVelocity = -xVelocity
                }
                let yVelocity = CGFloat.random(in:-550.0...550.0)
                self._disc.position = initialPos
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
        case 1: txt = "LAST DISC"
        default: txt = "DISCS - \(adsks)"
        }
        return txt
    }
    
    private func setMsgs() {
        switch _state {
        case .WaitToStartMatch:
            _msgDisp1.text = "To start a new match,"
            _msgDisp2.text = "touch and hold both pads."
        case .MatchFinishedNewRecord:
            _msgDisp1.text = "Well done!"
            _msgDisp2.text = "You've set a new record!"
        case .GamePaused:
            _msgDisp1.text = "To resume, touch one or both pads."
            _msgDisp2.text = "To abort, touch anywhere with 3 fingers."
        case .LaunchingDisk:
            _msgDisp1.text = "Get ready to play!"
            _msgDisp2.text = "To pause the game, release both pads."
        case .LostDisc:
            var discTxt: String!
            let availDiscs = GameManager.shared.availableDiscs
            if availDiscs >= 2 {
                discTxt = ", you have \(availDiscs) discs left!"
            } else if availDiscs == 1 {
                discTxt = ", make the most of your last disc!"
            }
            // There's at least one rally left ...
            _msgDisp1.text = "Get ready\(discTxt!)"
            _msgDisp2.text = "To abort, touch anywhere with 3 fingers."
        case .LostLastDisc:
            if GameManager.shared.scoreBoard.isNewRecord {
                _msgDisp1.text = "Well done!!!"
                _msgDisp2.text = "You just set a new record!"
            } else {
                // No disc left and no record breaker
                _msgDisp1.text = "Match ended!"
                _msgDisp2.text = "Go ahead and play again!!"
            }
        case .WaitToStartNewRally:
            _msgDisp1.text = "Hold both pads to launch a new disc."
            _msgDisp2.text = "To abort, touch anywhere with 3 fingers"
        case .GameOngoing:
            _msgDisp1.text = ""
            _msgDisp2.text = ""
        case .MatchFinished:
            // TODO: think about better finished message - maybe congratulate
            //       if score is above a given threshold; display playing time.
            _msgDisp1.text = "Thanks for playing!"
            _msgDisp2.text = "Touch anywhere to start a new game."
        }
    }

}
