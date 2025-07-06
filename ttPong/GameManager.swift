//
//  GameManager.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

// import CloudKit
import Connectivity
import Foundation
import GameKit
import SpriteKit


class GameManager: NSObject, GKGameCenterControllerDelegate {

    // MARK: - Singleton support

    static let shared = GameManager()

    override private init() {
        _soundMuted = UserDefaults.standard.bool(forKey: "SoundMuted")
        _scoreBoard = ScoreBoard()
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
            print("@pickUpDisc -> there's no disc to be picked up - check the logic!")
            return
        }
        _availableDiscs -= 1
    }

    // MARK: - Game Navigation

    private var _currentScene: SKScene?
    
    func presentGame(on view: SKView) {
        guard _currentScene == nil else {
            return;
        }

        _currentScene = CourtScene(within: view)
        _currentScene?.scaleMode = .aspectFill
        view.presentScene(_currentScene)
        
        // getiCloudUserID()
        
        // initGameCenterIntegration is not called directly from the private
        // initializer because it depends on a RootViewController being
        // defined for the application. Calling it from here, where there's a
        // SKView already constructed is a guarantee that a RootViewController
        // has already been defined.
        initGameCenterIntegration()

        startNewGame()
    }
    
    func startNewGame() {
        _availableDiscs = GameManager.TOTAL_DISCS;
        _scoreBoard.resetScore()
    }

    func displayRecords() {
        var rootVc: UIViewController
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            rootVc = window!.rootViewController!
        } else {
            rootVc = UIApplication.shared.windows.first!.rootViewController!
        }
        if self.gameCenterSessionActive {
            var vc: GKGameCenterViewController!
            if #available(iOS 14.0, *) {
                // For iOS 14 or later, the GameCenter view controller allows
                // specifying the player scope.
                vc = GKGameCenterViewController(state: .leaderboards)
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
            let alert =
                UIAlertController(
                    title: NSLocalizedString("Score Board Disabled", comment: ""),
                    message: NSLocalizedString("To enable the Score Board", comment: ""),
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
        let titleStr =
            appVersion != nil ?
            String.localizedStringWithFormat(
                NSLocalizedString("About ttPong", comment: ""), appVersion!) :
            NSLocalizedString("About ttPong", comment: "")
        let messageBody = NSLocalizedString(
            "Author: Raul Costa Junior, 2020.\n\n", comment: "")

        let alert =
            UIAlertController(
                title: titleStr,
                message: messageBody,
                preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .cancel, handler: nil)
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Write a review", comment: ""),
                style: .default,
                handler: { action in
                    self.openReviewUrl()
                })
        )
        let rootVc =
            UIApplication.shared.windows.first!.rootViewController!
        rootVc.present(alert, animated: true)
    }
    
    func displayThemeSelection() {
        // TODO: Display actionSheet to allow for theme selection
    }
    
    // MARK: - GameCenter Integration
    
    // TODO: move GameCenterIntegration to its own class, GameCenterGateway,
    //       along with the three fields (private vars below) as public r.o.
    // TODO: move score related functionalities to ScoreBoard, which will have
    //       a LEADER_BOARD_ID as an initialization parameter. It will use the
    //       GameCenterGateway services to retrieve and update high scores. Add
    //       functionality to store records that couldn't be saved due to lack
    //       of connectivity and flush those records whenever the connectivity
    //       is restored in the lifetime of the hosting process.

    private let _connectivity = Connectivity()
    private var _gameCenterSessionActive = false
    private var _gameCenterDisabled = false
    private var _localPlayer: GKLocalPlayer!
    private var _previousPlayerID: String?

    // Is there a live session with GameCenter for the
    // local player?
    var gameCenterSessionActive: Bool {
        if !_gameCenterDisabled && !_gameCenterSessionActive {
            // There's no GameCenter session but the player hasn't denied
            // his/her intend to use GameCenter - if there's connectivity,
            // prompt the player to login to GameCenter again.
            _connectivity.checkConnectivity { conn in
                if conn.isConnectedViaCellular || conn.isConnectedViaWiFi {
                    self.initGameCenterIntegration()
                }
            }
        }
        return _gameCenterSessionActive
    }

    private var _gameCenterConnDelegate: GameCenterConnDelegate?

    func setGameCenterConnDelegate(_ delegate: GameCenterConnDelegate) {
        _gameCenterConnDelegate = delegate
    }

    func initGameCenterIntegration() {
        _localPlayer = GKLocalPlayer.local

        _localPlayer.authenticateHandler = { (vc, error) -> Void in
            if vc != nil {
                let rootVc =
                    UIApplication.shared.windows.first!.rootViewController!
                //show game center sign in controller
                DispatchQueue.main.async {
                    rootVc.present(vc!, animated: true, completion: nil)
                }
                return
            }
            if (self._localPlayer.isAuthenticated) {
                self._connectivity.checkConnectivity { conn in
                    if conn.isConnectedViaCellular || conn.isConnectedViaWiFi {
                        // There's both a logged GameCenter user and Internet
                        // connectivity.
                        self._gameCenterSessionActive = true
                        if let previousPlayerID = self._previousPlayerID,
                            previousPlayerID != self._previousPlayerID {
                            // GameCenter player changed
                            self._gameCenterConnDelegate?.GameCenterPlayerDisconnected(
                                playerId: self._previousPlayerID ?? "")
                            self.startNewGame()
                        }
                        self.updateHighScoresFromGameCenter()
                        self._gameCenterConnDelegate?.GameCenterPlayerConnected(
                            playerId: self._localPlayer.teamPlayerID)
                    }
                    self._previousPlayerID = self._localPlayer.teamPlayerID
                    self._gameCenterDisabled = false
                    // If there's no Internet connectivity, leave the next
                    // check for when gameCenterSessionActive is queried again;
                    // we avoid going into polling mode as that would increase
                    // battery usage.
                }
            } else {
                // User has not logged in GameCenter - register that in
                // _gameCenterDisabled so we don't keep bothering him/her.
                self._gameCenterDisabled = true
                self._gameCenterSessionActive = false
                self._previousPlayerID = nil
            }
        }
    }
    
    func resetGameCenterIntegration() {
        if self._gameCenterSessionActive {
            self._gameCenterSessionActive = false
            self._previousPlayerID = self._localPlayer.teamPlayerID
            self._gameCenterDisabled = false
            self._gameCenterConnDelegate?.GameCenterPlayerDisconnected(playerId: self._localPlayer.teamPlayerID)
        } else {
            // If there was no session active we just need to clear the
            // GameCenterDisabled status.
            self._gameCenterDisabled = false
        }
    }

    func updateHighScoresFromGameCenter() {
        guard _gameCenterSessionActive else { return }
        
        if #available(iOS 14.0, *) {
            self.updateHighScoresFromGameCenter_14_newer()
        } else {
            self.updateHighScoresFromGameCenter_older_14()
        }
    }
    
    fileprivate func updateHighScoresFromGameCenter_older_14() {
        var globalHighScore: Int64 = -1
        var playerHighScore: Int64 = -1
        var playerRank: Int64 = -1
        
        // Loads the global high score
        let globalLeaderBoard = GKLeaderboard()
        let highScoresGroup = DispatchGroup()
        globalLeaderBoard.identifier = GameManager.LEADER_BOARD_ID
        globalLeaderBoard.timeScope = .allTime
        globalLeaderBoard.playerScope = .global
        globalLeaderBoard.range = NSMakeRange(1,1)
        highScoresGroup.enter()
        globalLeaderBoard.loadScores(
            completionHandler: { (boardScores, error) -> Void in
                 if let scores = boardScores, error == nil {
                     if (scores.count) > 0 {
                         globalHighScore = scores[0].value
                     }
                    highScoresGroup.leave()
                 }
        })
         
        // Loads the player high score and rank.
        let playerLeaderBoard = GKLeaderboard(players: [self._localPlayer])
        playerLeaderBoard.identifier = GameManager.LEADER_BOARD_ID
        playerLeaderBoard.timeScope = .allTime
        playerLeaderBoard.range = NSMakeRange(1, 1)
        highScoresGroup.enter()
        playerLeaderBoard.loadScores(
            completionHandler: { [weak self] (boardScores, error) -> Void in
               if let scores = boardScores, error == nil {
                   for score in scores {
                       if score.player.teamPlayerID == self?._localPlayer.teamPlayerID {
                           playerHighScore = score.value
                           playerRank = Int64(score.rank)
                           break;
                       }
                   }
               }
               highScoresGroup.leave()
        })

        highScoresGroup.notify(queue: .main) {
            self._scoreBoard.setHighScores(playerHighScore: playerHighScore, globalHighScore: globalHighScore, playerRank: playerRank)
        }
    }

    @available(iOS 14.0, *)
    fileprivate func updateHighScoresFromGameCenter_14_newer() {
        var globalHighScore:Int64 = -1
        var playerHighScore:Int64 = -1
        var playerRank: Int64 = -1
        
        // Loads the LeaderBoard
        var leaderBoard: GKLeaderboard?
        // Loads the high score.
        GKLeaderboard.loadLeaderboards(IDs: [GameManager.LEADER_BOARD_ID]) { [weak self] (leaderBoards, error) in
            leaderBoard = leaderBoards?.first
            leaderBoard?.loadEntries(for: .global, timeScope: .allTime, range: NSMakeRange(1,10)) { [weak self] (localPlayerEntry, entries, numOfPlayers, err) in
                guard err == nil else { return }
                if let lPlayerEntry = localPlayerEntry {
                    playerHighScore = Int64(lPlayerEntry.score)
                    playerRank = Int64(lPlayerEntry.rank)
                }
                if let allPlayersEntries = entries, allPlayersEntries.count > 0 {
                    globalHighScore = Int64(allPlayersEntries[0].score)
                }
                DispatchQueue.main.async {
                    self?._scoreBoard.setHighScores(playerHighScore: playerHighScore, globalHighScore: globalHighScore, playerRank: playerRank)
                }
            }
        }
    }

    /**
      Registers a new record for the current player with the GameCenter.
     
      - Parameter onScoreRegistered: callback to be executed upon successful record registration.
     */
    func registerNewRecord(onScoreRegistered: @escaping () -> Void) {
        guard (_scoreBoard.isNewPlayerRecord) else {
            print("Error: there's no new record to register.")
            return
        }
        if gameCenterSessionActive {
            let reportedScore =
                GKScore(leaderboardIdentifier: GameManager.LEADER_BOARD_ID)
            reportedScore.value = _scoreBoard.playerHighScore
            GKScore.report([reportedScore]) {(error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    onScoreRegistered()
                }
            }
        }
    }


    // MARK: - GKGameCenterControllerDelegate Protocol

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }


    // MARK: - Private Helper Methods
    fileprivate func openReviewUrl() {
        let appID = "1535019034"
        let urlStr =
            "https://itunes.apple.com/app/id\(appID)?action=write-review"

        guard let url = URL(string: urlStr),
                  UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
