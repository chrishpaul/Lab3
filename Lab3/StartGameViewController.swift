//
//  StartGameViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/22/24.
//

import UIKit

class StartGameViewController: UIViewController {
    
    @IBOutlet weak var extraStepsLabel: UILabel!
    @IBOutlet weak var dailyBaseLabel: UILabel!
    var extraSteps : Float!
    let stepsPerItem : Float = 50.0
    var totalBudget  = 10
    @IBOutlet weak var stepBonusLabel: UILabel!
    
    @IBOutlet weak var totalBudgetLabel: UILabel!
    //@IBOutlet weak var backgroundImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let screenSize: CGRect = UIScreen.main.bounds
        
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "park3")
        //let backgroundImage = UIImage(named: "park3")
        
        //let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleToFill
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        extraStepsLabel.text = String(format: "Steps above goal: %.0f", extraSteps)
        let stepBonus = Int(extraSteps / stepsPerItem)
        let dailyBase = 10
        self.totalBudget = stepBonus + dailyBase
        stepBonusLabel.text = String(format: "Step bonus: \(stepBonus)")
        dailyBaseLabel.text = String(format: "Daily base: \(dailyBase)")
        totalBudgetLabel.text = String(format: "Total budget: \(totalBudget)")
        

        // Do any additional setup after loading the view.
    }
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? GameViewController{
            vc.junkBudget = totalBudget
        }
    }
    
    
    

}
