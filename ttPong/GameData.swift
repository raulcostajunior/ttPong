//
//  GameState.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation

// TODO: remove the states below - only for ref; some will have their own scenes
//GameStates {
//    case WaitingForStart (scene1)
//    case Starting (scene1)
//    case Running (scene1)
//    case Paused (scene1)
//    case Aborted (scene2)
//    case FinishedNewRecord (scene3)
//    case Finished (scene4 - or scene3 if they don't differ much)
//    case DisplayingRecords (scene5 - show know where to go to after leaving)
//    case DisplayingHelp (scene6 - show know where to go to after leaving)
//}

class GameOptions {
    var soundMuted = false
    
    // Should use accelerometer reading to influence disc trajectory?
    var useAccelerometer = false
}

/**
 Single repository for game data required by multiple scenes.
 */
class GameData {
    
    static let shared = GameData()
    
    var options = GameOptions()
    
    // TODO: add ScoreBoard instance. ScoreBoard should be a new class,
    //       accessible from here and expose a Save method. The rest of the
    //       game should access the ScoreBoard through GameData. ScoreBoard
    //       may be a temporary class - it may not survive a future GameCenter
    //       integration.
    
    private init() {
        // TODO: load game options and ScoreBoard
    }
    
    deinit {
        // TODO: save game options and ScoreBoard
    }
}
