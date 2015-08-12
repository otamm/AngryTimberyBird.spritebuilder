//
//  GameEnd.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;
import GameKit;

class GameEnd:CCNode, GKGameCenterControllerDelegate {
    
    /* connected objects */
    
    weak var restartButton:CCButton!;
    weak var twitterButton:CCButton!;
    weak var facebookButton:CCButton!;
    weak var gameCenterButton:CCButton!;
    weak var themeButton:CCButton!;
    
    weak var totalScore:CCLabelBMFont!;
    weak var highScore:CCLabelBMFont!;
    
    weak var newBest:CCSprite!;
    /* custom variables */
    
    var currentScore:Int = 0;
    var currentBest:Int = 0;
    
    
    // loads current theme index and available themes to pass them to ChooseTheme class.
    var availableThemes:[String] = [];
    var themeIndex:Int!;
    
    /* cocos2d methods */
    
    func didLoadFromCCB() {
        //self.setUpGameCenter();
        //self.loadAds();
        iAdHandler.sharedInstance.setBannerPosition(bannerPosition: .Top);
        iAdHandler.sharedInstance.adBannerView.hidden = false;
        iAdHandler.sharedInstance.displayBannerAd();
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
    
    /* button methods */
    func restart() {
        // hides ads just before restarting.

        iAdHandler.sharedInstance.adBannerView.hidden = true;
        
        var mainScene = CCBReader.load("MainScene") as! MainScene;
        mainScene.isFirstLoad = false;
        //mainScene.playAnimations = true;
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
    
    func chooseTheme() {
        var chooseThemePopover = CCBReader.load("ChooseTheme") as! ChooseTheme;
        chooseThemePopover.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft);
        chooseThemePopover.availableThemes = self.availableThemes;
        chooseThemePopover.position = ccp(0.5, 0.5);
        chooseThemePopover.zOrder = Int.max;
        chooseThemePopover.setCurrentTheme(self.themeIndex);
        self.addChild(chooseThemePopover);
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
        var scoreReporter = GKScore(leaderboardIdentifier: "LumbyBird");
        scoreReporter.value = Int64(self.currentBest);// = Int64(GameCenterInteractor.sharedInstance.score);
        var scoreArray: [GKScore] = [scoreReporter];
        
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
            if error != nil {
                println("Game Center: Score Submission Error");
            }
        });
    }
}