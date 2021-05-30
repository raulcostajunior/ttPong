//
//  GameManager.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

// import CloudKit
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

        _currentScene = CourtScene(size:view.bounds.size)
        _currentScene?.scaleMode = .aspectFill
        view.presentScene(_currentScene)
        
        // getiCloudUserID()
        
        // initGameCenterIntegration is not called directly from the private
        // initializer because it depends on a defined RootViewController being
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
        let rootVc =
            UIApplication.shared.windows.first!.rootViewController!
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
        var messageBody =
            appVersion != nil ?
            String.localizedStringWithFormat(
                NSLocalizedString("Version %@\n", comment: ""), appVersion!
            ) : ""
        messageBody +=
            NSLocalizedString("Author: Raul Costa Junior, 2020.\n\n", comment: "")
            +
            NSLocalizedString("Please consider writing a review.", comment: "")
        let alert =
            UIAlertController(
                title: NSLocalizedString("About ttPong", comment: ""),
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
    
    // MARK: - CloudKit Integration
//    private var _gameUserID: String?
//    private var _gameUserEmail: String?
//
//    func getiCloudUserID() {
//
//        /* Solution based on iCloud Key-Value store - to see how the key/value can be shared among different
//           apps from the same team - this could be used for instance to share a gamer alias and Avatar among
//           multiple games, see https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW26
//        */
//        if NSUbiquitousKeyValueStore.default.synchronize() {
//            if let uuidStr = NSUbiquitousKeyValueStore.default.string(forKey: "ttPongUserID") {
//                // It is not the first time the current iCloud user has accessed the game.
//                self._gameUserID = uuidStr
//            } else {
//                let uuid = NSUUID()
//                NSUbiquitousKeyValueStore.default.set(uuid.uuidString, forKey: "ttPongUserID")
//                NSUbiquitousKeyValueStore.default.synchronize()
//                self._gameUserID = uuid.uuidString
//            }
//        } else {
//            // An error occurred during synchronization
//            print("Error during iCloud Key-Value Store synchronization!")
//        }
        
        
        /* Solution based on iCloudKit Container - if any additional user information, like e-mail, is needed;
           didn't manage to retrieve the e-mail. */
//        CKContainer(identifier: GameManager.ICLOUD_KIT_CONTAINER).fetchUserRecordID(completionHandler: {
//            (recordID, error) in
//            if let recID = recordID {
//                // ID could be successfully retrieved
//                self._gameUserID = recID.recordName
//                print("iCloud user ID = \(recID.recordName)")
//                self._gameUserRecord = recID
//                self.getiCloudUserEmail()
//            } else if error != nil {
//                print("Error trying to retrieve iCloud user ID:")
//                print(error.debugDescription)
//            }
//        })
//    }
  
    /* getiCloudUserEmail was commented out because it didn't work to retrieve the e-mail, even when the user grants the
       required permission. */
//    func getiCloudUserEmail() {
//        if let gameUserRec = self._gameUserRecord {
//            let container = CKContainer(identifier: GameManager.ICLOUD_KIT_CONTAINER)
//            container.requestApplicationPermission(.userDiscoverability, completionHandler: {(status, error) in
//                if status == .granted {
//                    container.discoverUserIdentity(withUserRecordID: gameUserRec, completionHandler: { (userID, error) in
//                        self._gameUserEmail = userID?.lookupInfo?.emailAddress
//                    })
//                }
//                // One possibility, if the gamer denies access to his/her e-mail would be to ask for an alias.
//                // Or maybe fail completely if the user doesn't allow the e-mail address to be retrieved.
//
//            })
//        }
//    }


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
                    // player changed and that game will be restarted. (v 2.0)
                    self.startNewGame()
                }
                self._previousPlayerID = self._localPlayer.playerID
                self.updateHighScoresFromGameCenter()
            } else {
                //game center is disabled on the device
                self._gameCenterSessionActive = false
                self._previousPlayerID = nil
            }
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
                       if score.player.playerID == self?._localPlayer.playerID {
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
