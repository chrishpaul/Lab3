//
//  StartGameViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/22/24.
//

import UIKit

class StartGameViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var extraStepsLabel: UILabel!
    @IBOutlet weak var dailyBaseLabel: UILabel!
    @IBOutlet weak var stepBonusLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    
    //MARK: - Variables and properties
    let dailyBase = 10                  //Base currency available in game
    let stepsPerBonus : Float = 200.0   //Factor to calculate currency of bonus steps
    var extraSteps : Float!             //Set in prep for segue from pedometer VC
    var totalBudget = 10                //Initialize total currency
    
    //MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()

        //Calculate game currency from extra steps walked in previous day
        setCurrencyLabels()
    }
    
    func setBackgroundImage(){
        //Set up background image to match game scene
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "park3")
        backgroundImageView.contentMode = .scaleToFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    func setCurrencyLabels(){
        //Populate labels showing user how much currency their extra steps provide
        extraStepsLabel.text = String(format: "Steps above goal: %.0f", extraSteps)
        let stepBonus = Int(extraSteps / stepsPerBonus)
        self.totalBudget = stepBonus + dailyBase
        stepBonusLabel.text = String(format: "Step bonus: \(stepBonus)")
        dailyBaseLabel.text = String(format: "Daily base: \(dailyBase)")
        totalBudgetLabel.text = String(format: "Total budget: \(totalBudget)")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController{
            //Pass the total game currency to the game VC
            vc.junkBudget = totalBudget
        }
    }
    
    
    

}
