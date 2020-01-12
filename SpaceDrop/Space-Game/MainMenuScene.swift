//
//  MainMenuScene.swift
//  Space-Game
//
//  Created by Joshua Colley on 29/11/2016.
//  Copyright © 2016 Joshua Colley. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "bg-5")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let label1 = SKLabelNode(fontNamed: "The Bold Font")
        label1.text = "JC-Designs Presents"
        label1.fontSize = 45
        label1.fontColor = SKColor.white
        label1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.78)
        label1.zPosition = 1
        self.addChild(label1)
        
        let label2 = SKLabelNode(fontNamed: "The Bold Font")
        label2.text = "SPACE"
        label2.fontSize = 200
        label2.fontColor = SKColor.white
        label2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.625)
        label2.zPosition = 1
        self.addChild(label2)
        
        let label3 = SKLabelNode(fontNamed: "The Bold Font")
        label3.text = "DROP"
        label3.fontSize = 200
        label3.fontColor = SKColor.white
        label3.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        label3.zPosition = 1
        self.addChild(label3)
        
        let label4 = SKLabelNode(fontNamed: "The Bold Font")
        label4.text = "Start Game"
        label4.name = "startButton"
        label4.fontSize = 130
        label4.fontColor = SKColor.white
        label4.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
        label4.zPosition = 1
        self.addChild(label4)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let touchPoint = touch.location(in: self)
            let tapped = atPoint(touchPoint)
            
            if tapped.name == "startButton"{
                let nextScene = GameScene(size: self.size)
                nextScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(nextScene, transition:transition)
            }
        }
    }
    
    
    
}
