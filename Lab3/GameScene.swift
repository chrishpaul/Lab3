//
//  GameScene.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/21/24.
//  Referenced video tutorial at https://www.youtube.com/watch?v=cJy61bOqQpg

import UIKit
import SpriteKit
import CoreMotion
import GameKit

enum CollisionTypes: UInt32 {
    case player = 1
    case healthFood = 2
    case junkFood = 4
    //case allFood = 6
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let motion = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var accelerationFactor: CGFloat = 40
    
    var player:SKSpriteNode!
    var background = SKSpriteNode(imageNamed: "park3")
    var healthFoods = ["avocado", "walnuts", "lettuce", "strawberries", "carrots", "salmon", "watermelon"]
    var junkFoods = ["soda", "fries", "hotdog", "pizza", "friedchicken"]
    var foodFallRate = 6.0
    
    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    let junkLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    var junkBudget:Int?
    var junk:Int = 10 {
        willSet(newValue){
            DispatchQueue.main.async {
                self.junkLabel.text = "Junk Food Budget: \(newValue)"
            }
        }
    }
    
    var gameTimer:Timer!
    
    override func didMove(to view: SKView) {
        //Configure and add park background
        background.size = CGSize(width: size.width, height: size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        //Add picnic basket node
        player = SKSpriteNode(imageNamed: "basket")
        player.name = "player"
        player.size = CGSize(width: size.width*0.2, height: size.height*0.1)
        player.position = CGPoint(x: size.width / 2, y: player.size.height/2 + 30)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        //TODO: Change the category
        player.physicsBody?.contactTestBitMask = CollisionTypes.healthFood.rawValue | CollisionTypes.junkFood.rawValue
        player.physicsBody?.collisionBitMask = 0
        self.addChild(player)
        
        motion.accelerometerUpdateInterval = 0.2
        motion.startAccelerometerUpdates(to: OperationQueue.current!){(data: CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x)*0.75 + self.xAcceleration * 0.25
            }
        }
        
        //TODO: Why do we have this zero gravity?
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        // add a scorer
        self.addScore()
        self.addJunkBudget()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addFood), userInfo: nil, repeats: true)
    }
    
    @objc func addFood(){
        let randNum = Double.random(in: 0...1)
        let probabilityJunk = 0.8
        
        var foodSprite : SKSpriteNode
        if randNum < probabilityJunk {
            foodSprite = createFoodSprite(foodArray: junkFoods)
            foodSprite.physicsBody?.categoryBitMask = CollisionTypes.junkFood.rawValue
            
        } else {
            foodSprite = createFoodSprite(foodArray: healthFoods)
            foodSprite.physicsBody?.categoryBitMask = CollisionTypes.healthFood.rawValue
        }
        
        self.addChild(foodSprite)
        
        //let animationDuration:TimeInterval = 6
        var actionArray = [SKAction]()
        //actionArray.append(SKAction.move(to: CGPoint(x: foodSprite.position.x, y: -foodSprite.size.height), duration: animationDuration))
        actionArray.append(SKAction.move(to: CGPoint(x: foodSprite.position.x, y: -foodSprite.size.height), duration: foodFallRate))
        actionArray.append(SKAction.removeFromParent())
        
        foodSprite.run(SKAction.sequence(actionArray))
    }
    
    func updateJunkBudgetTo(val : Int){
        junkBudget = val
    }
    
    func createFoodSprite(foodArray : [String])->SKSpriteNode{
        let foods = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: foodArray) as! [String]
        let foodSprite = SKSpriteNode(imageNamed: foods[0])
        foodSprite.name = "foodSprite"
        
        let randNumber = CGFloat.random(in: 0.1...0.9)
        foodSprite.size = CGSize(width: size.width*0.15, height: size.height*0.1)
        foodSprite.position = CGPoint(x: size.width*randNumber, y: size.height + foodSprite.size.height)
        
        foodSprite.physicsBody = SKPhysicsBody(rectangleOf: foodSprite.size)
        foodSprite.physicsBody?.isDynamic = true
        foodSprite.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        foodSprite.physicsBody?.collisionBitMask = 0
        
        return foodSprite
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * accelerationFactor
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        } else if player.position.x > self.size.width + 20{
            player.position = CGPoint(x: -20, y: player.position.y)
            
        }
    }
    /*
    func addHealthyFood(){
        healthFoods = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: healthFoods) as! [String]
        let healthFood = SKSpriteNode(imageNamed: healthFoods[0])
        
        let randNumber = CGFloat.random(in: 0.1...0.9)
        //let randomSpritePosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width))
        healthFood.size = CGSize(width: size.width*0.15, height: size.height*0.1)
        healthFood.position = CGPoint(x: size.width*randNumber, y: size.height + healthFood.size.height)
        healthFood.physicsBody = SKPhysicsBody(rectangleOf: healthFood.size)
        healthFood.physicsBody?.isDynamic = true
        
        healthFood.physicsBody?.categoryBitMask = CollisionTypes.healthFood.rawValue
        //TODO: Change the category
        healthFood.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        healthFood.physicsBody?.collisionBitMask = 0
        
        self.addChild(healthFood)
        
        let animationDuration:TimeInterval = 6
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: healthFood.position.x, y: -healthFood.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        healthFood.run(SKAction.sequence(actionArray))
    }

    func addJunkFood(){
        junkFoods = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: healthFoods) as! [String]
        let healthFood = SKSpriteNode(imageNamed: healthFoods[0])
        
        let randNumber = CGFloat.random(in: 0.1...0.9)
        //let randomSpritePosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width))
        healthFood.size = CGSize(width: size.width*0.15, height: size.height*0.1)
        healthFood.position = CGPoint(x: size.width*randNumber, y: size.height + healthFood.size.height)
        healthFood.physicsBody = SKPhysicsBody(rectangleOf: healthFood.size)
        healthFood.physicsBody?.isDynamic = true
        
        healthFood.physicsBody?.categoryBitMask = CollisionTypes.healthFood.rawValue
        //TODO: Change the category
        healthFood.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        healthFood.physicsBody?.collisionBitMask = 0
        
        self.addChild(healthFood)
        
        let animationDuration:TimeInterval = 6
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: healthFood.position.x, y: -healthFood.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        healthFood.run(SKAction.sequence(actionArray))
    }*/
    
    func ateHealthyFood(food: SKSpriteNode) {
        self.run(SKAction.playSoundFileNamed("munch.mp3", waitForCompletion: false))
        food.removeFromParent()
        score += 1
    }
    
    func ateJunkFood(food: SKSpriteNode){
        self.run(SKAction.playSoundFileNamed("yuck.mp3", waitForCompletion: false))
        food.removeFromParent()
        junk -= 1
        
        if junk == 0 {
            endGame()
        }
    }
    
    func endGame(){
        gameTimer.invalidate()
        print("End of game")
        //self.childNode(withName: "player")?.physicsBody?.isDynamic = false
        accelerationFactor = 0
        self.enumerateChildNodes(withName: "foodSprite") { (node, stop) in
            node.removeFromParent()
        }
        
        scoreLabel.removeFromParent()
        junkLabel.removeFromParent()
        
        let gameOver = SKLabelNode(text: "Picnic's Over!")
        gameOver.fontName = "MarkerFelt-Wide"
        gameOver.fontSize = 48
        gameOver.fontColor = .systemPink
        gameOver.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 300)
        addChild(gameOver)
        
        let finalScore = SKLabelNode(text: "Final Score \(score)")
        finalScore.fontName = "MarkerFelt-Thin"
        finalScore.fontSize = 36
        finalScore.fontColor = .black
        finalScore.position = CGPoint(x: frame.size.width / 2, y: frame.height - 350)
        addChild(finalScore)
        
        
    }
    
    func addScore(){
        
        //scoreLabel.text = "Score: 0"
        //scoreLabel.name = "score"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.white
        // place score in middle of screen horizontally, and a littel above the minimum vertical
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 70)
        //scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        addChild(scoreLabel)
        self.score = 0
    }
    
    func addJunkBudget(){
        
        //junkLabel.text = "Junk Food Budget: \(self.junk)"
        junkLabel.fontSize = 20
        junkLabel.fontColor = SKColor.white
        // place score in middle of screen horizontally, and a littel above the minimum vertical
        junkLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 110)
        //scoreLabel.fontName = "AmericanTypewriter-Bold"
        junkLabel.fontSize = 24
        addChild(junkLabel)
        self.junk = junkBudget!
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        foodFallRate = foodFallRate*0.95
        var food: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            food = contact.bodyB
        } else {
            food = contact.bodyA
        }
        
        if (food.categoryBitMask & CollisionTypes.junkFood.rawValue) != 0 {
            ateJunkFood(food: food.node as! SKSpriteNode)
        } else if (food.categoryBitMask & CollisionTypes.healthFood.rawValue) != 0 {
            ateHealthyFood(food: food.node as! SKSpriteNode)
        }
    }
    /*
    func addBasket(){
        let spriteBasket = SKSpriteNode(imageNamed: "basket")
        spriteBasket.size = CGSize(width: size.width*0.1, height: size.height*0.1)
        spriteBasket.position = CGPoint(x: size.width / 2, y: spriteBasket.size.height/2 + 20)
        
        self.addChild(spriteBasket)
    }
    
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: ???, withHandler: self.handleMotion)
        }
    }
    
    func handleMotion(motionData: CMDeviceMotion?, error:NSError?){
        if let gravity = motionData?.gravity{
            self.physicsWorld.gravity = CGVectorMake(CGFloat(9.8*gravity.x), CGFloat(9.8*gravity.y))
        }
    }
*/
}
