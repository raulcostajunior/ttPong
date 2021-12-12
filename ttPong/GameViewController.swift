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
    
    var gamePresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = self.view as! SKView? else { return }
        view.ignoresSiblingOrder = true
//        view.showsFPS = true
//        view.showsNodeCount = true
//        view.showsPhysics = true
//        view.showsDrawCount = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let view = self.view as! SKView?, !gamePresented else { return }
        // SafeArea adjustments cannot be done at viewDidLoad (too early;
        // all the insets are zero, even for models that have a notch and no
        // home button).
        if #available(iOS 11.0, *) {
            view.frame = self.view.safeAreaLayoutGuide.layoutFrame
        }
        GameManager.shared.presentGame(on: view)
        gamePresented = true
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
