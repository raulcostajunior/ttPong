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
    
struct ScoreBoard {
    
    private var _score = 0
    private var _highScore = 0
    
    var score:Int { return _score }
    var highScore:Int { return _highScore }
    
    var scoreLabel: String {
        let fmtScore = String(format:"%04d", _score)
        return "SCORE  \(fmtScore)"
    }
    
    var highScoreLabel: String {
        let fmtScore = String(format:"%04d", _highScore)
        return "RECORD  \(fmtScore)"
    }
    
    init(highScore: Int) {
        _score = 0
        _highScore = highScore
    }
    
    mutating func increaseScore(by increment:Int) {
        _score += increment
        if _score > _highScore {
            _highScore = _score
        }
    }
    
}

