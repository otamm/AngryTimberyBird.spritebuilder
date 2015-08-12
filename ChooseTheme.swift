//
//  ChooseTheme.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 8/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ChooseTheme : CCNode {
    /* linked objects */
    
    weak var themeDisplay:CCSprite!;
    
    weak var themeNameLabel:CCLabelBMFont!;
    
    weak var leftButton:CCButton!;
    
    weak var rightButton:CCButton!;
    
    weak var saveButton:CCButton!;
    
    weak var backButton:CCButton!;
    
    /* custom variables */
    
    var currentThemeIndex:Int!;
    
    var availableThemes:[String] = [];
    
    var theme:String!;
    
    /* cocos2d methods */
    
    override func onEnter() {
        super.onEnter();
        self.loadTheme();
    }
    
    /* custom methods */
    
    func setCurrentTheme(theme: Int) {
        self.currentThemeIndex = theme;
    }
    
    func loadTheme() {
        self.theme = self.availableThemes[self.currentThemeIndex];
        self.themeDisplay.spriteFrame = CCSpriteFrame(imageNamed: "iPad/themeDisplay/" + self.theme + ".png");
        self.themeNameLabel.setString(self.theme);
    }
    
    func reloadGameplay() {
        var mainScene = CCBReader.load("MainScene") as! MainScene;
        mainScene.isFirstLoad = false;
        mainScene.playAnimations = true;
        var scene = CCScene();
        scene.addChild(mainScene);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    /* button methods */
    
    
    func goLeft() {
        self.currentThemeIndex = (self.currentThemeIndex + (self.availableThemes.count - 1)) % self.availableThemes.count;
        self.loadTheme();
    }
    
    func goRight() {
        self.currentThemeIndex = (self.currentThemeIndex + 1) % self.availableThemes.count;
        self.loadTheme();
    }
    
    func saveTheme() {
        NSUserDefaults.standardUserDefaults().setInteger(self.currentThemeIndex, forKey: "themeIndex");
        self.reloadGameplay();
    }
    
    func back() {
        self.reloadGameplay();
    }
    

}