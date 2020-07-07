//
//  SoundOptionSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 06.07.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

// TODO: Handle touch event
class SoundOptionSprite: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(texture: nil,
                   color: UIColor.clear,
                   size: CGSize(width:40, height:40))
        let mutedImg = UIImage(named: "speaker.slash")
        _mutedTexture = SKTexture.init(image: mutedImg!)
        
        let nonMutedImg = UIImage(named:"speaker.2")
        _nonMutedTexture = SKTexture.init(image: nonMutedImg!)
        
        texture = _nonMutedTexture
    }
    
    private var _muted = false
    
    private var _mutedTexture: SKTexture!
    private var _nonMutedTexture: SKTexture!
    
    var isMuted: Bool {
        get {
            _muted
        }
        set {
            _muted = newValue
            texture = _muted ? _mutedTexture : _nonMutedTexture
        }
    }

}
