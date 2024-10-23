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
    // MARK: Variables
    let motionModel = MotionModel()
    var todayProgressView: StepProgressView?
    var yesterdayProgressView: StepProgressView?
    
    // MARK: View display functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.motionModel.delegate = self
        
        self.goalAchievedButton.isHidden = true
        
        //Set up activity monitoring and display
        self.activityImage.loadGif(name: "unknown")
        self.motionModel.startActivityMonitoring()
        
        //Set up step counting display for today
        todayProgressView = setupStepProgressView(center: view.center)
        showProgressFor(day: "today",
                        stepLabel: self.stepCountLabel,
                        goalButton: self.stepGoalButton,
                        progressView: todayProgressView!)
        
        //Set center of yesterday progress view below today's view
        let x = self.view.center.x
        let y = self.view.center.y + 225.0
        let center = CGPoint(x: x, y: y)
        
        //Set up step counting display for yesterday
        yesterdayProgressView = setupStepProgressView(center: center)
        showProgressFor(day: "yesterday",
                        stepLabel: self.stepsYesterdayLabel,
                        goalButton: self.yesterdayGoalButton,
                        progressView: yesterdayProgressView!)
        
        //Start pedometer
        self.motionModel.startPedometerMonitoring()
        
    }
    
    func setupStepProgressView(center: CGPoint)->StepProgressView {
        // set view
        let progressView = StepProgressView(frame: .zero)
        progressView.center = center
        view.addSubview(progressView)
        return progressView
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
            
            
            if day == "today" {
                let stepsRemaining = goal - steps
                self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
            }
        }
    }
}

extension ViewController : StepGoalChangedDelegate{
    func stepGoalChangedTo(goal: Float, yesterday: Float) {
        //self.motionModel.updateStepGoal(goal: goal)
        self.motionModel.updateStepGoalFor(day: "today", goal: goal)
        self.motionModel.updateStepGoalFor(day: "yesterday", goal: yesterday)
        //print(String(format: "Step goal changed to %.0f", goal))
        DispatchQueue.main.async {
            self.stepGoalButton.setTitle(String(format: "%.0f", goal), for: .normal)
            let steps = self.motionModel.getStepCountFor(day: "today")
            var endProgress = steps / goal
            self.todayProgressView!.progressAnimation(from: 0, to: endProgress)
            
            self.yesterdayGoalButton.setTitle(String(format: "%.0f", yesterday), for: .normal)
            let stepsYesterday = self.motionModel.getStepCountFor(day: "yesterday")
            endProgress = stepsYesterday / yesterday
            self.yesterdayProgressView?.progressAnimation(from: 0, to: endProgress)
            
            if stepsYesterday / yesterday > 1.0 {
                self.goalAchievedButton.isHidden = false
            } else {
                self.goalAchievedButton.isHidden = true
            }
            
            let stepsRemaining = goal - steps
            self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
        }
    }
}

extension ViewController: MotionDelegate{
    func yesterdayUpdated() {
        showProgressFor(day: "yesterday", 
                        stepLabel: self.stepsYesterdayLabel,
                        goalButton: self.yesterdayGoalButton,
                        progressView: self.yesterdayProgressView!)
        
        let steps = motionModel.getStepCountFor(day: "yesterday")
        let goal = motionModel.getStepGoalFor(day: "yesterday")
        if steps / goal > 1.0 {
            DispatchQueue.main.async {
                self.goalAchievedButton.isHidden = false
            }
        }
    }
    
    // MARK: =====Motion Delegate Methods=====
    
    func activityUpdated(activity:CMMotionActivity){
        
        //self.activityLabel.text = "🚶: \(activity.walking), 🏃: \(activity.running)"
        print(activity.description)
        
        if(activity.walking){
            self.activityImage.loadGif(name: "walking")
        } else if(activity.running){
            self.activityImage.loadGif(name: "running")
        } else if(activity.automotive){
            self.activityImage.loadGif(name: "driving")
        } else if(activity.stationary){
            self.activityImage.image = UIImage(named: "still.jpg")
        } else if(activity.unknown){
            self.activityImage.loadGif(name: "unknown")
        }
    }
    
    func pedometerUpdated(pedData:CMPedometerData){

        // display the output directly on the phone
        DispatchQueue.main.async {
            // this goes into the large gray area on view
            self.stepCountLabel.text = pedData.numberOfSteps.stringValue
            let goal = self.motionModel.getStepGoal()
            
            let steps = pedData.numberOfSteps.floatValue
            let stepsRemaining = goal - steps
            
            self.stepsRemainingLabel.text = String(format: "Steps Remaining: %.0f", stepsRemaining)
            
            let endProgress = steps / goal
            
            let lastStepCount = self.motionModel.getStepCountFor(day: "today")
            //let startProgress = self.motionModel.lastCount / goal
            let startProgress = lastStepCount / goal
            self.todayProgressView!.progressAnimation(from: startProgress, to: endProgress)
            self.motionModel.setLastStepCountTo(steps: steps)
            //self.motionModel.lastCount = pedData.numberOfSteps.floatValue
            print(pedData.numberOfSteps.intValue)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StepGoalViewController{
            vc.delegate = self
            //vc.day = "today"
            //let goal = self.motionModel.getStepGoal()
            vc.currentGoal = self.motionModel.getStepGoal()
            vc.yesterdayGoal = self.motionModel.getStepGoalFor(day: "yesterday")
        } else if let vc = segue.destination as? StartGameViewController{
            let steps = self.motionModel.getStepCountFor(day: "yesterday")
            let goal = self.motionModel.getStepGoalFor(day: "yesterday")
            vc.extraSteps = steps - goal
        }
        
    }
}

