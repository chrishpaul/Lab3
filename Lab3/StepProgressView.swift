//
//  StepProgressView.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/14/24.
//  Referenced https://cemkazim.medium.com/how-to-create-animated-circular-progress-bar-in-swift-f86c4d22f74b
//

import UIKit

class StepProgressView: UIView {
//Class that implements custom progress bar
    
    //MARK: - Variables
    private var circleLayer = CAShapeLayer()            //Base curved bar
    private var progressLayer = CAShapeLayer()          //Progress curved bar
    private var startPoint = CGFloat(-5*Double.pi/4)    //Angle of start of curve
    private var endPoint = CGFloat(Double.pi / 4)       //Angle of end of curve
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createCircularPath()
    }
    
    func createCircularPath() {
        // Creates circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width, y: frame.size.height), radius: 100, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        
        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        
        // Configure appearance of base bar
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 15.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.systemGray3.cgColor
        
        // Add circleLayer to layer
        layer.addSublayer(circleLayer)
        
        // progressLayer path defined to circularPath of same shape as base path
        progressLayer.path = circularPath.cgPath
        
        // Configure appearance of progress bar
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 15.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.systemMint.cgColor
        
        // Add progressLayer to layer
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(from: Float, to: Float) {
        // Animates progess bar
        
        // Uses "strokeEnd" keyPath for animation
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.fromValue = from
        circularProgressAnimation.toValue = to
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
