//
//  DataStore.swift
//  ttPong
//
//  Created by Raul Costa Junior on 14.06.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation


/**
 Responsable for loading, storing and providing an access
 point for game data - at this point Score and Options.
 */
class DataStore {
    
    func loadOptions() -> Options {
        // TODO: add real body
        return Options()
    }
    
    func saveOptions(_ opt: Options) {
        // TODO: add real body
    }
    
    func loadScoreBoard() -> ScoreBoard {
        // TODO: add real body
        return ScoreBoard(highScore: 0);
    }
    
    func saveScoreBoard(_ sb: ScoreBoard) {
        // TODO: add real body
    }
    
}
