import Foundation;

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    /* linked objects */
    
    // the bird sprite
    weak var bird:Bird!;
    // first ground; first and second grounds will be rendered one after another to give the impression of movement.
    weak var ground1:CCSprite!;
    // second ground block.
    weak var ground2:CCSprite!;
    // the main physics node, every child of it are affected by physics.
    weak var gamePhysicsNode:CCPhysicsNode!;
    // layer inside gamePhysicsNode to add obstacles to.
    weak var obstaclesLayer:CCNode!;
    // restart button visible once game over is triggered.
    weak var restartButton:CCButton!;
    
    /* custom variables */
    
    // will keep track of how much time has passed since last touch. Initialized to 0.
    var sinceTouch:CCTime = 0;
    // value of total screen height minus ground height.
    var usableScreenSize:CGFloat!;
    // ground height to be used with variable above.
    var groundHeight:CGFloat!;
    // constant speed of horizontal movement.
    var birdSpeedX:CGFloat = 80;
    // array to hold the two ground blocks.
    var groundBlocks:[CCNode] = [];
    // specifies a minimum ground position before it is reassigned, giving the impression of movement.
    var minimumGroundPositionX:CGFloat!;
    // stores the index value in the groundBlocks array of the current ground block being checked for being offscreen.
    var groundBlockIndex:Int = 0;
    // array to hold current Obstacle instances.
    var obstacles:[Obstacle] = [];
    // specifies location of first obstacle.
    let firstObstaclePosition:CGFloat = 380;
    // specifies distance between each obstacle.
    let distanceBetweenObstacles:CGFloat = 280;
    // specifies horizontal position of past obstacle.
    var nextObstaclePosition:CGFloat!;
    // specifies index of active obstacle.
    var activeObstacleIndex:Int = 0;
    // specifies total obstacles.
    var totalObstacles:Int!;
    // specifies last obstacle index; its position will be checked in order to set the time to add a new obstacle to MainScene.
    var lastObstacleIndex:Int = 0;
    // gets minimum possible obstacle position to be officially considered outside scene bounds.
    var minimumObstaclePositionX:CGFloat!;
    // keeps track of current score.
    var score:Int = 0;
    // multiplies current score for popping pigs if on a streak.
    var scoreMultiplier:Int = 0;
    // hold pigs
    var pigs:[Pig] = [];
    // stores pig width to check when pig has gone offscreen
    var minusPigWidth:CGFloat!;
    // checks index of an eventually non-popped pig that might have gone offscreen
    var offscreenPigIndex:Int = 0;
    // checks index of last popped pig
    var lastPoppedPig:Int = 0;
    // keeps track of total number of pigs to respawn a pig only after (number_of_pigs) obstacles from the position it was popped.
    var totalPigs:CGFloat!;
    // these will be checked once a goal is passed, positions will be updated elsewhere due to performance reasons.
    var somethingNeedsRepositioning:Bool = false;
    var groundBlockNeedsRepositioning:Bool = false;
    var pigNeedsRepositioning:Bool = false;
    var obstacleNeedsRepositioning:Bool = false;
    
    /* cocos2d methods */
    
    // called once scene is loaded
    func didLoadFromCCB() {
        self.groundBlocks.append(self.ground1);
        self.groundBlocks.append(self.ground2);
        self.minimumGroundPositionX = -self.ground1.contentSize.width;
        
        self.groundHeight = self.ground1.contentSize.height;
        self.usableScreenSize = self.contentSize.height - self.groundHeight;
        
        self.nextObstaclePosition = self.firstObstaclePosition;
        
        var obstacle:Obstacle;
        for i in 0..<3 {
            obstacle = CCBReader.load("Obstacle") as! Obstacle;
            self.obstacles.append(obstacle);
            self.obstaclesLayer.addChild(obstacle);
        }
        var pig:Pig;
        // will be used to position first three pigs along Y axis
        var random:CGFloat;
        
        for i in 0..<3 {
            pig = CCBReader.load("Pig") as! Pig;
            pig.index = i;
            self.pigs.append(pig);
            self.gamePhysicsNode.addChild(pig);
            random = (CGFloat(CCRANDOM_0_1()) * self.usableScreenSize) + 2 * self.groundHeight;
            //random = (CGFloat(arc4random_uniform(UInt32(self.usableScreenSize)))) + self.groundHeight;
            pig.position = CGPoint(x: (self.distanceBetweenObstacles / 2) + self.nextObstaclePosition + (CGFloat(i) * self.distanceBetweenObstacles), y: random);
        }
        self.minusPigWidth = -(self.pigs[0].contentSize.width);
        
        self.totalObstacles = self.obstacles.count;
        self.totalPigs = CGFloat(self.pigs.count);
        self.minimumObstaclePositionX = -self.obstacles[0].contentSize.width;
        
        for i in 0..<3 {
            self.spawnNewObstacle();
            //self.spawnNewPig();
        }
        
        
        
        self.gamePhysicsNode.collisionDelegate = self;
        self.userInteractionEnabled = true;
        //self.gamePhysicsNode.debugDraw = true;
    }
    
    // called at every rendered frame
    override func update(delta: CCTime) {
        // clampf tests the specific float value and if it is bigger than a set maximum, the value gets assigned to that maximum (which is 200 in this case). First argument is value to test, second argument is minimum value allowed and third argument is the maximum value allowed.
        // setting the second argument (the minimum) to -Float(CGFloat.max) would assign minimum value as the smallest float possible, which means that the downwards velocity will not get affected.
        let velocityY = clampf(Float(self.bird.physicsBody.velocity.y), -200, 300);
        self.bird.physicsBody.velocity = ccp(0, CGFloat(velocityY));
        
        // moves bird horizontally on screen.
        self.bird.position.x += self.birdSpeedX * CGFloat(delta);
        
        // moves physics node to the left, which repositions every child of it (bird horizontal position is cancelled out)
        self.gamePhysicsNode.position.x -= self.birdSpeedX * CGFloat(delta);
        
        //self.sinceTouch += delta; // updates timer
        /*self.bird.rotation = clampf(self.bird.rotation, -30, 90); // updates rotation, value is clamped to not let bird spin around itself.
        
        // will update bird's angular velocity if the value is not at a minimum or maximum.
        if (self.bird.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(self.bird.physicsBody.angularVelocity), -2, 1);
            self.bird.physicsBody.angularVelocity = CGFloat(angularVelocity);
        }
        // will start rotating the bird down after a while.
        if (self.sinceTouch > 0.3) {
            let impulse = -18000.0 * delta;
            self.bird.physicsBody.applyAngularImpulse(CGFloat(impulse));
        }*/
        if (self.somethingNeedsRepositioning) {
            if (self.groundBlockNeedsRepositioning) {
                self.spawnNewGroundBlock();
                self.groundBlockNeedsRepositioning = false;
            }
            if (self.pigNeedsRepositioning) {
                self.spawnNewPig();
                self.pigNeedsRepositioning = false;
            }
            if (self.obstacleNeedsRepositioning) {
                self.spawnNewObstacle();
                self.obstacleNeedsRepositioning = false;
            }
            self.somethingNeedsRepositioning = false;
        }
    }
    
    // listens for collision between bird and any 'level' object.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, level: CCNode!) -> Bool {
        self.triggerGameOver();
        return true;
    }
    
    // listens for collisions between bird and goal, located between two pipes.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, goal: Goal!) -> Bool {
        self.score += 1000;
        println("\(self.score)");
        if (convertToNodeSpace(self.gamePhysicsNode.convertToWorldSpace(self.groundBlocks[self.groundBlockIndex].position)).x <= self.minimumGroundPositionX) {
            self.somethingNeedsRepositioning = true;
            self.groundBlockNeedsRepositioning = true;
        }
        
        if (convertToNodeSpace(self.gamePhysicsNode.convertToWorldSpace(self.obstacles[self.activeObstacleIndex].position)).x <= self.minimumObstaclePositionX) {
            self.somethingNeedsRepositioning = true;
            self.obstacleNeedsRepositioning = true;
            //self.lastObstacleIndex = (self.lastObstacleIndex + 1) % self.totalObstacles;
        }
        
        if (convertToNodeSpace(self.gamePhysicsNode.convertToWorldSpace(self.pigs[self.offscreenPigIndex].position)).x <= self.minusPigWidth) {
            self.somethingNeedsRepositioning = true;
            self.pigNeedsRepositioning = true;
        }
        
        return true;
    }
    
    // listens for collision between bird and any 'level' object.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, pig: Pig!) -> Bool {
        self.pigs[pig.index].die();
        self.lastPoppedPig = pig.index;
        self.scoreMultiplier++;
        self.score = self.score + (1000 * self.scoreMultiplier);
        println("\(self.score)");
        return true;
    }
    
    /* button methods */
    
    func restart() {
        let scene = CCBReader.loadAsScene("MainScene");
        CCDirector.sharedDirector().presentScene(scene);
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // makes bird go up
        self.bird.physicsBody.applyImpulse(ccp(0, 300));
        // makes bird rotate up
        //self.bird.physicsBody.applyAngularImpulse(10000);
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
    
    // interchanges ground rendering
    func spawnNewGroundBlock() {
        if (self.groundBlockIndex == 0) {
            self.ground1.position = ccp(self.ground1.position.x + 2 * 352, 88);
        } else {
            self.ground2.position = ccp(self.ground2.position.x + 2 * 352, 88);
        }
        //self.groundBlocks[self.groundBlockIndex].position = ccp(-(self.minimumGroundPositionX), 0);
        self.groundBlockIndex = (self.groundBlockIndex + 1) % 2;
        
    }
    
    // spawns pig at new location
    func spawnNewPig() {
        let random = (CGFloat(CCRANDOM_0_1()) * self.usableScreenSize) + 2 * self.groundHeight;
        self.pigs[self.offscreenPigIndex].position = ccp((self.distanceBetweenObstacles / 2) + self.nextObstaclePosition + (self.totalPigs * self.distanceBetweenObstacles), random);
        // if last pig to go offscreen was popped, revive it before repositioning. Else, set score multiplier to 0.
        if (self.offscreenPigIndex == self.lastPoppedPig) {
            self.pigs[self.offscreenPigIndex].revive();
        } else {
            self.scoreMultiplier = 0;
        }
            self.pigs[self.offscreenPigIndex].revive();
        self.offscreenPigIndex = (self.offscreenPigIndex + 1) % self.pigs.count;
        //self.unschedule("spawnNewPig");
    }
    
    /*func pigAscending() {
        self.pigs[self.activePigIndex].runAction(CCActionMoveBy(duration: 0.2, position: CGPoint(x: 0, y: 500)));
        self.unschedule("pigAscending");
    }*/
    func triggerGameOver() {
        self.userInteractionEnabled = false;
        self.restartButton.userInteractionEnabled = true;
        self.restartButton.visible = true;
        self.bird.die();
        self.birdSpeedX = 0;
        self.bird.rotation = 90;
        self.bird.physicsBody.allowsRotation = false;
        
        // set pigs' collision mask to an empty array, preventing bird popping a pig after game is over.
        for p in 0..<self.pigs.count {
            self.pigs[p].physicsBody.collisionMask = [];
        }
        
        
        // just in case
        self.bird.stopAllActions();
        
        let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)));
        let moveBack = CCActionEaseBounceOut(action: move.reverse());
        let shakeSequence = CCActionSequence(array: [move, moveBack]);
        self.runAction(shakeSequence);
    }
}
