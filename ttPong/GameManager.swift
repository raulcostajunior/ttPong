//
//  GameManager.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation
import SpriteKit


/**
 * Responsabilities:
 *
 *  + Access-point to the Game Data Store (this has the scoreboard and the options) single scoreboard
 *  + Instructs the Game Data Store to load and save data (life-cycle manager)
 *  + Abstract interscene transition knowledge from the individual scenes (by
 *  providing higher level methods like presentGame, registerNewRecord,
 *  displayHelp, displayScoreBoard ...
 */
class GameManager {
    
    static let shared = GameManager()
    
    private let dataStore = DataStore()
    
    var options: Options
    
    var scoreBoard: ScoreBoard
    
    // TODO: add ScoreBoard instance. ScoreBoard should be a new class,
    //       accessible from here and expose a Save method. The rest of the
    //       game should access the ScoreBoard through GameData. ScoreBoard
    //       may be a temporary class - it may not survive a future GameCenter
    //       integration.
    
    private init() {
        self.options = dataStore.loadOptions()
        self.scoreBoard = dataStore.loadScoreBoard()
    }
    
    deinit {
        dataStore.saveOptions(self.options)
        dataStore.saveScoreBoard(self.scoreBoard)
    }
    
    private var _currentScene: SKScene?
    
    func presentGame(on view: SKView) {
        guard _currentScene == nil else {
            return;
        }
        _currentScene = CourtScene(size:view.bounds.size)
        _currentScene?.scaleMode = .aspectFill
        view.presentScene(_currentScene)
    }
    
    // TODO: Add another scene transition methods
    func registerNewRecord() {
        let newRecordScene = NewRecordScene()
        if let currentScene = _currentScene {
            let trans = SKTransition.fade(withDuration:1.5)
            currentScene.view?.presentScene(newRecordScene,
                                            transition: trans)
            _currentScene = newRecordScene
        }
    }
    

}
