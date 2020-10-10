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
    private var _newRecord = false
    
    var score:Int64 { return _score }
    var highScore:Int64 { return _highScore }
    var isNewRecord:Bool { return _newRecord }
    
    init(highScore: Int64) {
        _score = 0
        _highScore = highScore
        _newRecord = false
    }
    
    func increaseScore(by increment:Int64) {
        _score += increment
        if _score > _highScore {
            _newRecord = true
            _highScore = _score
        }
    }
    
    func resetScore() {
        _score = 0
        _newRecord = false
    }

    func updateHighScore(_ newRecord: Int64) {
        if newRecord > _highScore {
            _highScore = newRecord
            if _highScore >= _score {
                _newRecord = false
            }
        }
    }
    
}

