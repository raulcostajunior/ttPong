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
    
    // TOOO: (v 1.6) Set visibility per state in a more compact way; too much redundant code in the updateState at this point.
    // TODO: (v 1.6) Add state for new world record with the corresponding congratulation effects.
    enum CourtState {
        case WaitToStartMatch
        case LaunchingDisk
        case GameOngoing
        case LostDisc
        case WaitToStartNewRally
        case GamePaused
        case MatchAborted
        case MatchAbortedNewRecord
        case MatchFinished
        case MatchFinishedNewRecord
    }
    
    static let PAD_INSET = CGFloat(12.0)
    static let TOP_BOTTOM_INSET = CGFloat(2.0)
    static let ICON_H_SPACING = CGFloat(36.0)
    // The arctan of 30 degrees - will be used to derive the maximum y velocity
    // component for a maximum disc trajectory slope of 30 degrees.
    static let ARCTAN_30_DEG: CGFloat = 1.0 / sqrt(30.0)

    private var _disc: DiscSprite!
    private var _leftPad: PadSprite!
    private var _rightPad: PadSprite!
    private var _soundOption: SoundOptionSprite!
    private var _leaderBoard: LeaderBoardSprite!
    private var _themeOption: ThemeOptionSprite!
    private var _gameInfo: AboutGameSprite!
    
    // The x coordinate of the scoreboard when
    // both score and high-score are visible
    private var _scoreHighScoreX: CGFloat!
    // The x coordinate of the scoreboard when
    // only the score is visible
    private var _scoreX: CGFloat!
    
    private var _scoreDisp: SKLabelNode!
    private var _highScoreDisp: SKLabelNode!
    private var _discsDisp: SKLabelNode!
    private var _msgDisp1: SKLabelNode!
    private var _msgDisp2: SKLabelNode!
    private var _msgHighScore: SKLabelNode!
    private var _msgTitle: SKLabelNode!
    
    private var _discAppearance: SKEmitterNode!
    
    private var _discReleaseEffect: SKAction!
    private var _discHitEffect: SKAction!
    private var _discGoneEffect: SKAction!
    private var _newRecordEffect: SKAction!
    private var _gameStartEffect: SKAction!
    private var _gameOverEffect: SKAction!

    // A disc whose x position is outside the limits below is
    // considered lost.
    private var _leftLimit: CGFloat!
    private var _rightLimit: CGFloat!
    
    // A disc whose x position is within the limits below is
    // considered in court.
    private var _leftLimitIn: CGFloat!
    private var _rightLimitIn: CGFloat!
    
    // Minimum values for components of velocity vector - proportional
    // to screen size
    private var _minDxSpeed: CGFloat!
    private var _minDySpeed: CGFloat!
    
    private var _curDxSpeed: CGFloat!
    private var _maxDxSpeed: CGFloat!
    private var _hitsInRally = 0
    
    private var _state = CourtState.WaitToStartMatch

    private var state: CourtState {
        get { _state }
        set {
            _state = newValue
            setMsgs()
        }
    }

    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
        
        initDiscAppearanceEffect()
        initToolsNodes(size)
        initGameStatusNodes(size)
        initMsgDisplayingNodes(size)
        initPhysics(size)
        initSoundFx()

        gotoInitialState()
    }
    
    fileprivate func initDiscAppearanceEffect() {
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
    
    fileprivate func initToolsNodes(_ size: CGSize) {
        // The tools are centered at the bottom of the screen.
        _leaderBoard = LeaderBoardSprite()
        let leaderHPos =
            (size.width - _leaderBoard.size.width - CourtScene.ICON_H_SPACING)/2
        let leaderVPos = CourtScene.TOP_BOTTOM_INSET+_leaderBoard.size.height/2
        _leaderBoard.position = CGPoint(x: leaderHPos, y: leaderVPos)
        self.addChild(_leaderBoard)
        
        _soundOption = SoundOptionSprite()
        let sndOptHPos =
            leaderHPos - _leaderBoard.size.width/2 - CourtScene.ICON_H_SPACING
        let sndOptVPos = CourtScene.TOP_BOTTOM_INSET +
            _soundOption.size.height/2
        _soundOption.position = CGPoint(x: sndOptHPos, y: sndOptVPos)
        self.addChild(_soundOption)
        
        _themeOption = ThemeOptionSprite()
        let themeOptHPos = leaderHPos + _leaderBoard.size.width/2 +
            CourtScene.ICON_H_SPACING
        let themeOptVPos = CourtScene.TOP_BOTTOM_INSET +
            _leaderBoard.size.height/2
        _themeOption.position = CGPoint(x: themeOptHPos, y: themeOptVPos)
        self.addChild(_themeOption)
               
        _gameInfo = AboutGameSprite()
        let infoHPos = themeOptHPos + _leaderBoard.size.width/2 +
            CourtScene.ICON_H_SPACING
        let infoVPos = sndOptVPos
        _gameInfo.position = CGPoint(x: infoHPos, y: infoVPos)
        self.addChild(_gameInfo)
    }
    
    fileprivate func initMsgDisplayingNodes(_ size: CGSize) {
        _msgDisp1 = SKLabelNode(fontNamed: "Phosphate Solid")
        _msgDisp1.fontSize = 19
        _msgDisp1.fontColor = UIColor.yellow
        _msgDisp1.position = CGPoint(x: size.width/2,
                                     y: size.height/2 + _msgDisp1.fontSize)
        _msgDisp1.horizontalAlignmentMode = .center
        _msgDisp1.verticalAlignmentMode = .center
        self.addChild(_msgDisp1)
        
        _msgDisp2 = SKLabelNode(fontNamed: "Phosphate Solid")
        _msgDisp2.fontSize = 19
        _msgDisp2.fontColor = UIColor.yellow
        _msgDisp2.position = CGPoint(x: size.width/2,
                                     y: size.height/2 - 8)
        _msgDisp2.horizontalAlignmentMode = .center
        _msgDisp2.verticalAlignmentMode = .center
        self.addChild(_msgDisp2)
        
        _msgHighScore = SKLabelNode(fontNamed: "Phosphate Solid")
        _msgHighScore.fontSize = 19
        _msgHighScore.fontColor = UIColor.white
        _msgHighScore.position = CGPoint(x: size.width/2,
                                         y: size.height/2 - _msgDisp2.fontSize*2)
        _msgHighScore.horizontalAlignmentMode = .center
        _msgHighScore.verticalAlignmentMode = .center
        self.addChild(_msgHighScore)
        
        _msgTitle = SKLabelNode(fontNamed: "Phosphate Solid")
        _msgTitle.fontSize = 24
        _msgTitle.fontColor = UIColor.white
        _msgTitle.position = CGPoint(x: size.width/2,
                                     y: size.height/2 + _msgDisp1.fontSize*2 + 12)
        _msgTitle.horizontalAlignmentMode = .center
        _msgTitle.verticalAlignmentMode = .center
        self.addChild(_msgTitle)
    }
    
    fileprivate func initGameStatusNodes(_ size: CGSize) {
        let scoreFont = UIFont(name: "Phosphate", size: 19)
        let fontAttributes = [NSAttributedString.Key.font: scoreFont!]
        let scoreMaxText = NSLocalizedString("SCORE - 99999", comment: "")
        let scoreMaxWidth =
            (scoreMaxText as NSString).size(withAttributes: fontAttributes).width
        
        // The x coordinate of the score display is calculated so that the
        // set of score and high score in roughly centered in the right
        // half of the screen - the reason for the 3.0/4.0 factor.
        _scoreHighScoreX = size.width*3.0/4.0 - scoreMaxWidth - 2.5
        // When only the score is visible - the player is not connected to
        // GameCenter or still doesn't have a high score.
        _scoreX = _scoreHighScoreX + scoreMaxWidth/2.0
        
        _scoreDisp = SKLabelNode(fontNamed: "Phosphate Solid")
        _scoreDisp.fontSize = 19
        _scoreDisp.position =
            CGPoint(x: _scoreX,
                    y: size.height - CourtScene.TOP_BOTTOM_INSET)
        _scoreDisp.horizontalAlignmentMode = .left
        _scoreDisp.verticalAlignmentMode = .top
        self.addChild(_scoreDisp)
        
        _highScoreDisp = SKLabelNode(fontNamed: "Phosphate Solid")
        _highScoreDisp.fontSize = 19
        _highScoreDisp.position =
            CGPoint(x: _scoreHighScoreX + scoreMaxWidth + 5.0,
                    y: size.height - CourtScene.TOP_BOTTOM_INSET)
        _highScoreDisp.horizontalAlignmentMode = .left
        _highScoreDisp.verticalAlignmentMode = .top
        self.addChild(_highScoreDisp)
               
        _discsDisp = SKLabelNode(fontNamed: "Phosphate Solid")
        _discsDisp.fontSize = 19
        _discsDisp.position = CGPoint(x: size.width/4,
                                      y: size.height - CourtScene.TOP_BOTTOM_INSET)
        _discsDisp.horizontalAlignmentMode = .center
        _discsDisp.verticalAlignmentMode = .top
        self.addChild(_discsDisp)
    }
    
    fileprivate func initPhysics(_ size: CGSize) {
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
        // Minimum velocity components proportional to scene size
        // Ratios defined from experimentation on an iPhone 5c (568x320 screen)
        _minDxSpeed = size.width * 0.92
        _minDySpeed = size.height * 0.25
        _curDxSpeed = _minDxSpeed
        _maxDxSpeed = _minDxSpeed * 2.0
        
        _leftLimit = _leftPad.position.x - _disc.size.width/2
        _rightLimit = _rightPad.position.x + _disc.size.width/2
        _leftLimitIn = _leftPad.position.x + _leftPad.size.width/2
        _rightLimitIn = _rightPad.position.x - _rightPad.size.width/2
    }
    
    fileprivate func initSoundFx() {
        // Sound effects initializations
        _discReleaseEffect =
            SKAction.playSoundFileNamed("DiscRelease.caf",
                                        waitForCompletion: false)
        _discHitEffect =
            SKAction.playSoundFileNamed("DiscHit.caf",
                                        waitForCompletion: false)
        _discGoneEffect =
            SKAction.playSoundFileNamed("DiscGone.wav",
                                        waitForCompletion: false)
        _newRecordEffect =
            SKAction.playSoundFileNamed("NewRecord.wav",
                                        waitForCompletion: false)
        _gameStartEffect =
            SKAction.playSoundFileNamed("GameStart.wav",
                                        waitForCompletion: false)
        _gameOverEffect =
            SKAction.playSoundFileNamed("GameOver.wav",
                                        waitForCompletion: false)
    }
    
    // MARK: - SKPhysicsContactDelegate

    private var _leftPadAtContactBegin: CGPoint?
    private var _rightPadAtContactBegin: CGPoint?

    func didBegin(_ contact:SKPhysicsContact) {
        guard state == .GameOngoing && _disc.position.x > _leftLimitIn &&
            _disc.position.x < _rightLimitIn
            else {
            // We're only interested in collisions while game is ongoing
            // and the disc in court
            return
        }
        let contactMask =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == DiscSprite.CollisionCateg | PadSprite.CollisionCateg {
            playSoundFx(_discHitEffect)
            _leftPadAtContactBegin = _leftPad.position
            _rightPadAtContactBegin = _rightPad.position
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard state == .GameOngoing && _disc.position.x > _leftLimitIn &&
            _disc.position.x < _rightLimit
            else {
            // We're only interested in collisions while game is ongoing
            // and the disc in court
            return
        }
        let contactMask =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == DiscSprite.CollisionCateg | PadSprite.CollisionCateg {
            let hitLeftPad =
                (self._disc.position.x < self.size.width/2)
            // If the hit pad moved between contact begin and contact end,
            // apply an Angular Impulse.
            if let leftAtBegin = _leftPadAtContactBegin,
               let rightAtBegin = _rightPadAtContactBegin {
                let padYDelta =
                    hitLeftPad ? _leftPad.position.y - leftAtBegin.y :
                    _rightPad.position.y - rightAtBegin.y
                _disc.physicsBody?.applyAngularImpulse(padYDelta * 0.0005)
            }
            // If a few milliseconds after hitting the pad the disc had it
            // horizontal velocity component reverted, it is still in game.
            Timer.scheduledTimer(
                withTimeInterval: 0.15,
                repeats: false,
                block: { timer in
                    // The disc speed accessment and adjustments must happen on
                    // the UI thread along with the SpriteKit update pipeline
                    // methods.
                    DispatchQueue.main.async {
                        if (hitLeftPad && self._disc.velocity.dx > 0.0) ||
                            (!hitLeftPad && self._disc.velocity.dx < 0.0) {
                            self._hitsInRally += 1
                            GameManager.shared.scoreBoard.increaseScore(by: 1)
                            if self._hitsInRally % 4 == 0 &&
                                self._curDxSpeed < self._maxDxSpeed {
                                // Periodically, on the number of hits in
                                // the rally, increase the minimal speed
                                // until it reaches the maximum.
                                self._curDxSpeed += self._minDxSpeed / 10
                            }
                        }
                    } // end of DispatchQueue.main.async
                }
            )
        }
    }
    
    // MARK: - Scene State handling
    
    func gotoInitialState() {
        _disc.reset()
        state = .WaitToStartMatch
        showToolNodes()
        playSoundFx(_gameStartEffect)
        GameManager.shared.startNewGame()
        GameManager.shared.updateHighScoresFromGameCenter()
    }
    
    private func updateSceneState() {
        switch _state {
        case .WaitToStartMatch:
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgTitle.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = GameManager.shared.scoreBoard.globalHighScore < 0
            resetPadsPositions()
            _leftPad.movable = false
            _rightPad.movable = false
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start game
                state = .LaunchingDisk
                hideToolNodes()
                let fadeOutMsg = SKAction.fadeOut(withDuration: 3.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                _leftPad.movable = true
                _rightPad.movable = true
                launchDisc()
            }
        case .LaunchingDisk:
            // Transient state - display timed message while
            // some actions are executed.
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = true
            _msgTitle.isHidden = true
        case .LostDisc:
            // Transient state - display timed message while
            // some actions are executed.
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = true
            _msgTitle.isHidden = true
        case .WaitToStartNewRally:
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = GameManager.shared.scoreBoard.globalHighScore < 0
            _msgTitle.isHidden = true
            resetPadsPositions()
            _leftPad.movable = false
            _rightPad.movable = false
            if _leftPad.isActive && _rightPad.isActive {
                // Both pads are being touched - start new rally.
                _leftPad.movable = true
                _rightPad.movable = true
                state = .LaunchingDisk
                hideToolNodes()
                let fadeOutMsg = SKAction.fadeOut(withDuration: 3.5)
                _msgDisp1.run(fadeOutMsg, withKey:"fadeOut")
                _msgDisp2.run(fadeOutMsg, withKey:"fadeOut")
                launchDisc()
            }
        case .GameOngoing:
            _disc.isHidden = false
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgDisp1.isHidden = true
            _msgDisp2.isHidden = true
            _msgTitle.isHidden = true
            _msgHighScore.isHidden = true
            _msgDisp1.removeAction(forKey: "fadeOut")
            _msgDisp2.removeAction(forKey: "fadeOut")
            _msgDisp1.alpha = 1.0
            _msgDisp2.alpha = 1.0
            if !_leftPad.isActive || !_rightPad.isActive {
                // Releasing any pad while match is ongoing, pauses it
                state = .GamePaused
                showToolNodes()
                _leftPad.movable = false
                _rightPad.movable = false
                _leftPad.isPaused = true
                _rightPad.isPaused = true
                _discsDisp.isPaused = true
                _discsDisp.fontColor = UIColor.darkGray
                _scoreDisp.isPaused = true
                _scoreDisp.fontColor = UIColor.darkGray
                _highScoreDisp.isPaused = true
                _highScoreDisp.fontColor = UIColor.darkGray
                _disc.pause()
            }
        case .GamePaused:
            _disc.isHidden = false
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgTitle.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = true
            if _leftPad.isActive && _rightPad.isActive {
                // Touching both pads while match is paused, resumes it.
                state = .GameOngoing
                hideToolNodes()
                _leftPad.movable = true
                _rightPad.movable = true
                _leftPad.isPaused = false
                _rightPad.isPaused = false
                _discsDisp.isPaused = false
                _discsDisp.fontColor = UIColor.white
                _scoreDisp.isPaused = false
                _scoreDisp.fontColor = UIColor.white
                _highScoreDisp.isPaused = false
                _highScoreDisp.fontColor = UIColor.white
                 _disc.resume()
            }
        case .MatchFinished, .MatchAborted,
             .MatchFinishedNewRecord, .MatchAbortedNewRecord:
            _disc.isHidden = true
            _discsDisp.isHidden = false
            _scoreDisp.isHidden = false
            _highScoreDisp.isHidden = GameManager.shared.scoreBoard.playerHighScore < 0
            _msgTitle.isHidden = false
            _msgDisp1.isHidden = false
            _msgDisp2.isHidden = false
            _msgHighScore.isHidden = true
        }
        
        if !_scoreDisp.isHidden {
            // Adjust the position of the score label depending on
            // the visibility of high-score label.
            _scoreDisp.position.x = _highScoreDisp.isHidden ? _scoreX : _scoreHighScoreX
        }
        
    }
    
    // MARK: - SKScene overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 3 &&
            (state == .GamePaused  || state == .WaitToStartNewRally) {
            // User chose to abort game
            self.alpha = 0.0
            let fadeInScene = SKAction.fadeIn(withDuration: 1.5)
            self.run(fadeInScene)
            if GameManager.shared.scoreBoard.isNewPlayerRecord {
                GameManager.shared.registerNewRecord() {
                    GameManager.shared.updateHighScoresFromGameCenter()
                }
                playSoundFx(_newRecordEffect)
                state = .MatchAbortedNewRecord
                showToolNodes()
            }
            else {
                state = .MatchAborted
                showToolNodes()
            }
            // Restores the color of the text sprites that display the number
            // of discs and the scores. It may be grayed out if the abort came
            // from a paused game.
            self._discsDisp.fontColor = UIColor.white
            self._scoreDisp.fontColor = UIColor.white
            self._highScoreDisp.fontColor = UIColor.white
            
            Timer.scheduledTimer(withTimeInterval: 3.0,
                                 repeats: false,
                                 block: { timer in
                                    // Any scene state transition must happen
                                    // in the UI thread along with the rest of
                                    // the SpriteKit update pipeline.
                                    DispatchQueue.main.async {
                                        // TODO: remove the call to updateHighScoreFromGameCenter
                                        GameManager.shared.updateHighScoresFromGameCenter()
                                        self.gotoInitialState()
                                    }
            })
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateSceneState()

        if _disc.isActive {
            // Guarantees the mininal disc horizontal and vertical speeds
            // (avoid edge cases where the game would be too boring).
            // The ratio between the minimum Vx/Vy is the minimal disc slope.
            if abs(_disc.velocity.dx) < _curDxSpeed {
                _disc.velocity.dx =
                    (_disc.velocity.dx < 0 ? -_curDxSpeed : _curDxSpeed)
            }
            if abs(_disc.velocity.dy) < _minDySpeed {
                _disc.velocity.dy =
                    (_disc.velocity.dy < 0 ? -_minDySpeed : _minDySpeed)
            }
        }
    }
    
    override func didEvaluateActions() {
        if state == .GameOngoing {
            // Detects and processes disc loss
            if _disc.position.x - _disc.size.width/2 < _leftLimit || _disc.position.x + _disc.size.width/2 > _rightLimit {
                // Disc is completely to the left or to the right of the scene - player lost rally.
                playSoundFx(_discGoneEffect)
                _msgDisp1.alpha = 0.0
                _msgDisp2.alpha = 0.0
                let fadeInMsg = SKAction.fadeIn(withDuration: 0.5)
                _msgDisp1.run(fadeInMsg)
                _msgDisp2.run(fadeInMsg)
                if GameManager.shared.availableDiscs > 1 {
                    // There's at least one disc left; let user start
                    // a new rally
                    GameManager.shared.pickUpDisc()
                    state = .LostDisc
                    showToolNodes()
                    Timer.scheduledTimer(
                        withTimeInterval: 3.0,
                        repeats: false,
                        block: { timer in
                            // Any scene state transition must happen in the UI
                            // thread along with the rest of the SpriteKit
                            // update pipeline.
                            DispatchQueue.main.async {
                                self.state = .WaitToStartNewRally
                                self.showToolNodes()
                            }
                    })
                } else {
                    // Lost rally for the last disc.
                    if GameManager.shared.scoreBoard.isNewPlayerRecord {
                        state = .MatchFinishedNewRecord
                        showToolNodes()
                        GameManager.shared.registerNewRecord() {
                            GameManager.shared.updateHighScoresFromGameCenter()
                        }
                    } else {
                        state = .MatchFinished
                        showToolNodes()
                    }
                    // Play new record or game over effects a little bit
                    // delayed, so they can be distinguished from the sound
                    // of the last disc gone.
                    Timer.scheduledTimer(
                        withTimeInterval: 0.8,
                        repeats: false,
                        block: {timer in
                            DispatchQueue.main.async {
                                self.playSoundFx(
                                    GameManager.shared.scoreBoard.isNewPlayerRecord ?
                                    self._newRecordEffect : self._gameOverEffect
                                )
                            }
                        })
                    Timer.scheduledTimer(
                        withTimeInterval: 5.0,
                        repeats: false,
                        block: { timer in
                            // Any scene state transition must happen in the UI
                            // thread along with the rest of the SpriteKit
                            // update pipeline.
                            DispatchQueue.main.async {
                                if self.state == .MatchFinished || self.state == .MatchFinishedNewRecord {
                                    // TODO: remove this call to updateHighScoresFromGameCenter
                                    GameManager.shared.updateHighScoresFromGameCenter()
                                    self.gotoInitialState()
                                }
                            }
                        })
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        if _state != .GamePaused && _state != .LaunchingDisk && state != .LostDisc {
            // A score or high-score change is possible in the current court state
            _scoreDisp.text = scoreText()
            _highScoreDisp.text = highScoreText()
            _msgHighScore.text = globalHighScoreText()
        }
        if _state != .GameOngoing && _state != .GamePaused {
            // An update of the number of disks is possible in the current court state
            _discsDisp.text = discsText()
        }
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
        let leftLimit = _leftPad.size.width/2.0 + _leftPad.position.x + 20.0
        let rightLimit = self.size.width / 4.0
        var xStart =
            CGFloat.random(in: leftLimit...rightLimit)
        if fromRight {
            // When the disk is comming from right, the x is relative to
            // the scene right boundary.
            xStart = self.size.width - xStart
        }
        let initialPos =
            CGPoint(x: xStart,
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
                // Makes sure the disc launch happens in the UI thread (main
                // queue). All the SpriteKit update cycle methods run on the UI
                // thread, so this is a strong enough guarantee.
                DispatchQueue.main.async {
                    self.playSoundFx(self._discReleaseEffect)
                    self._discAppearance.alpha = 0.0
                    self._discAppearance.isHidden = true
                    self.state = CourtState.GameOngoing
                    self.hideToolNodes()
                    self._hitsInRally = 0
                    // At the start of the rally decreases the velocity to the
                    // minimal value.
                    self._curDxSpeed = self._minDxSpeed!
                    var xVelocity = self._curDxSpeed!
                    if fromRight {
                        xVelocity = -xVelocity
                    }
                    var yVelocity = CGFloat.random(in:-550.0...550.0)
                    // For the first launch, limit the disc trajectory angle to 30
                    // degrees.
                    if GameManager.shared.availableDiscs == GameManager.shared.totalDiscs {
                        let yVelocityAbsLimit = abs(xVelocity) * CourtScene.ARCTAN_30_DEG
                        if abs(yVelocity) > yVelocityAbsLimit {
                            let yFactor: CGFloat = (yVelocity < 0 ? -1.0 : 1.0)
                            yVelocity = sqrt(yVelocityAbsLimit*yVelocityAbsLimit) * yFactor
                        }
                    }
                    self._disc.position = initialPos
                    self._disc.velocity =
                        CGVector(dx: xVelocity, dy: yVelocity)
                } // DispatchQueue.main.async end
        })
    }
    
    private func scoreText() -> String {
        let fmtScore = String(format:"%04d",
                              GameManager.shared.scoreBoard.score)
        return String.localizedStringWithFormat(
            NSLocalizedString("SCORE - %@", comment: ""),
            fmtScore
        )
    }
    
    private func highScoreText() -> String {
        let fmtHighScore = String(format:"%04d",
                                  GameManager.shared.scoreBoard.playerHighScore)
        return String.localizedStringWithFormat(
            NSLocalizedString("HIGH - %@", comment: ""),
            fmtHighScore
        )
    }
    
    private func globalHighScoreText() -> String {
        guard !_msgHighScore.isHidden else { return "" }
        let fmtHighScore = String(format:"%04d",
                                  GameManager.shared.scoreBoard.globalHighScore)
        
        if GameManager.shared.scoreBoard.playerRank > 0 {
            // The player is already ranked - display global record and player rank
            let fmtRank = String("# \(GameManager.shared.scoreBoard.playerRank)")
            return String.localizedStringWithFormat(
                NSLocalizedString("GLOBAL HIGH RANK", comment: ""),
                                  fmtHighScore, fmtRank
            )
        } else {
            // The player is not ranked yet - display only the global record
            return String.localizedStringWithFormat(
                NSLocalizedString("GLOBAL HIGH", comment: ""),
                                  fmtHighScore
            )
        }
    }
    
    private func discsText() -> String {
        let adsks = GameManager.shared.availableDiscs
        var txt = ""
        switch adsks {
        case 1: txt = NSLocalizedString("LAST DISC", comment: "")
        default: txt =
            String.localizedStringWithFormat(
                NSLocalizedString("DISCS - %d", comment: ""),
                adsks
            )
        }
        return txt
    }
    
    private func playSoundFx(_ soundFx: SKAction)  {
        if !GameManager.shared.soundMuted {
            run(soundFx)
        }
    }
    
    private func hideToolNodes() {
        _soundOption.isHidden = true
        _leaderBoard.isHidden = true
        _themeOption.isHidden = true
        _gameInfo.isHidden = true
    }
    
    private func showToolNodes() {
        _soundOption.isHidden = false
        _leaderBoard.isHidden = false
        _themeOption.isHidden = false
        _gameInfo.isHidden = false
    }
    
    private func setMsgs() {
        switch _state {
        case .WaitToStartMatch:
            _msgTitle.text = NSLocalizedString("Let's Play !", comment: "")
            _msgDisp1.text = NSLocalizedString("To start a new match,", comment: "")
            _msgDisp2.text = NSLocalizedString("touch and hold both pads.", comment: "")
        case .MatchAborted:
            _msgTitle.text = NSLocalizedString("Game aborted", comment: "")
            _msgDisp1.text = NSLocalizedString("Hope to have you back soon !", comment: "")
            _msgDisp2.text = ""
        case .MatchAbortedNewRecord:
            _msgTitle.text = NSLocalizedString("A New Record !!", comment: "")
            _msgDisp1.text = NSLocalizedString("Game aborted, but congrats !", comment: "")
            _msgDisp2.text = ""
        case .MatchFinishedNewRecord:
            _msgTitle.text = NSLocalizedString("A New Record !!", comment: "")
            _msgDisp1.text = NSLocalizedString("Well done !!!", comment: "")
            _msgDisp2.text = ""
        case .MatchFinished:
            _msgTitle.text = NSLocalizedString("Game Over !", comment: "")
            _msgDisp1.text = NSLocalizedString("Go ahead and play again !!", comment: "")
            _msgDisp2.text = ""
        case .GamePaused:
            _msgTitle.text = NSLocalizedString("Game Paused", comment: "")
            _msgDisp1.text = NSLocalizedString("To resume, touch and hold both pads.", comment: "")
            _msgDisp2.text = NSLocalizedString("To abort, touch anywhere with 3 fingers.", comment: "")
        case .LaunchingDisk:
            _msgDisp1.text = NSLocalizedString("Get ready to play !", comment: "")
            _msgDisp2.text = NSLocalizedString("Releasing any pad pauses the game.", comment: "")
        case .LostDisc:
            var discTxt: String!
            let availDiscs = GameManager.shared.availableDiscs
            if availDiscs >= 2 {
                discTxt =
                    String.localizedStringWithFormat(
                        NSLocalizedString("You have %d discs left !", comment: ""),
                        availDiscs
                    )
            } else if availDiscs == 1 {
                discTxt =
                    NSLocalizedString("Make the most of your last disc !", comment: "")
            }
            // There's at least one rally left ...
            _msgDisp1.text = discTxt
            _msgDisp2.text = NSLocalizedString("Good luck !!", comment:"")
        case .WaitToStartNewRally:
            _msgDisp1.text = NSLocalizedString("Hold both pads to launch a new disc.", comment: "")
            _msgDisp2.text = NSLocalizedString("To abort, touch anywhere with 3 fingers.", comment: "")
        case .GameOngoing:
            _msgDisp1.text = ""
            _msgDisp2.text = ""
        }
    }

}
