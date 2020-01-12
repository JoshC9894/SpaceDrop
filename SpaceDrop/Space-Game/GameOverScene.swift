//
//  GameOverScene.swift
//  Space-Game
//
//  Created by Joshua Colley on 28/11/2016.
//  Copyright © 2016 Joshua Colley. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    
    let restartButton = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "bg-5")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 1)
        background.size = self.size
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.80)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 125
        scoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "Highscore: \(highScoreNumber)"
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.fontSize = 125
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.45)
        self.addChild(highScoreLabel)
        
        
        restartButton.text = "Restart"
        restartButton.fontColor = SKColor.white
        restartButton.fontSize = 75
        restartButton.zPosition = 1
        restartButton.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.15)
        self.addChild(restartButton)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            if restartButton.contains(pointOfTouch){
                let newScene = GameScene(size: self.size)
                newScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(newScene, transition: transition)
            }
        }
    }
    
    
    
    
    
}
