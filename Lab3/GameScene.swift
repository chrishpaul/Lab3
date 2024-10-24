//
//  GameScene.swift
//  Lab3
//
//  Created by Chrishnika Paul on 10/21/24.
//  Referenced video tutorial at https://www.youtube.com/watch?v=cJy61bOqQpg
//  Referenced GameScene code from CS7323 by Eric Larson

import UIKit
import SpriteKit
import CoreMotion
import GameKit

//Enum representing collision categories and masks
enum CollisionTypes: UInt32 {
    case player = 1
    case healthFood = 2
    case junkFood = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Variables
    private let motion = CMMotionManager()
    
    private var xAcceleration:CGFloat = 0       //Acceleration value for game along x axis
    private var accelerationFactor: CGFloat = 40    //Factor controling impact of acceleration on player movement
    private var accelerometerUpdateInterval = 0.1   //How often to get accelerometer updates
    
    var player:SKSpriteNode!        //Sprite to represent player
    var background = SKSpriteNode(imageNamed: "park3")      //Background sprite
    
    private let probabilityJunk = 0.7       //Probability of penalty (vs. reward) sprite generation
    
    // Array used to represent reward sprite image names
    var healthFoods = ["avocado",
                       "walnuts",
                       "lettuce",
                       "strawberries",
                       "carrots",
                       "salmon",
                       "watermelon"]
    
    // Array used to represent penalty sprite image names
    var junkFoods = ["soda", 
                     "fries",
                     "hotdog",
                     "pizza",
                     "friedchicken"]
    var foodFallRate = 6.0      // Duration for which reward and penalty sprites spend crossing screen

    
    // Node to display score
    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    //Update display when score value changes
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    var junkBudget:Int?     //Total amount of lives used as currency in game
    // Node to display lives remaining (junk points left)
    let junkLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    // Update display when number of lives left changes
    var junk:Int = 10 {
        willSet(newValue){
            DispatchQueue.main.async {
                self.junkLabel.text = "Junk Food Budget: \(newValue)"
            }
        }
    }
    
    var gameTimer:Timer!        //Timer to control rewards and penalty sprite generation
    
    //MARK: - Game set up functions
    override func didMove(to view: SKView) {
        
        //Configure and add park background
        addBackground()
        
        //Add picnic basket (player) node
        addPlayerNode()
        
        //Set accelerometer update interval and start updates
        motion.accelerometerUpdateInterval = self.accelerometerUpdateInterval
        motion.startAccelerometerUpdates(to: OperationQueue.current!){(data: CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                
                // if no errors, calculate player acceleration along x axis as weighted sum of prev player acceleration and new data
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x)*0.75 + self.xAcceleration * 0.25
            }
        }
        
        // Set gravity to zero
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        // Set self as delegate to be notified of contact between sprites
        self.physicsWorld.contactDelegate = self
        
        // Add a scorer
        self.addScore()
        
        // Add a lives remaining count
        self.addJunkBudget()
        
