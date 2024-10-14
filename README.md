Overall
- [ ] Use the A-series motion controls whenever possible.
- [ ] Use proper coding techniques and naming conventions for objective-C or Swift.
- [ ] Interface Design - Proper use of interface elements, auto layout, and landscape portrait views. (1pt)
- [ ] Proper Coding Techniques - MVC adhered to, navigation, commenting of code, etc. (2pt)
- [ ] Module A: Steps - Proper display (and calculation) of steps taken thus far today (updates as one walks) and the total steps taken on the previous day. These should match with the Apple Health app numbers. (2pt)
- [ ] Module A: Steps - This should use persistent memory such that when the app is closed the goal from previous setting is taken into account. (1pt)
- [ ] Module A: Realtime Steps and Activity - Display the steps in real time and the current activity. Interface should update properly from the main queue. (1.5pt)
- [ ] Module B: SpriteKit Object Created and Sensors Accessed - A sprite should be created that responds to motion of the phone. Sensors should be properly accessed using core motion.
- [ ] Module B: Physics used in Game Properly (1pt)
- [ ] Module B: Collisions - Collisions in the game are implemented properly and cause some kind of reaction. (1pt)
- [ ] Use the steps of a user as some type of "currency" in the game to incentivize movement during the day (1pt)

Module A
- [ ] Display the number of steps a user has walked today and display the number of steps a user walked yesterday
- [ ] Displays a realtime count of the number of steps a user has taken today (this could be the same label as "number of steps today")
- [ ] Displays the number of steps until the user reaches a (user settable) daily goal
- [ ] The step goal should be saved persistently so that it is remembered even when the app restarts
- [ ] Displays the current activity of the user: {unknown, still, walking, running, cycling, driving}
- [ ] Use a highly visual interface for displaying the information

Module B
- [ ] Create a simple game that the user can play whenever they meet their step goal for the previous day
- [ ] Use {acceleration, gyro, magnetometer, AND/OR fused motion} to control some part of the physics of a SpriteKit (or SceneKit) game.
- [ ] Use two or more SpriteKit (or SceneKit) Nodes with dynamic physics
- [ ] Incorporate Collision detection through delegation
- [ ] Use the steps of a user as some type of "currency" in the game to incentivize movement during the day
