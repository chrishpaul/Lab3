//
//  StepGoalViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/18/24.
//

import UIKit

protocol StepGoalChangedDelegate {
    func stepGoalChangedTo(goal: Float, yesterday: Float) //Delegate function must update displayed goal
}

class StepGoalViewController: UIViewController {
    
    //let motionModel = MotionModel()
    var delegate : StepGoalChangedDelegate?
        //var day : String
    var currentGoal : Float?
    var yesterdayGoal : Float?

    @IBOutlet weak var stepGoalLabel: UILabel!
    @IBOutlet weak var stepGoalStepper: UIStepper!
    @IBOutlet weak var yesterdayGoalLabel: UILabel!
    @IBOutlet weak var yesterdayGoalStepper: UIStepper!
    override func viewDidLoad() {
        super.viewDidLoad()
        //stepGoalStepper.transform = stepGoalStepper.transform.scaledBy(x: 2, y: 1)
        if let goal = currentGoal,
           let yesterdayGoal = self.yesterdayGoal{
            //print(String(format: "Curren Goal: %.0f", goal))
            stepGoalLabel.text = String(format: "%.0f", goal)
            stepGoalStepper.value = Double(goal)
            yesterdayGoalLabel.text = String(format: "%.0f", yesterdayGoal)
            yesterdayGoalStepper.value = Double(yesterdayGoal)
        }
        

        // Do any additional setup after loading the view.
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func stepGoalChanged(_ sender: UIStepper) {
        self.stepGoalLabel.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func yesterdayGoalChanged(_ sender: UIStepper) {
        self.yesterdayGoalLabel.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func cancelChange(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func setGoal(_ sender: Any) {
        //self.motionModel.goal = Float(stepGoalStepper.value)
        delegate?.stepGoalChangedTo(goal: Float(stepGoalStepper.value), yesterday: Float(yesterdayGoalStepper.value));
        //delegate?.stepGoalChanged(to: Float(stepGoalStepper.value));
        dismiss(animated: true)
    }
}
