//
//  MotionModel.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/14/24.
//  Based on MotionModel.swift by Eric Cooper Larson on 10/2/24. Copyright © 2024 Eric Larson. All rights reserved.
//

import Foundation
import CoreMotion

//MARK: - Protocol
// setup a protocol for the ViewController to be delegate for
protocol MotionDelegate {
    // Define delegate functions
    func activityUpdated(activity:CMMotionActivity)
    func pedometerUpdated(pedData:CMPedometerData)
    func yesterdayUpdated()     //Handler for when steps for yesterday are available
}

class MotionModel{
    
    // MARK: =====Class Variables=====
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    //User settable step goal persisited in UserDefaults
    private var lastStepCount:Float = 0.0       //Holds the data from the last pedometer update
    private var yesterdayStepCount:Float?       //Holds the number of steps from yesterday
    
    var delegate:MotionDelegate? = nil
    
    func setLastStepCountTo(steps : Float){
        self.lastStepCount = steps
    }
    func setYesterdayStepCountTo(steps : Float){
        self.yesterdayStepCount = steps
    }
    
    // MARK: - Getters
    func getStepCountFor(day : String) -> Float{
        // Gets the number of steps taken today or yesterday
        
        if day == "today" {
            // Return the number of steps as of the last pedometer update
            return self.lastStepCount
            
        } else if day == "yesterday" {
            if let steps = self.yesterdayStepCount{     //using lazy instantiation
                return steps
            } else {
                // Create date object for yesterday
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                // Get corresponding system start of day
                let startOfDay = Calendar.current.startOfDay(for: yesterday!)
                // End of yesterday is start of today
                let endOfDay = Calendar.current.startOfDay(for: Date())
                
                //Query pedometer for steps for yesterday
                pedometer.queryPedometerData(from: startOfDay, to: endOfDay){
                    (pedData:CMPedometerData?, error:Error?)->Void in
                        
                    // if no errors, update the delegate
                    if let unwrappedPedData = pedData,
                       let delegate = self.delegate {
                        // Set private variable for yesterday's steps
                        self.yesterdayStepCount = unwrappedPedData.numberOfSteps.floatValue
                        delegate.yesterdayUpdated()
                    }
                }
                return self.yesterdayStepCount ?? 0.0       //default value if errors
                
            }
        } else {
            return 0.0      //default value if day not today or yesterday
        }
    }
    
    func getStepGoal() -> Float{
        // Returns today's step goal stored in UserDefaults.standard
        
        getStepGoalFor(day: "today")
    }
    
    func getStepGoalFor(day: String) -> Float{
        // Returns current step goal stored in UserDefaults.standard
        // for day "today" or "yesterday"
        
        //Create key based on day passed in
        let key = day + "StepGoal"
        
        let defaults = UserDefaults.standard
        
        // If  key exists, return it.
        if let stepGoal = defaults.object(forKey: key) as? Float{
            return stepGoal
            
        }else{ //Else update UserDefaults with key and default value
            updateStepGoalFor(day: day, goal: 5000)
            return 5000                     //Default goal
        }
    }
    
    //MARK: - Setters
    
    func updateStepGoal(goal : Float){
        //Updates today's step goal
        updateStepGoalFor(day: "today", goal : goal)
    }
    
    func updateStepGoalFor(day: String, goal : Float){
        //Updates current step goals for "today" or "yesterday"
        let defaults = UserDefaults.standard
        
        //Create key using day
        let key = day + "StepGoal"
        defaults.set(goal, forKey: key)
    }
    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // start activity updates
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and send to delegate
                if let unwrappedActivity = activity,
                   let delegate = self.delegate {
                    // Call delegate function
                    delegate.activityUpdated(activity: unwrappedActivity)
                }
            }
        }
    }
    
    func startPedometerMonitoring(){
        // This is the computed start of day and matches the date used by my health app
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable(){
            // start updating the pedometer from the today's "start of day"
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

