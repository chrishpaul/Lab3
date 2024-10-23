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

    var junkBudget:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup game scene
        let scene = GameScene(size: view.bounds.size)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
