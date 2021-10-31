//
//  GameViewController.swift
//  ttPong
//
//  Created by Raul Costa Junior on 18.04.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
    
    var adjustedSafeArea = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *), let view = self.view, !adjustedSafeArea {
            view.frame = self.view.safeAreaLayoutGuide.layoutFrame
            adjustedSafeArea = true
        }
        guard let view = self.view as! SKView? else { return }
        view.ignoresSiblingOrder = true
//        view.showsFPS = true
//        view.showsNodeCount = true
//        view.showsPhysics = true
//        view.showsDrawCount = true
        GameManager.shared.presentGame(on:view)
    }
 
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
