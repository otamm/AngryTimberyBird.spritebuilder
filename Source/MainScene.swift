import Foundation;

class MainScene: CCNode {
    /* linked objects */
    
    // the bird sprite
    weak var bird:CCSprite!;
    
    // first ground; first and second grounds will be rendered one after another to give the impression of movement.
    weak var ground1:CCSprite!;
    
    // second ground block.
    weak var ground2:CCSprite!;
    
    // the main physics node, every child of it are affected by physics.
    weak var gamePhysicsNode:CCPhysicsNode!;
    
    /* custom variables */
    
    // will keep track of how much time has passed since last touch. Initialized to 0.
    var sinceTouch:CCTime = 0;
    
    // constant speed of horizontal movement.
    let birdSpeedX:CGFloat = 80;
    
    // array to hold the two ground blocks.
    var groundBlocks:[CCSprite] = [];
    // specifies a minimum ground position before it is reassigned, giving the impression of movement.
    var minimumGroundPositionX:CGFloat!;
    // stores the index value in the groundBlocks array of the current ground block being checked for being offscreen.
    var groundBlockIndex:Int = 0;
    // array to hold current Obstacle instances.
    var obstacles:[Obstacle] = [];
    // specifies location of first obstacle.
    let firstObstaclePosition:CGFloat = 280;
    // specifies distance between each obstacle.
    let distanceBetweenObstacles:CGFloat = 160;
    // specifies horizontal position of past obstacle.
    var nextObstaclePosition:CGFloat!;
    // specifies index of active obstacle.
    var activeObstacleIndex:Int = 0;
    // specifies total obstacles.
    var totalObstacles:Int!;
    
    /* cocos2d methods */
    
    // called once scene is loaded
    func didLoadFromCCB() {
        self.groundBlocks.append(self.ground1);
        self.groundBlocks.append(self.ground2);
        self.minimumGroundPositionX = -self.ground1.contentSize.width;
        
        self.nextObstaclePosition = self.firstObstaclePosition;
        var obstacle:Obstacle;
        for i in 0..<3 {
            obstacle = CCBReader.load("Obstacle") as! Obstacle;
            self.obstacles.append(obstacle);
            self.gamePhysicsNode.addChild(obstacle);
        }
        
        self.totalObstacles = self.obstacles.count;
        
        for i in 0..<3 {
            self.spawnNewObstacle();
        }
        
        self.userInteractionEnabled = true;
    }
    
    // called at every rendered frame
    override func update(delta: CCTime) {
        // clampf tests the specific float value and if it is bigger than a set maximum, the value gets assigned to that maximum (which is 200 in this case). First argument is value to test, second argument is minimum value allowed and third argument is the maximum value allowed.
        // setting the second argument (the minimum) to -Float(CGFloat.max) would assign minimum value as the smallest float possible, which means that the downwards velocity will not get affected.
        let velocityY = clampf(Float(self.bird.physicsBody.velocity.y), -200, 200);
        self.bird.physicsBody.velocity = ccp(0, CGFloat(velocityY));
        
        // moves bird horizontally on screen.
        // self.bird.position = ccp(self.bird.position.x + birdSpeedX * CGFloat(delta), self.bird.position.y);
        self.bird.position.x += self.birdSpeedX * CGFloat(delta);
        
        // moves physics node to the left,which repositions every child of it (bird horizontal position is cancelled out)
        self.gamePhysicsNode.position.x -= self.birdSpeedX * CGFloat(delta);
        
        self.sinceTouch += delta; // updates timer
        self.bird.rotation = clampf(self.bird.rotation, -30, 90); // updates rotation, value is clamped to not let bird spin around itself.
        
        // will update bird's angular velocity if the value is not at a minimum or maximum.
        if (self.bird.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(self.bird.physicsBody.angularVelocity), -2, 1);
            self.bird.physicsBody.angularVelocity = CGFloat(angularVelocity);
        }
        // will start rotating the bird down after a while.
        if (self.sinceTouch > 0.3) {
            let impulse = -18000.0 * delta;
            self.bird.physicsBody.applyAngularImpulse(CGFloat(impulse));
        }
        // checks if ground block has gone totally offscreen. if that's the case, repositions it at the end of the next ground block.
        let currentGround = self.groundBlocks[self.groundBlockIndex];
        if (convertToNodeSpace(self.gamePhysicsNode.convertToWorldSpace(currentGround.position)).x <= self.minimumGroundPositionX) {
            println("HI");
            currentGround.position = ccp(-(self.minimumGroundPositionX * 2), currentGround.position.y);
            self.groundBlockIndex = (self.groundBlockIndex + 1) % 2;
        }
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // makes bird go up
        self.bird.physicsBody.applyImpulse(ccp(0, 300));
        // makes bird rotate up
        self.bird.physicsBody.applyAngularImpulse(10000);
        // resets timer
        self.sinceTouch = 0;
    }
    
    /* custom methods */
    
    // creates and adds a new obstacle
    func spawnNewObstacle() {
        self.obstacles[self.activeObstacleIndex].position = ccp(self.nextObstaclePosition, -30);
        self.obstacles[self.activeObstacleIndex].setupRandomPosition();
        self.nextObstaclePosition = self.nextObstaclePosition + self.distanceBetweenObstacles;
        self.activeObstacleIndex = (self.activeObstacleIndex + 1) % self.totalObstacles;
    }
}