        // Set up timer to repeatedly generate reward and penalty sprites
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addFood), userInfo: nil, repeats: true)
    }
    
    func addBackground(){
        //Configure and add park background
        background.size = CGSize(width: size.width, height: size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func addPlayerNode(){
        //Configure and add player (picnic basket) node
        player = SKSpriteNode(imageNamed: "basket")
        player.name = "player"
        player.size = CGSize(width: size.width*0.2, height: size.height*0.1)
        player.position = CGPoint(x: size.width / 2, y: player.size.height/2 + 30)
        
        //Set up physics body
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        
        //Set category mask based on enum value for player category
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        
        //Set mask to notify on collisions with both penalty and reward sprites
        player.physicsBody?.contactTestBitMask = CollisionTypes.healthFood.rawValue | CollisionTypes.junkFood.rawValue
        
        //Do not sinulate physics of collsions for this sprite
        player.physicsBody?.collisionBitMask = 0
        
        self.addChild(player)
    }
    
    func addScore(){
        // Create score label
        
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.white
        
        // place score in middle of screen horizontally, and a littel below the maximum vertical
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 70)
        scoreLabel.fontSize = 36
        addChild(scoreLabel)
        self.score = 0          //Initialize to 0, which will update scoreLabel node's text
    }
    
    func addJunkBudget(){
        // Create lives remaining label
        
        junkLabel.fontSize = 20
        junkLabel.fontColor = SKColor.white
        
        // place score in middle of screen horizontally, and a littel below the maximum vertical
        junkLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 110)
        junkLabel.fontSize = 24
        addChild(junkLabel)
        self.junk = junkBudget!     //Initialize to the calculated currency based on steps above goal
    }
    
    func createFoodSprite(foodArray : [String])->SKSpriteNode{
        // Creates a food sprite of a given type based on list of image names passed in
        
        // Shuffle the list to choose one at random
        let foods = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: foodArray) as! [String]
        let foodSprite = SKSpriteNode(imageNamed: foods[0])
        foodSprite.name = "foodSprite"      //Name the sprite to allow removing it at end of game
        // Scale the sprite image to a fixed size
        foodSprite.size = CGSize(width: size.width*0.15, height: size.height*0.1)
        
        // Use random number to randomly change the x coordinate of the sprites starting position
        let randNumber = CGFloat.random(in: 0.1...0.9)
        foodSprite.position = CGPoint(x: size.width*randNumber, y: size.height + foodSprite.size.height)
        
        // Set up the sprite's physics body
        foodSprite.physicsBody = SKPhysicsBody(rectangleOf: foodSprite.size)
        foodSprite.physicsBody?.isDynamic = true
        // Set contact notifications for collisions with player's sprite
        foodSprite.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        foodSprite.physicsBody?.collisionBitMask = 0
        
        return foodSprite
    }
    
    @objc func addFood(){
        //Generate reward or penalty sprite on a timed basis with fixed probability of either type
        
        //let probabilityJunk = 0.8
        var foodSprite : SKSpriteNode
        
        // Choose a random number used to generate either penalty or reward with some probability
        let randNum = Double.random(in: 0...1)
        if randNum < probabilityJunk {
            // Create penalty sprite
            foodSprite = createFoodSprite(foodArray: junkFoods)
            
            // Set category mask for penalty
            foodSprite.physicsBody?.categoryBitMask = CollisionTypes.junkFood.rawValue
            
        } else {
            // Create reward sprite
            foodSprite = createFoodSprite(foodArray: healthFoods)
            
            // Set category mask for reward
            foodSprite.physicsBody?.categoryBitMask = CollisionTypes.healthFood.rawValue
        }
        
        self.addChild(foodSprite)
        
        //Create array of actions to perform to move sprite across screen and then remove
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: foodSprite.position.x, y: -foodSprite.size.height), duration: foodFallRate))
        actionArray.append(SKAction.removeFromParent())
        
        // Run sprite actions
        foodSprite.run(SKAction.sequence(actionArray))
    }
    
    func updateJunkBudgetTo(val : Int){
        // Set number of lives based on currency passed from calling VC
        junkBudget = val
    }
    
    //MARK: - Gameplay logic functions
    
    func ateHealthyFood(food: SKSpriteNode) {
        // Run when player and reward sprite contact
        
        // Play reward sound
        self.run(SKAction.playSoundFileNamed("munch.mp3", waitForCompletion: false))
        
        // Remove reward sprite
        food.removeFromParent()
        
        // Increment score
        score += 1
    }
    
    func ateJunkFood(food: SKSpriteNode){
        // Run when player and penalty sprite contact
        
        // Play penalty sound
        self.run(SKAction.playSoundFileNamed("yuck.mp3", waitForCompletion: false))
        
        // Remove penalty sprite
        food.removeFromParent()
        
        // Decrease lives remaining
        junk -= 1
        
        // If out of lives run end of game function
        if junk == 0 {
            endGame()
        }
    }
    
    func endGame(){
        // Runs when no lives remain
        
        // Stop timer that generates reward and penalty sprites
        gameTimer.invalidate()
        
        // Freeze player by zeroing accelration factor
        accelerationFactor = 0
        
        // Remove all nodes with name "foodSprite"
        self.enumerateChildNodes(withName: "foodSprite") { (node, stop) in
            node.removeFromParent()
        }
        
        // Remove running score and lives labels
        scoreLabel.removeFromParent()
        junkLabel.removeFromParent()
        
        // Create game over label
        let gameOver = SKLabelNode(text: "Picnic's Over!")
        gameOver.fontName = "MarkerFelt-Wide"
        gameOver.fontSize = 48
        gameOver.fontColor = .systemPink
        gameOver.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 300)
        addChild(gameOver)
        
        // Create final score label
        let finalScore = SKLabelNode(text: "Final Score \(score)")
        finalScore.fontName = "MarkerFelt-Thin"
        finalScore.fontSize = 36
        finalScore.fontColor = .black
        finalScore.position = CGPoint(x: frame.size.width / 2, y: frame.height - 350)
        addChild(finalScore)
    }
    
    //MARK: - Physics functions
    override func didSimulatePhysics() {
        // Change the players x position based on a calculated acceleration factor along x axis
        player.position.x += xAcceleration * accelerationFactor
        
        // Wrap the player sprite around the screen if it goes off either edge
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        } else if player.position.x > self.size.width + 20{
            player.position = CGPoint(x: -20, y: player.position.y)
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Handler for contact notifications
        
        //Decrease the time a sprite takes to cross screen after each contact
        foodFallRate = foodFallRate*0.95
        
        var food: SKPhysicsBody
        
        // Determine which body in contact is the food sprite and which is the player...
        //  the player has the smaller value mask
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            food = contact.bodyB
        } else {
            food = contact.bodyA
        }
        
        // Determine if the food sprite was a penalty or reward based on category mask
        if (food.categoryBitMask & CollisionTypes.junkFood.rawValue) != 0 {
            // call function to handle penalty contact
            ateJunkFood(food: food.node as! SKSpriteNode)
        } else if (food.categoryBitMask & CollisionTypes.healthFood.rawValue) != 0 {
            // call function to handle reward contact
            ateHealthyFood(food: food.node as! SKSpriteNode)
        }
    }
}
