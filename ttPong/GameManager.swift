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
    
    private static let TOTAL_DISCS = 4
    
    private let _dataStore = DataStore()
    private var _scoreBoard: ScoreBoard
    private var _availableDiscs = GameManager.TOTAL_DISCS
    
    var options: Options
    
    var scoreBoard: ScoreBoard {
        return _scoreBoard
    }
    
    private init() {
        self.options = _dataStore.loadOptions()
        _scoreBoard = _dataStore.loadScoreBoard()
    }
    
    deinit {
        _dataStore.saveOptions(self.options)
        _dataStore.saveScoreBoard(self.scoreBoard)
    }
    
    var availableDiscs: Int {
        return _availableDiscs;
    }
    
    func pickUpDisc() {
        guard _availableDiscs > 0 else {
            print("@pickUpDisc -> will return false")
            return
        }
        _availableDiscs -= 1
    }
    
    private var _currentScene: SKScene?
    
    func presentGame(on view: SKView) {
        guard _currentScene == nil else {
            print("Error: there should be not current scene when calling 'presentGame'.")
            print("       'presentGame' should be called only at the begin of the game lifecycle.")
            return;
        }
        _currentScene = CourtScene(size:view.bounds.size)
        _currentScene?.scaleMode = .aspectFill
        view.presentScene(_currentScene)
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
    

    func navigateToNewRecord() {
        guard let currentScene = _currentScene,
                  currentScene is CourtScene else {
                    print("Error: the current scene is expected to be of type 'CourtScene'")
                    return
        }
        let newRecordScene = NewRecordScene()
        if let currentScene = _currentScene {
            let trans = SKTransition.fade(withDuration:1.5)
            currentScene.view?.presentScene(newRecordScene,
                                            transition: trans)
            _currentScene = newRecordScene
        }
    }
    
    func navigateToInstructions() {
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

}
