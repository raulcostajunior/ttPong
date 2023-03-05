//
//  SoundOptionSprite.swift
//  ttPong
//
//  Created by Raul Costa Junior on 06.07.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import SpriteKit

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
        
        _muted = GameManager.shared.soundMuted
        texture = (_muted ? _mutedTexture : _nonMutedTexture)

        isUserInteractionEnabled = true
    }
    
    private var _muted: Bool!
    private var _mutedTexture: SKTexture!
    private var _nonMutedTexture: SKTexture!
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _muted = !_muted
        GameManager.shared.soundMuted = _muted
        texture = (_muted ? _mutedTexture : _nonMutedTexture)
        super.touchesEnded(touches, with: event)
    }

}
