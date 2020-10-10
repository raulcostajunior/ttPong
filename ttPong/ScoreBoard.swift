//
//  ScoreBoard.swift
//  ttPong
//
//  Created by Raul Costa Junior on 14.06.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation

/**
 Game score board.

 For now, this does only contains the player's self assigned
 alias - just like old school arcade machines.
 */
    
class ScoreBoard {
    
    private var _score: Int64 = 0
    private var _highScore: Int64 = 0
    private var _highScoreDate: Date
    private var _newRecord = false
    
    var score:Int64 { return _score }
    var highScore:Int64 { return _highScore }
    var highScoreDate: Date { return _highScoreDate }
    var isNewRecord:Bool { return _newRecord }
    
    init(highScore: Int64, setAt: Date) {
        _score = 0
        _highScore = highScore
        _highScoreDate = setAt
        _newRecord = false
    }
    
    func increaseScore(by increment:Int64) {
        _score += increment
        if _score > _highScore {
            _newRecord = true
            _highScore = _score
            _highScoreDate = Date()
        }
    }
    
    func resetScore() {
        _score = 0
        _newRecord = false
    }

    func highScoreFromGlobal(_ globalRecord: Int64, setAt: Date) {
        if globalRecord > _score {
            // The global record is higher than the current score; even if
            // the current local High-Score is higher, it will be set because
            // we can't take any chance to allow the Global score to be
            // tampered from the unsafelly persisted local high score. If the
            // current score is higher than the global record, the user is on
            // his/her way to register a new record globally.
            _highScore = globalRecord
            _highScoreDate = setAt
            if _highScore >= _score {
                _newRecord = false
            }
        }
    }
    
}

