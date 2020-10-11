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
                highScore:
                    Int64(UserDefaults.standard.integer(forKey: "HighScore")),
                setAt:
                    UserDefaults.standard.object(forKey: "HighScoreDate") != nil ?
                    UserDefaults.standard.object(forKey: "HighScoreDate") as! Date :
                    Date())
    }


    // MARK: - Options and Score Management

    private static let TOTAL_DISCS = 4

    // The Leader Board ID defined in iTunesConnect
    private static let LEADER_BOARD_ID = "board.normal"

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

    func registerNewRecord() {
        guard _scoreBoard.isNewRecord else {
            print("Error: there's no new record to register.")
            return
        }
        if gameCenterSessionActive {
            // TODO: register score with GameCenter
            let reportedScore =
                GKScore(leaderboardIdentifier: GameManager.LEADER_BOARD_ID)
            reportedScore.value = _scoreBoard.highScore
            GKScore.report([reportedScore]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            }
        }
        // Always registers high score locally as a fall-back for when no
        // GameCenter integration is available.
        UserDefaults.standard.set(_scoreBoard.highScore,
                                  forKey: "HighScore")
        UserDefaults.standard.set(_scoreBoard.highScoreDate,
                                  forKey: "HighScoreDate")
    }


    // MARK: - Game Navigation

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
        initGameCenterIntegration()

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

    func displayRecords() {
        let rootVc =
            UIApplication.shared.windows.first!.rootViewController!
        if self.gameCenterSessionActive {
            var vc: GKGameCenterViewController!
            if #available(iOS 14.0, *) {
                // For iOS 14 or later, the GameCenter view controller allows
                // specifying the player scope.
                vc = GKGameCenterViewController(
                    leaderboardID: GameManager.LEADER_BOARD_ID,
                    playerScope: .global,
                    timeScope: .allTime)
            } else {
                vc = GKGameCenterViewController()
                vc.leaderboardIdentifier = GameManager.LEADER_BOARD_ID
                vc.leaderboardTimeScope = .allTime
            }
            vc.gameCenterDelegate = self
            //show leader board in UI thread
            DispatchQueue.main.async {
                rootVc.present(vc,
                               animated: true, completion: nil)
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
            dateFormatter.timeZone = TimeZone.current
            let highScoreStamp =
                dateFormatter.string(from: _scoreBoard.highScoreDate)
            var messageBody: String
            if _scoreBoard.highScore > 0 {
                messageBody =
                    "Registered at '\(highScoreStamp)'.\n\nTo enable the " +
                    "Global Score Board, please sign in to GameCenter in " +
                    "Settings > GameCenter."
            } else {
                messageBody =
                    "\nTo enable the " +
                    "Global Score Board, please sign in to GameCenter in " +
                    "Settings > GameCenter."
            }
            let alert =
                UIAlertController(
                    title: "High Score: \(_scoreBoard.highScore) points",
                    message: messageBody,
                    preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: nil))
            rootVc.present(alert, animated: true)
        }
    }

    func displayAboutInfo() {
        let appVersion =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as?
               String
        var messageBody =
            appVersion != nil ? "Version \(appVersion!)\n" : ""
        messageBody += "Author: Raul Costa Junior, 2020.\n\n" +
                       "Please consider writing a review."
        let alert =
            UIAlertController(
            title: "About ttPong",
                message: messageBody,
                preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "Write a review", style: .default,
                          handler: { action in
                            self.openReviewUrl()
                          }))
        let rootVc =
            UIApplication.shared.windows.first!.rootViewController!
        rootVc.present(alert, animated: true)
    }


    // MARK: - Helpers
    fileprivate func openReviewUrl() {
        let appID = "1535019034"
        let urlStr =
            "https://itunes.apple.com/app/id\(appID)?action=write-review"

        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }


    // MARK: - GameCenter Integration

    private var _gameCenterSessionActive = false
    private var _localPlayer: GKLocalPlayer!
    private var _previousPlayerID: String?

    // Is there a live session with GameCenter for the
    // local player?
    var gameCenterSessionActive: Bool { _gameCenterSessionActive }

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
            }
        }
    }

    func updateHighScoreFromGameCenter() {
        guard _gameCenterSessionActive else { return }

        let gkLeaderboard = GKLeaderboard()
        gkLeaderboard.identifier = GameManager.LEADER_BOARD_ID
        gkLeaderboard.timeScope = .allTime
        gkLeaderboard.playerScope = .global
        gkLeaderboard.range = NSMakeRange(1, 3)

        // Load the scores - it is important that the High-Score update happens
        // in the UI thread so it is synchronized with any changes coming from
        // the game loop.
        gkLeaderboard.loadScores(
            completionHandler: { (boardScores, error) -> Void in
                if let scores = boardScores, error == nil {
                    if (scores.count) > 0 {
                        DispatchQueue.main.async {
                            self._scoreBoard.highScoreFromGlobal(
                                scores[0].value,
                                setAt: scores[0].date)
                            if self._scoreBoard.highScore == scores[0].value {
                                // The high score has been updated; update the
                                // local fall-back persistence.
                                UserDefaults.standard.set(
                                    self._scoreBoard.highScore,
                                    forKey: "HighScore")
                                UserDefaults.standard.set(
                                    self._scoreBoard.highScoreDate,
                                    forKey: "HighScoreDate")
                            }
                        }
                    }
                }
            })
    }


    // MARK: - GKGameCenterControllerDelegate Protocol

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

}
