import Foundation;

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    /* linked objects */
    
    // the bird sprite
    weak var bird:Bird!;
    // the main physics node, every child of it are affected by physics.
    weak var gamePhysicsNode:CCPhysicsNode!;
    // layer inside gamePhysicsNode to add obstacles to and guarantee they'll be affected by physics.
    weak var obstaclesLayer:CCNode!;
    // layer inside gamePhysicsNode to add ground blocks to and guarantee they'll be affected by physics.
    weak var groundBlocksLayer:CCNode!;
    // gets first background image (will be chained to itself)
    /*weak var background1:CCNode!;
    // gets second background image which is exactly like the first one
    weak var background2:CCNode!;
    // same
    weak var background3:CCNode!;*/
    // layer which contain background nodes.
    weak var backgroundLayer:CCNode!;
    // layer which contains pigs
    weak var pigsLayer:CCNode!;
    // total score label
    weak var scoreLabel:CCLabelBMFont!;
    // added points label
    weak var addedPointsLabel1:CCLabelBMFont!;
    // second added points label
    weak var addedPointsLabel2:CCLabelBMFont!;
    // just a label with the text 'score'. Invisible once game is over.
    weak var scoreText:CCLabelBMFont!;
    // starts game.
    weak var playButton:CCButton!;
    // presents theme selection scene.
    weak var themeButton:CCButton!;
    
    /* custom variables */
    
    // will keep track of how much time has passed since last touch. Initialized to 0.
    var sinceTouch:CCTime = 0;
    // value of total screen height minus ground height.
    var usableScreenHeight:CGFloat!;
    // ground height to be used with variable above.
    var groundHeight:CGFloat!;
    // same, with width
    var groundWidth:CGFloat!;
    // constant speed of horizontal movement.
    var birdSpeedX:CGFloat = 80;
    // array to hold the ground blocks.
    var groundBlocks:[Ground] = [];
    // specifies a minimum ground position before it is reassigned, giving the impression of movement.
    var minimumGroundPositionX:CGFloat!;
    // stores the index value in the groundBlocks array of the current ground block being checked for being offscreen.
    var groundBlockIndex:Int = 0;
    // array to hold current Obstacle instances.
    var obstacles:[Obstacle] = [];
    // specifies location of first obstacle.
    let firstObstaclePosition:CGFloat = 450;
    // specifies distance between each obstacle.
    let distanceBetweenObstacles:CGFloat = 288; // should be either a multiple or divisor of 256 to avoid a bug.
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
    // checks index of an eventually non-popped pig that might have gone offscreen. Checks one index before the last pig offscreen, so index starts at 1 and not 0.
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
    var backgroundNeedsRepositioning:Bool = false;
    // gets background width, will be compared to itself times -1 to detect when frame has gone offscreen.
    var minusBackgroundWidth:CGFloat!;
    // keeps track of current background index
    var backgroundIndex:Int = 0;
    // array to reference background images. Initially empty.
    var backgrounds:[Background] = [];
    // checks whether or not this is the first load and display extra intro animations if it is.
    var isFirstLoad:Bool = true;
    // checks wheter or not game is over.
    var isGameOver:Bool = false;
    // stores obstacle width to control pig position relative to it.
    var obstacleWidth:CGFloat!;
    // stores last pig horizontal position.
    var lastPigPosition:CGFloat!;
    // stores number for added points label
    var addedPointsNum:Int = 0;
    // represents directory for current theme.
    var theme:String!;
    // array with themes available.
    var themes:[String] = ["DarkForest", "Realness", "Aqua"];
    // current theme index, set to 0 by default.
    var themeIndex:Int = 0;
    // checks wheter or not game started.
    var gameStarted:Bool = false;
    // initial gravity value. set after loading game.
    var gravity:Float!;
    // flight value, upwards Y velocity
    var flight:Float!;
    // compensate the variety of densities for each bird.
    var flightImpulse:CGFloat!;
    // store values for each respective theme.
    var themeImpulses:[CGFloat] = [1000, 1800, 1000];
    var themeGravities:[Float] = [-200, -250, -200];
    var themeFlights:[Float] = [210, 250, 210];
    // checks whether to play initial animations or not. Set to false by default
    var playAnimations = false;
    
    /* cocos2d methods */
    
    // called once scene is loaded
    func didLoadFromCCB() {
        self.nextObstaclePosition = self.firstObstaclePosition;
        self.loadTheme();
        
        //self.themeIndex = 1;
        var chosenTheme = self.themes[self.themeIndex];
        //var chosenTheme = self.themes[0];
        self.bird = CCBReader.load("Themes/" + chosenTheme + "/Bird" + "\(self.themeIndex)") as! Bird;
        self.gamePhysicsNode.addChild(self.bird);
        self.setupPositions();
        // bird added to physics node once game starts.
        //self.gamePhysicsNode.addChild(self.bird);
        
        self.backgroundLayer.zOrder = 0;
        self.obstaclesLayer.zOrder = 1;
        self.groundBlocksLayer.zOrder = 2;
        self.bird.zOrder = 3;
        self.addedPointsLabel1.zOrder = 4;
        self.addedPointsLabel2.zOrder = 5;
        self.scoreText.zOrder = 6;
        self.scoreLabel.zOrder = 7;
        
        var background:Background;
        var obstacle:Obstacle;
        var groundBlock:Ground;
        
        self.backgroundLayer.position = CGPoint(x: 0, y: 0);
        
        for i in 0..<4 {
            // add backgrounds and position them spriteFrame = CCSpriteFrame(imageNamed:)
            background = CCBReader.load("Background") as! Background;
            background.setSprite(chosenTheme);
            self.backgroundLayer.addChild(background);
            self.backgrounds.append(background);
            self.backgrounds[i].position = CGPoint(x: background.contentSize.width * CGFloat(i) - 4, y: 0);
            
            // add obstacles, which will be spawned later.
            obstacle = CCBReader.load("Obstacle") as! Obstacle;
            //obstacle.zOrder = -10;
            obstacle.setSprite(chosenTheme);
            self.obstacles.append(obstacle);
            self.obstaclesLayer.addChild(obstacle);
            
            // add ground blocks and positions them.
            groundBlock = CCBReader.load("Ground") as! Ground;
            groundBlock.spriteFrame = CCSpriteFrame(imageNamed: "iPad/worlds/" + chosenTheme + "/ground4.png");
            self.groundBlocks.append(groundBlock);
            self.groundBlocksLayer.addChild(self.groundBlocks[i]);
            self.groundBlocks[i].position = CGPoint(x: groundBlock.contentSize.width * CGFloat(i) - 4, y: 0);
        }
        
        self.obstacleWidth = self.obstacles[0].contentSize.width;
        self.minusBackgroundWidth = -self.backgrounds[0].contentSize.width;
        
        self.groundHeight = self.groundBlocks[0].contentSize.height;
        self.groundWidth = self.groundBlocks[0].contentSize.width;
        
        self.minimumGroundPositionX = -self.groundWidth;
        
        self.usableScreenHeight = self.contentSize.height - self.groundHeight;
        
        var pig:Pig;
        // will be used to position first three pigs along Y axis
        var randomX:CGFloat;
        var randomY:CGFloat;
        
        for i in 0..<4 {
            pig = CCBReader.load("Themes/" + chosenTheme + "/Pig" + "\(self.themeIndex)") as! Pig;
            pig.index = i;
            self.pigs.append(pig);
            //self.pigsLayer.addChild(pig);
            self.obstaclesLayer.addChild(pig);
            randomY = (CGFloat(CCRANDOM_0_1()) * self.usableScreenHeight) + 2 * self.groundHeight;
            randomX = round((self.distanceBetweenObstacles - 2 * self.obstacleWidth) / 4);
            
            if (CCRANDOM_0_1() > 0.5) {
                randomX = -randomX;
            }

            self.pigs[i].distanceFromCenter = randomX;
            
            pig.position = CGPoint(x: ((self.distanceBetweenObstacles - 2 * self.obstacleWidth) / 2) + self.nextObstaclePosition + (CGFloat(i) * self.distanceBetweenObstacles) + randomX + self.obstacleWidth, y: randomY);
        }
        self.lastPigPosition = self.pigs[self.pigs.count - 1].position.x;

        
        self.minusPigWidth = -(self.pigs[0].contentSize.width);
        
        self.totalObstacles = self.obstacles.count;
        self.totalPigs = CGFloat(self.pigs.count);
        self.minimumObstaclePositionX = -self.obstacles[0].contentSize.width;
        
        for i in 0..<4 {
            self.spawnNewObstacle();
        }
        
        self.gamePhysicsNode.collisionDelegate = self;
        self.userInteractionEnabled = true;
        //self.gamePhysicsNode.debugDraw = true;
    }
    
    // executed just after didLoadFromCCB.
    override func onEnter() {
        super.onEnter();
        // loads ads and displays them at the top on first load; from second load on, displays them at the top.
        if (self.isFirstLoad) {
            //self.loadAds();
            iAdHandler.sharedInstance.loadAds(bannerPosition: .Top);
            //iAdHandler.sharedInstance.adBannerView.hidden = false;
            iAdHandler.sharedInstance.displayBannerAd();
            iAdHandler.sharedInstance.loadInterstitialAd();
            self.playAnimations = true;
        } else {
            iAdHandler.sharedInstance.setBannerPosition(bannerPosition: .Bottom);
            iAdHandler.sharedInstance.displayBannerAd();
        }
        
        if (self.isFirstLoad || self.playAnimations) {
            self.playButton.visible = true;
            self.themeButton.visible = true;
            self.playButton.userInteractionEnabled = true;
            self.themeButton.userInteractionEnabled = true;
            self.scoreText.visible = false;
            self.scoreLabel.visible = false;
            
            self.isGameOver = true;
            
            self.flight = 300;
            self.gravity = -200;
            animationManager.runAnimationsForSequenceNamed("logoEnter");
        } else {
            //iAdHandler.sharedInstance.loadAds(bannerPosition: .Bottom);
            //iAdHandler.sharedInstance.adBannerView.hidden = false;
            self.gameStarted = true;
            self.isGameOver = false;
        }
    }
    
    // called at every rendered frame
    override func update(delta: CCTime) {
        // clampf tests the specific float value and if it is bigger than a set maximum, the value gets assigned to that maximum (which is 200 in this case). First argument is value to test, second argument is minimum value allowed and third argument is the maximum value allowed.
        // setting the second argument (the minimum) to -Float(CGFloat.max) would assign minimum value as the smallest float possible, which means that the downwards velocity will not get affected.
        if (self.gameStarted) {
            /*let velocityY = clampf(Float(self.bird.physicsBody.velocity.y), self.gravity, self.flight);
            self.bird.physicsBody.velocity = ccp(0, CGFloat(velocityY));*/
            // moves bird horizontally on screen.
            let velocityY = clampf(Float(self.bird.physicsBody.velocity.y), self.gravity, self.flight);
            self.bird.physicsBody.velocity = ccp(0, CGFloat(velocityY))
            self.bird.position.x += self.birdSpeedX * CGFloat(delta);
        
            // moves physics node to the left, which repositions every child of it (bird horizontal position is cancelled out)
            self.gamePhysicsNode.position.x -= self.birdSpeedX * CGFloat(delta);
        
            //self.sinceTouch += delta; // updates timer
            /*self.bird.rotation = clampf(self.bird.rotation, -30, 90); // updates rotation, value is clamped to    not let bird spin around itself.
        
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
        }
        
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
        
            if (self.backgroundNeedsRepositioning) {
                for i in 0..<self.backgrounds.count {
                    if (self.convertToNodeSpace(self.backgroundLayer.convertToWorldSpace(self.backgrounds[i].position)).x <= self.minusBackgroundWidth) {
                        self.spawnNewBackground();
                    }
                }
                self.backgroundNeedsRepositioning = false;
            }
            self.somethingNeedsRepositioning = false;
        }
    }
    
    // listens for collision between bird and any 'level' object.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, level: CCNode!) -> ObjCBool {
        self.triggerGameOver();
        return true;
    }
    
    // listens for collisions between bird and goal, located between two pipes. A lot of checks will be ran here to save processing power from doing all of them on the update method, which would execute at every new frame rendered.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, goal: Goal!) -> ObjCBool {
        
        self.score += 100;
        
        self.scoreLabel.setString("\(self.score)");
        self.displayAddedPoints(100);
        
        if (self.convertToNodeSpace(self.groundBlocksLayer.convertToWorldSpace(self.groundBlocks[self.groundBlockIndex].position)).x <= self.minimumGroundPositionX) {
            self.somethingNeedsRepositioning = true;
            self.groundBlockNeedsRepositioning = true;
        }
        
        if (self.convertToNodeSpace(self.obstaclesLayer.convertToWorldSpace(self.obstacles[self.activeObstacleIndex].position)).x <= self.minimumObstaclePositionX) {
            self.somethingNeedsRepositioning = true;
            self.obstacleNeedsRepositioning = true;
        }
        
        if (self.convertToNodeSpace(self.obstaclesLayer.convertToWorldSpace(self.pigs[self.offscreenPigIndex].position)).x <= self.minusPigWidth) {
            self.somethingNeedsRepositioning = true;
            self.pigNeedsRepositioning = true;
            //println("pig will be repositioned");
        }
        
        if (self.convertToNodeSpace(self.backgroundLayer.convertToWorldSpace(self.backgrounds[self.backgroundIndex].position)).x <= self.minusBackgroundWidth) {
            self.somethingNeedsRepositioning = true;
            self.backgroundNeedsRepositioning = true;
        }
        
        return true;
    }
    
    // listens for collision between bird and any 'level' object.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, pig: Pig!) -> ObjCBool {
        if (!pig.isPopped) {
            self.pigs[pig.index].die();
            if (self.lastPoppedPig != (pig.index + self.pigs.count - 1) % self.pigs.count) {
                self.scoreMultiplier = 0;
            }
            self.lastPoppedPig = pig.index;
            self.scoreMultiplier++;
        
            let addToScore = 50 * self.scoreMultiplier;
            self.displayAddedPoints(addToScore);
            self.score = self.score + (addToScore);
            self.scoreLabel.setString("\(self.score)");
        
        //println("\(self.score)");
        }
        return true;
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCNode!, backgroundSensor: CCNode!) -> ObjCBool {
        self.somethingNeedsRepositioning = true;
        self.backgroundNeedsRepositioning = true;
        return true;
    }
    
    /* button methods */
    
    func startGame() {
        iAdHandler.sharedInstance.adBannerView.hidden = true;
        
        var mainScene = CCBReader.load("MainScene") as! MainScene;
        mainScene.isFirstLoad = false;
        mainScene.gameStarted = true;
        mainScene.isGameOver = false;
        //mainScene.gameStarted = true;
        var scene = CCScene();
        scene.addChild(mainScene);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    func chooseTheme() {
        var chooseThemePopover = CCBReader.load("ChooseTheme") as! ChooseTheme;
        chooseThemePopover.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft);
        chooseThemePopover.availableThemes = self.themes;
        chooseThemePopover.position = ccp(0.5, 0.5);
        chooseThemePopover.zOrder = Int.max;
        chooseThemePopover.setCurrentTheme(self.themeIndex);
        self.addChild(chooseThemePopover);
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (self.gameStarted) {
            // makes bird go up
            self.bird.physicsBody.applyImpulse(ccp(0, 10000));
            // makes bird rotate up
            //self.bird.physicsBody.applyAngularImpulse(10000);
            // resets timer
            let velocityY = clampf(Float(self.bird.physicsBody.velocity.y), self.gravity, self.flight);
            self.bird.physicsBody.velocity = ccp(0, CGFloat(velocityY));
            self.sinceTouch = 0;
        } else {
            if !(self.isFirstLoad || self.playAnimations) {
                self.displayGameOver();
            }
        }
    }
    
    /* custom methods */
    
    // swaps background frames to give impression of continuous horizontal movement.
    func spawnNewBackground() {
        //self.backgrounds[self.backgroundIndex].position.x = self.backgrounds[self.backgroundIndex].position.x + CGFloat(self.backgrounds.count) * (self.backgrounds[self.backgroundIndex].backgroundWidth); // will actually add two times its own width to its X position.
        self.backgrounds[self.backgroundIndex].position.x += CGFloat(self.backgrounds.count) * -(self.minusBackgroundWidth);
        
        self.backgrounds[self.backgroundIndex].position = ccp(round(self.backgrounds[self.backgroundIndex].position.x), round(self.backgrounds[self.backgroundIndex].position.y));
        
        self.backgroundIndex = (self.backgroundIndex + 1) % self.backgrounds.count;
    }
    
    // creates and adds a new obstacle
    func spawnNewObstacle() {
        self.obstacles[self.activeObstacleIndex].position = ccp(self.nextObstaclePosition, -30);
        self.obstacles[self.activeObstacleIndex].setupRandomPosition();
        self.nextObstaclePosition = self.nextObstaclePosition + self.distanceBetweenObstacles;
        self.activeObstacleIndex = (self.activeObstacleIndex + 1) % self.totalObstacles;
        
    }
    
    // interchanges ground rendering
    func spawnNewGroundBlock() {
        self.groundBlocks[self.groundBlockIndex].position.x += self.groundWidth * CGFloat(self.groundBlocks.count);
        
        self.groundBlocks[self.groundBlockIndex].position = ccp(round(self.groundBlocks[self.groundBlockIndex].position.x), round(self.groundBlocks[self.groundBlockIndex].position.y));
        
        self.groundBlockIndex = (self.groundBlockIndex + 1) % self.groundBlocks.count;
        
    }
    
    // spawns pig at new location
    func spawnNewPig() {
        let randomY:CGFloat = (CGFloat(CCRANDOM_0_1()) * self.usableScreenHeight) + 2 * self.groundHeight;
        var randomX:CGFloat = round(CGFloat(self.distanceBetweenObstacles - 2 * self.obstacleWidth) / 4);
        
        var pigDistanceFromCenter:CGFloat = self.pigs[self.offscreenPigIndex].distanceFromCenter;
        if (CCRANDOM_0_1() > 0.5) {
            randomX = -randomX;
        }
        
        self.pigs[self.offscreenPigIndex].distanceFromCenter = randomX;

        // assigns random position to pig. X axis is half the distance between obstacles plus or minus up to one third the distance between obstacles. Y axis is a random position between the ground and the full screen height.
        //self.pigs[self.offscreenPigIndex].position = CGPoint(x: self.lastPigPosition - self.pigs[(self.offscreenPigIndex + self.pigs.count - 1) % self.pigs.count].distanceFromCenter + (self.obstacleWidth + self.distanceBetweenObstacles / 2), y: randomY);
        self.pigs[self.offscreenPigIndex].position = CGPoint(x: self.lastPigPosition - pigDistanceFromCenter + self.distanceBetweenObstacles + randomX, y: randomY);
        
        if (self.pigs[self.offscreenPigIndex].isPopped) {
            self.pigs[self.offscreenPigIndex].revive();
        } else {
            if (self.scoreMultiplier < 1) {
                self.scoreMultiplier = 0;
            }
        }
        
        self.lastPigPosition = self.pigs[self.offscreenPigIndex].position.x;
        println("AQW \(self.lastPigPosition)");
        self.offscreenPigIndex = (self.offscreenPigIndex + 1) % self.pigs.count;
    }
    
    func triggerGameOver() {
        //self.unschedule("gameplay");
        self.bird.die();
        self.birdSpeedX = 0;
        self.bird.rotation = 90;
        self.bird.physicsBody.allowsRotation = false;
        
        // set pigs' collision mask to an empty array, preventing bird popping a pig after game is over.
        for p in 0..<self.pigs.count {
            self.pigs[p].physicsBody.collisionMask = [];
        }
        if !(self.isFirstLoad || self.playAnimations) {
            self.isGameOver = true;
            self.gameStarted = false;
            self.schedule("displayGameOver", interval: 70.0 / 60.0);
        }
        
        // just in case
        self.bird.stopAllActions();
        
        let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)));
        let moveBack = CCActionEaseBounceOut(action: move.reverse());
        let shakeSequence = CCActionSequence(array: [move, moveBack]);
        self.runAction(shakeSequence);
    }
    
    // displays how many points the last action added to score.
    func displayAddedPoints(points: Int) {
        if (self.addedPointsNum == 0) {
            self.addedPointsLabel1.setString("+\(points)");
            self.addedPointsLabel1.visible = true;
            self.addedPointsLabel1.position = self.bird.position;
            self.addedPointsLabel1.runAction(CCActionMoveBy(duration: 20.0/60.0, position: CGPoint(x: 0, y: 100)));
        } else {
            self.addedPointsLabel2.setString("+\(points)");
            self.addedPointsLabel2.visible = true;
            self.addedPointsLabel2.position = self.bird.position;
            self.addedPointsLabel2.runAction(CCActionMoveBy(duration: 20.0/60.0, position: CGPoint(x: 0, y: 100)));
        }
        self.schedule("undisplayAddedPoints", interval: 20.0 / 60.0);
    }
    
    func undisplayAddedPoints() {
        if (self.addedPointsNum == 0) {
            self.addedPointsLabel1.visible = false;
        } else {
            self.addedPointsLabel2.visible = false;
        }
        self.addedPointsNum = (self.addedPointsNum + 1) % 2;
        self.unschedule("undisplayAddedPoints");
    }
    
    func displayGameOver() {
        self.unschedule("displayGameOver");
        // so bird won't move.
        self.userInteractionEnabled = false;
        // makes score labels invisible
        self.scoreLabel.visible = false;
        self.scoreText.visible = false;
        
        var gameEndPopover = CCBReader.load("GameEnd") as! GameEnd;
        gameEndPopover.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft);
        gameEndPopover.position = ccp(0.5, 0.5);
        gameEndPopover.zOrder = Int.max;
        gameEndPopover.themeIndex = self.themeIndex;
        gameEndPopover.availableThemes = self.themes;
        gameEndPopover.isHighscore(self.score);
        self.addChild(gameEndPopover);
    }
    
    func loadTheme() {
        let defaults = NSUserDefaults.standardUserDefaults();
        var chosenIndex:Int? = defaults.integerForKey("themeIndex");
        var defaultIndex = 0;
        if (chosenIndex != nil) {
            self.themeIndex = chosenIndex!;
        } else {
            self.themeIndex = defaultIndex;
        }
        
        self.gravity = self.themeGravities[self.themeIndex];
        self.flight = self.themeFlights[self.themeIndex];
        self.flightImpulse = self.themeImpulses[self.themeIndex];
    }
    
    func setupPositions() {
        self.bird.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width * 0.34, y: CCDirector.sharedDirector().viewSize().height * 0.7);
    }
    
}
