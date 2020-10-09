//
//  GameManager.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

/**
 * Responsabilities:
 *
 *  + Interface with GameCenter for LeaderBoard management.
 *  + Abstracts interscene transition knowledge from the individual scenes (by
 *  providing higher level methods like presentGame, registerNewRecord,
 *  displayHelp, displayScoreBoard ...
 */
class GameManager: NSObject, GKGameCenterControllerDelegate {

    // MARK: - Singleton support

    static let shared = GameManager()

    override private init() {
        _soundMuted = UserDefaults.standard.bool(forKey: "SoundMuted")
        // For now, the score board is initialized with the locally persisted
        // (and anonymous) high-score. After the connection to GameCenter is
        // established and a local player is known, the global high-score will
        // be retrieved. From there on, the high-score will always be updated
        // from GameCenter whenever it is possible.
        _scoreBoard =
            ScoreBoard(
                highScore: UserDefaults.standard.integer(forKey: "HighScore"))
    }


    // MARK: - Options and Score Management

    private static let TOTAL_DISCS = 4

    private var _scoreBoard: ScoreBoard
    private var _availableDiscs = GameManager.TOTAL_DISCS

    private var _soundMuted: Bool

    var scoreBoard: ScoreBoard {
        return _scoreBoard
    }

    var soundMuted: Bool {
        get { _soundMuted }
        set {
            _soundMuted = newValue
            UserDefaults.standard.set(_soundMuted, forKey: "SoundMuted")
        }
    }
    
    var availableDiscs: Int {
        return _availableDiscs
    }
    
    var totalDiscs: Int {
        return GameManager.TOTAL_DISCS
    }
    
    func pickUpDisc() {
        guard _availableDiscs > 0 else {
            print("@pickUpDisc -> will return false")
            return
        }
        _availableDiscs -= 1
    }


    // MARK: - Scene Navigation

    private var _currentScene: SKScene?
    
    func presentGame(on view: SKView) {
        guard _currentScene == nil else {
            return;
        }
        _currentScene = CourtScene(size:view.bounds.size)
        _currentScene?.scaleMode = .aspectFill
        view.presentScene(_currentScene)
        // initGameCenterIntegration is not called directly from the private
        // initializer because it depends on a defined RootViewController being
        // defined for the application. Calling it from here, where there's a
        // SKView already constructed is a guarantee that a RootViewController
        // has already been defined.
        if (gameCenterIntegrationEnabled) {
            initGameCenterIntegration()
        }
        startNewGame()
    }
    
    func startNewGame() {
        guard let currentScene = _currentScene,
                  currentScene is CourtScene else {
                    print("Error: the current scene is expected to be of type 'CourtScene'")
                    return
        }
        _availableDiscs = GameManager.TOTAL_DISCS;
        _scoreBoard.resetScore()
    }

    func registerNewRecord() {
        guard _scoreBoard.isNewRecord else {
            print("Error: there's no new record to register.")
            return
        }
        UserDefaults.standard.set(_scoreBoard.highScore, forKey: "HighScore")
    }

    func displayRecords() {
        if self.gameCenterSessionActive {
            // TODO: display leaderboard
        } else {
            // TODO: display message stating that leaderboard requires
            //       GameCenter integration and allow user to enable
            //       GameCenter integration.
        }
    }
    
    func navigateToAboutGameScene() {
        guard let currentScene = _currentScene,
                  currentScene is CourtScene else {
                    print("Error: the current scene is expected to be of type 'CourtScene'")
                    return
        }
        // TODO: Save the current court for later restoring.
    }
    
    func goBackToCourt() {
        guard let currentScene = _currentScene,
                  !(currentScene is CourtScene) else {
                    print("Error: the current scene cannot be of type 'CourtScene'")
                    return
        }
        // TODO: Restore the court scene if there's a court scene to be restored.
        //       Otherwise, creates a fresh CourtScene
    }


    // MARK: - GameCenter Integration

    private var _gameCenterSessionActive = false
    private var _localPlayer: GKLocalPlayer!
    private var _previousPlayerID: String?
    private var _gameCenterIntegrationEnabled =
    UserDefaults.standard.object(
        forKey: "GameCenterIntegrationEnabled") != nil ?
        UserDefaults.standard.bool(forKey: "GameCenterIntegrationEnabled") :
        true

    // Is there a live session with GameCenter for the
    // local player?
    var gameCenterSessionActive: Bool { _gameCenterSessionActive }

    // Is GameCenter integration enabled? (if not, no attempt will be made
    // to establish a session for the local player).
    var gameCenterIntegrationEnabled: Bool {
        get { _gameCenterIntegrationEnabled }
        set {
            if !_gameCenterIntegrationEnabled && newValue {
                // Integration was disabled and is being enabled.
                // Initialize the connection
                initGameCenterIntegration()
            } else if gameCenterIntegrationEnabled && !newValue {
                // Integration is being disabled
                clearGameCenterIntegration()
            }
            _gameCenterIntegrationEnabled = newValue
            UserDefaults.standard.set(newValue,
                                      forKey: "GameCenterIntegrationEnabled")
        }
    }

    func clearGameCenterIntegration() {
        _localPlayer.authenticateHandler = nil
        _localPlayer = nil
    }

    func initGameCenterIntegration() {
        _localPlayer = GKLocalPlayer.local

        _localPlayer.authenticateHandler = { (vc, error) -> Void in
            if vc != nil {
                let rootVc =
                    UIApplication.shared.windows.first!.rootViewController!
                //show game center sign in controller
                DispatchQueue.main.async {
                    rootVc.present(vc!,
                                   animated: true, completion: nil)
                }
                return
            }
            if (self._localPlayer.isAuthenticated) {
                //user has succesfully logged in
                self._gameCenterSessionActive = true
                if let previousPlayerID = self._previousPlayerID,
                    previousPlayerID != self._previousPlayerID {
                    // TODO: Present message stating that logged GameCenter
                    // player changed and that game will be restarted.
                    self.startNewGame()
                }
                self._previousPlayerID = self._localPlayer.playerID
                self.updateHighScoreFromGameCenter()
            } else {
                //game center is disabled on the device
                self._gameCenterSessionActive = false
                self._previousPlayerID = nil
                // TODO:
                // Present message stating that high-scores won't be registered
                // when there's no GameCenter user logged in. This message
                // should present two options: OK, OK and Disable Game Center.
                // The integration should be re-enabable from a message box
                // that is displayed when the user tries to see the leaderboard
                // with the GameCenter integration disabled at the CourtScene.
            }
        }
    }

    func updateHighScoreFromGameCenter() {
        guard _gameCenterSessionActive else { return }

        // TODO: Get High Score from GameCenter - this method should
        //       use ScoreBoard.UpdateHighScore in the UI thread when it receives
        //       a high score and this updated high score is greater than the
        //       current high-score.
    }


    // MARK: - GKGameCenterControllerDelegate Protocol

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

}
