//
//  GameEnd.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;
import Social;
import GameKit;

class GameEnd:CCNode, GKGameCenterControllerDelegate {
    
    /* connected objects */
    
    weak var restartButton:CCButton!;
    weak var twitterButton:CCButton!;
    weak var facebookButton:CCButton!;
    weak var gameCenterButton:CCButton!;
    
    weak var totalScore:CCLabelBMFont!;
    weak var highScore:CCLabelBMFont!;
    
    weak var newBest:CCSprite!;
    /* custom variables */
    
    var currentScore:Int = 0;
    var currentBest:Int = 0;
    
    /* cocos2d methods */
    
    func didLoadFromCCB() {
        //self.setUpGameCenter();
    }
    
    
    /* custom methods */
    
    func isHighscore(score: Int) {
        self.currentScore = score;
        let defaults = NSUserDefaults.standardUserDefaults();
        let highscore:Int? = defaults.integerForKey("highscore");
        if (highscore != nil) {
            self.currentBest = highscore!;
        }
        if (self.currentScore > self.currentBest) {
            self.updateHighscore();
        }
        self.updateLabels();
    }
    
    func updateHighscore() {
        NSUserDefaults.standardUserDefaults().setInteger(self.currentScore, forKey: "highscore");
        self.currentBest = self.currentScore;
        self.newBest.visible = true;
    }
    
    func updateLabels() {
        self.totalScore.setString("\(self.currentScore)");
        self.highScore.setString("\(self.currentBest)");
    }
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance;
        gameCenterInteractor.authenticationCheck();
    }
    
    func shareButtonTapped() {
        var scene = CCDirector.sharedDirector().runningScene;
        var node: AnyObject = scene.children[0];
        var screenshot = screenShotWithStartNode(node as! CCNode);
        
        let sharedText = "This is some default text that I want to share with my users. [This is where I put a link to download my awesome game]";
        let itemsToShare = [screenshot, sharedText];
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo];
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil);
        controller.excludedActivityTypes = excludedActivities;
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil);
        
    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true;
        var viewSize = CCDirector.sharedDirector().viewSize();
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height));
        rtx.begin();
        node.visit();
        rtx.end();
        return rtx.getUIImage();
    }
    
    /* button methods */
    func restart() {
        var mainScene = CCBReader.load("MainScene") as! MainScene;
        mainScene.isFirstLoad = false;
        var scene = CCScene();
        scene.addChild(mainScene);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    func gameCenter() {
        self.setUpGameCenter();
        self.reportHighScoreToGameCenter();
        self.showLeaderboard();
    }
    
    func facebook() {
        SharingHandler.sharedInstance.postToFacebook(postWithScreenshot: true);
    }
    
    func twitter() {
        SharingHandler.sharedInstance.postToTwitter(stringToPost: "HELLO DERR", postWithScreenshot: true);
    }
    
    /* GameKit methods */
    
    func showLeaderboard() {
        var viewController = CCDirector.sharedDirector().parentViewController!;
        var gameCenterViewController = GKGameCenterViewController();
        gameCenterViewController.gameCenterDelegate = self;
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil);
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reportHighScoreToGameCenter() {
        var scoreReporter = GKScore(leaderboardIdentifier: "CrossItWayWalk");
        scoreReporter.value = Int64(self.currentBest);// = Int64(GameCenterInteractor.sharedInstance.score);
        var scoreArray: [GKScore] = [scoreReporter];
        
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
            if error != nil {
                println("Game Center: Score Submission Error");
            }
        });
    }
}