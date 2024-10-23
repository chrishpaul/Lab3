//
//  StepGoalViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/18/24.
//

import UIKit

// Protocol to be implemented by VC that calls this VC modally.
protocol StepGoalChangedDelegate {
    func stepGoalChangedTo(goal: Float, yesterday: Float) //Delegate function must update displayed goal
}

class StepGoalViewController: UIViewController {
    
    //MARK: - Variables
    // These are passed in from calling VC
    var delegate : StepGoalChangedDelegate?
    var currentGoal : Float?
    var yesterdayGoal : Float?

    //MARK: - Outlets
    @IBOutlet weak var stepGoalLabel: UILabel!
    @IBOutlet weak var stepGoalStepper: UIStepper!
    @IBOutlet weak var yesterdayGoalLabel: UILabel!
    @IBOutlet weak var yesterdayGoalStepper: UIStepper!
    
    //MARK: - View functions
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let goal = self.currentGoal,
           let yesterdayGoal = self.yesterdayGoal{
            // Configure display labels and steppers for goals
            stepGoalLabel.text = String(format: "%.0f", goal)
            stepGoalStepper.value = Double(goal)
            yesterdayGoalLabel.text = String(format: "%.0f", yesterdayGoal)
            yesterdayGoalStepper.value = Double(yesterdayGoal)
        }
    }
    
    // Handles changes to stepper value by updating display for today's goals
    @IBAction func stepGoalChanged(_ sender: UIStepper) {
        self.stepGoalLabel.text = String(format: "%.0f", sender.value)
    }
    
    // Handles changes to stepper value by updating display for yesterday's goals
    @IBAction func yesterdayGoalChanged(_ sender: UIStepper) {
        self.yesterdayGoalLabel.text = String(format: "%.0f", sender.value)
    }
    
    // Handles cancel action and returns to calling vc without making changes
    @IBAction func cancelChange(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // Calls handling function to update changes to step goals
    @IBAction func setGoal(_ sender: Any) {
        delegate?.stepGoalChangedTo(goal: Float(stepGoalStepper.value), yesterday: Float(yesterdayGoalStepper.value));
        dismiss(animated: true)
    }
}
