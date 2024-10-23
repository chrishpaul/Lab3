//
//  GameViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/21/24.
//  Based on Commotion Bounce Game from CS7323 by Eric Larson
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    //MARK: - Variables
    var junkBudget:Int!     //Used to store game currency. Passed from calling vc.
    
    //MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup game scene
        let scene = GameScene(size: view.bounds.size)
        
        //Updates the game with currency from exceeding step goals
        scene.updateJunkBudgetTo(val: junkBudget)
        
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true // show some debugging of the FPS
        skView.showsNodeCount = true // show how many active objects are in the scene
        skView.ignoresSiblingOrder = true // don't track who entered scene first
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    // don't show the time and status bar at the top
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
