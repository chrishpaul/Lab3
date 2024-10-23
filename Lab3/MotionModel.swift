//
//  MotionModel.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/14/24.
//  Based on MotionModel.swift by Eric Cooper Larson on 10/2/24. Copyright © 2024 Eric Larson. All rights reserved.
//

import Foundation
import CoreMotion

// setup a protocol for the ViewController to be delegate for
protocol MotionDelegate {
    // Define delegate functions
    func activityUpdated(activity:CMMotionActivity)
    func pedometerUpdated(pedData:CMPedometerData)
    func yesterdayUpdated()
}

class MotionModel{
    
    // MARK: =====Class Variables=====
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    //User settable step goal persisited in UserDefaults
    //private var goal:Float = 1000.0
    private var lastStepCount:Float = 0.0
    private var yesterdayStepCount:Float?
    
    var delegate:MotionDelegate? = nil
    
    func setLastStepCountTo(steps : Float){
        self.lastStepCount = steps
    }
    func setYesterdayStepCountTo(steps : Float){
        self.yesterdayStepCount = steps
    }
    func getStepCountFor(day : String) -> Float{
        if day == "today" {
            return self.lastStepCount
        } else if day == "yesterday" {
            if let steps = self.yesterdayStepCount{
                return steps
            } else {
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                let startOfDay = Calendar.current.startOfDay(for: yesterday!)
                let endOfDay = Calendar.current.startOfDay(for: Date())
                pedometer.queryPedometerData(from: startOfDay, to: endOfDay){
                    (pedData:CMPedometerData?, error:Error?)->Void in
                        
                        // if no errors, update the delegate
                    if let unwrappedPedData = pedData,
                       let delegate = self.delegate {
                        self.yesterdayStepCount = unwrappedPedData.numberOfSteps.floatValue
                        delegate.yesterdayUpdated()
                    }
                }
                return self.yesterdayStepCount ?? 0.0
                
            }
        } else {
            return 0.0
        }
    }
    
    func updateStepGoal(goal : Float){
        //self.goal = goal
        let defaults = UserDefaults.standard
        defaults.set(goal, forKey: "todayStepGoal")
    }
    
    func updateStepGoalFor(day: String, goal : Float){
        let defaults = UserDefaults.standard
        let key = day + "StepGoal"
        defaults.set(goal, forKey: key)
    }
    
    func getStepGoal() -> Float{
        let defaults = UserDefaults.standard
        if let stepGoal = defaults.object(forKey: "todayStepGoal") as? Float{
            return stepGoal
        }else{
            updateStepGoal(goal: 5000)
            return 5000
        }
    }
    
    func getStepGoalFor(day: String) -> Float{
        let key = day + "StepGoal"
        let defaults = UserDefaults.standard
        if let stepGoal = defaults.object(forKey: key) as? Float{
            return stepGoal
        }else{
            updateStepGoalFor(day: day, goal: 5000)
            return 5000
        }
    }
    
    /*
    func getYesterdayStepGoal() -> Float{
        let defaults = UserDefaults.standard
        if let yesterdayStepGoal = defaults.object(forKey: "YesterdayStepGoal") as? Float{
            return yesterdayStepGoal
        }else{
            //updateYesterdayStepGoal(goal: 5000)
            return 5000
        }
    }*/

    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and send to delegate
                // using the real time pedometer might influences how often we get activity updates...
                // so these updates can come through less often than we may want
                if let unwrappedActivity = activity,
                   let delegate = self.delegate {
                    // Print if we are walking or running
                    print("%@",unwrappedActivity.description)
                    
                    // Call delegate function
                    delegate.activityUpdated(activity: unwrappedActivity)
                    
                }
            }
        }
        
    }
    
    func startPedometerMonitoring(){
        print(Date())
        let startOfDay = Calendar.current.startOfDay(for: Date())
        //var today = Date()
        print(startOfDay)
        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable(){
            // start updating the pedometer from the current date and time
            //pedometer.startUpdates(from: Date())
            pedometer.startUpdates(from: startOfDay)
            {(pedData:CMPedometerData?, error:Error?)->Void in
                
                // if no errors, update the delegate
                if let unwrappedPedData = pedData,
                   let delegate = self.delegate {
                    
                    delegate.pedometerUpdated(pedData:unwrappedPedData)
                }

            }
        }
    }
    

    
    
}

