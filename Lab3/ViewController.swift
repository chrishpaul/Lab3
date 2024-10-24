//
//  ViewController.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/14/24.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var stepGoalButton: UIButton!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var yesterdayGoalButton: UIButton!
    @IBOutlet weak var stepsRemainingLabel: UILabel!
    @IBOutlet weak var goalAchievedButton: UIButton!
    @IBOutlet weak var todayProgressView: StepProgressView!
    @IBOutlet weak var yesterdayProgressView: StepProgressView!
    
    // MARK: Variables
    let motionModel = MotionModel()
    
    // MARK: View display functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.motionModel.delegate = self
        
        //Hide button to start game
        self.goalAchievedButton.isHidden = true
        
        //Set up activity monitoring and display
        self.activityImage.loadGif(name: "unknown")
        self.motionModel.startActivityMonitoring()
        
        //Set up step counting display for today and yesterday
        showProgressFor(day: "today",
                        stepLabel: self.stepCountLabel,
                        goalButton: self.stepGoalButton,
                        progressView: todayProgressView!)
        
        showProgressFor(day: "yesterday",
                        stepLabel: self.stepsYesterdayLabel,
                        goalButton: self.yesterdayGoalButton,
                        progressView: yesterdayProgressView!)
        
        //Start pedometer
        self.motionModel.startPedometerMonitoring()
    }
    
    func showProgressFor(day : String,
                         stepLabel: UILabel,
                         goalButton: UIButton,
                         progressView: StepProgressView){
        DispatchQueue.main.async {
            //Update step count label
            let steps = self.motionModel.getStepCountFor(day: day)
            stepLabel.text = String(format: "%.0f", steps)
            
            //Update step goal button
            let goal = self.motionModel.getStepGoalFor(day: day)
            goalButton.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
            goalButton.setTitle(String(format: "%.0f", goal), for: .normal)
            
            //Update progress bar
            let startProgress : Float = 0.0
            let endProgress = steps / goal
            progressView.progressAnimation(from: startProgress, to: endProgress)
            
            //Update steps remaining for today
            if day == "today" {
                let stepsRemaining = goal - steps
                self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
            }
        }
    }
}

extension ViewController : StepGoalChangedDelegate{
    
    // Function called when step goals are updated from StepGoalViewController
    func stepGoalChangedTo(goal: Float, yesterday: Float) {
        //Update step goals
        self.motionModel.updateStepGoalFor(day: "today", goal: goal)
        self.motionModel.updateStepGoalFor(day: "yesterday", goal: yesterday)
        DispatchQueue.main.async {
            
            //Recalculate progress and update display for today
            self.stepGoalButton.setTitle(String(format: "%.0f", goal), for: .normal)
            let steps = self.motionModel.getStepCountFor(day: "today")
            var endProgress = steps / goal
            self.todayProgressView!.progressAnimation(from: 0, to: endProgress)
            
            //Recalculate progress and update display for yesterday
            self.yesterdayGoalButton.setTitle(String(format: "%.0f", yesterday), for: .normal)
            let stepsYesterday = self.motionModel.getStepCountFor(day: "yesterday")
            endProgress = stepsYesterday / yesterday
            self.yesterdayProgressView?.progressAnimation(from: 0, to: endProgress)
            
            //Show or hide play game button depending on whether yesterday's goal was met
            if stepsYesterday / yesterday > 1.0 {
                self.goalAchievedButton.isHidden = false
            } else {
                self.goalAchievedButton.isHidden = true
            }
            
            //Update steps remaining button
            let stepsRemaining = goal - steps
            self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
        }
    }
}

// MARK: =====Motion Delegate Methods=====

extension ViewController: MotionDelegate{
    //Function Handler for when steps for yesterday are available
    func yesterdayUpdated() {
        //Update progress display for yesterday
        showProgressFor(day: "yesterday",
                        stepLabel: self.stepsYesterdayLabel,
                        goalButton: self.yesterdayGoalButton,
                        progressView: self.yesterdayProgressView!)
        
        //Calculate if yesterday's goal was met and show play game button accordingly
        let steps = motionModel.getStepCountFor(day: "yesterday")
        let goal = motionModel.getStepGoalFor(day: "yesterday")
        if steps / goal > 1.0 {
            DispatchQueue.main.async {
                self.goalAchievedButton.isHidden = false
            }
        }
    }
    
    func activityUpdated(activity:CMMotionActivity){
        //Handler for activity updates
        
        // Display gifs depending on activity returned by motion manager
        if(activity.walking){
            self.activityImage.loadGif(name: "walking")
        } else if(activity.running){
            self.activityImage.loadGif(name: "running")
        } else if (activity.cycling){
            self.activityImage.loadGif(name: "cycling")
        } else if(activity.automotive){
            self.activityImage.loadGif(name: "driving")
        } else if(activity.stationary){
            self.activityImage.image = UIImage(named: "still.jpg")
        } else if(activity.unknown){
            self.activityImage.loadGif(name: "unknown")
        }
    }
    
    func pedometerUpdated(pedData:CMPedometerData){
        //Handler for pedometer updates for today
        
        DispatchQueue.main.async {
            // Get steps from pedometer update and goal from stored value
            let steps = pedData.numberOfSteps.floatValue
            let goal = self.motionModel.getStepGoal()
            
            // Calculate steps remaining and update label
            let stepsRemaining = goal - steps
            self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
            
            //Update step count display
            self.stepCountLabel.text = String(format: "%.0f", steps)
            //self.stepCountLabel.text = pedData.numberOfSteps.stringValue
            
            //Calculate and display updated progress
            //  Number of steps since last update is used for incremental update
            let lastStepCount = self.motionModel.getStepCountFor(day: "today")
            let startProgress = lastStepCount / goal
            let endProgress = steps / goal
            self.todayProgressView!.progressAnimation(from: startProgress, to: endProgress)
            
            //Update motionModel with number of steps today as of this update
            self.motionModel.setLastStepCountTo(steps: steps)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StepGoalViewController{
            
            //Properties needed for step goal adjustment
            vc.delegate = self
            vc.currentGoal = self.motionModel.getStepGoal()
            vc.yesterdayGoal = self.motionModel.getStepGoalFor(day: "yesterday")
        } else if let vc = segue.destination as? StartGameViewController{
            
            //Calculation of extra steps to be used as currency in game
            let steps = self.motionModel.getStepCountFor(day: "yesterday")
            let goal = self.motionModel.getStepGoalFor(day: "yesterday")
            vc.extraSteps = steps - goal
        }
    }
}

