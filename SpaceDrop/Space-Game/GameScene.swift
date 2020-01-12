//
//  GameScene.swift
//  Space-Game
//
//  Created by Joshua Colley on 28/11/2016.
//  Copyright © 2016 Joshua Colley. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let startLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "hero")
    
    let shootSound = SKAction.playSoundFileNamed("shoot-sound.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
    
    let explosionAtlas = SKTextureAtlas(named: "explosion")
    var explosion: SKSpriteNode!
    var explosionFrames: [SKTexture]!
    
    let gameArea:CGRect
    
    enum gameState{
        case preGame
        case inGame
        case postGame
    }
    
    var currentGameState = gameState.preGame
    
    
    //Physics Catagories
    struct PhysicsCatagories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
    }
    
    
    
    //Randomize Functions
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max:CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    
    override init(size:CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        //Backgrounds (2 for scrolling)
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "bg-5")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        
        
        //Player
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCatagories.Player
        player.physicsBody!.collisionBitMask = PhysicsCatagories.None
        player.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy
        
        self.addChild(player)
        
        //Score
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        
        self.addChild(scoreLabel)
        
        //Lives
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        
        self.addChild(livesLabel)
        
        let foldDown = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(foldDown)
        livesLabel.run(foldDown)
        
        //Tap to Start Label
        startLabel.text = "Tap to Start"
        startLabel.fontSize = 100
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        startLabel.zPosition = 1
        startLabel.alpha = 0
        self.addChild(startLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatForever = SKAction.repeatForever(sequence)
        
        startLabel.run(repeatForever)
        
    }
    
    
    
    //Start Game Function
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, delete])
        
        startLabel.run(deleteSequence)
        
        let moveShip = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevel = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShip, startLevel])
        player.run(startGameSequence)
    }
    
    
    //Score Function
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 40 || gameScore == 65{
            startNewLevel()
        }
    }
    
    
    //Life Function
    func loseLife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            gameOver()
        }
    }
    
    
    //Game Over Function
    func gameOver(){
        
        currentGameState = gameState.postGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet", using: {
            bullet, stop in
            bullet.removeAllActions()
        })
        
        self.enumerateChildNodes(withName: "Enemy", using: {
            enemy, stop in
            enemy.removeAllActions()
        })
        
        //Change Scene with Delay
        let changeSceneAction = SKAction.run(changeScene)
        let wait = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([wait, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    
    
    //Move to Game Over Scene
    func changeScene(){
        let newScene = GameOverScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene, transition: transition)
    }
    
    
    
    //Bullet Function
    func fire_bullet(){
        
        //Spawn Bullet
        let bullet = SKSpriteNode(imageNamed: "hero-laser")
        bullet.setScale(1)
        bullet.name="Bullet"
        bullet.position = player.position
        bullet.zPosition = 1
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCatagories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCatagories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy
        
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 2)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([shootSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    
    
    
    
    
    //Spawn Enemies
    func spawnEnemy(){
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        
        //Random number for Enemy Spwan
        let A: UInt32 = 0
        let B: UInt32 = 4
        let number = arc4random_uniform(B - A + 1) + A
        
        var enemy: SKSpriteNode
        
        switch number {
        case 0:
           enemy = SKSpriteNode(imageNamed: "villan1")
        case 1:
           enemy = SKSpriteNode(imageNamed: "villan2")
        case 2:
           enemy = SKSpriteNode(imageNamed: "villan3")
        case 3:
           enemy = SKSpriteNode(imageNamed: "villan4")
        case 4:
           enemy = SKSpriteNode(imageNamed: "villan5")
        default:
           enemy = SKSpriteNode(imageNamed: "villan1")
        }
        
        
        
        enemy.setScale(0.5)
        enemy.name = "Enemy"
        enemy.position = startPoint
        enemy.zPosition = 2
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCatagories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCatagories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCatagories.Player | PhysicsCatagories.Bullet
        
        self.addChild(enemy)
        
        //Move & Delete Enemy
        let moveEnemy = SKAction.move(to: endPoint, duration: 3)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseLife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        
        //Rotate Enemy as it moves
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    
    
    
    
    
    
    //Start New Level
    func startNewLevel(){
        
        levelNumber += 1
        
        print(levelNumber)
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.0
        case 2: levelDuration = 0.8
        case 3: levelDuration = 0.6
        case 4: levelDuration = 0.4
        case 5: levelDuration = 0.2
            
        default:
            break
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    
    
    //Contact Function
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //Numerically order contact bodies
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        
        //
        //Set what happens when contact occurs
        //
        if body1.categoryBitMask == PhysicsCatagories.Player && body2.categoryBitMask == PhysicsCatagories.Enemy{
            //
            //if player hits enemy
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
            gameOver()
        }
        
        if body1.categoryBitMask == PhysicsCatagories.Bullet && body2.categoryBitMask == PhysicsCatagories.Enemy && (body2.node?.position.y)! < self.size.height{
            //
            //if bullet hits enemy
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            addScore()
        }
    }
    
    
    
    
    
    //Spawn Explosion
    //Animation using frames
    func spawnExplosion(spawnPosition: CGPoint){
        var walkFrames = [SKTexture]()
        let numImages = explosionAtlas.textureNames.count
        for i in 1...numImages {
            let explosionName = "explosion\(i-1)"
            walkFrames.append(explosionAtlas.textureNamed(explosionName))
        }
        
        explosionFrames = walkFrames
        
        let firstFrame = explosionFrames[0]
        explosion = SKSpriteNode(texture: firstFrame)
        explosion.position = spawnPosition
        explosion.zPosition = 3
        
        self.addChild(explosion)
        let func1 = SKAction.animate(with: explosionFrames, timePerFrame: 0.15)
        let func2 = SKAction.removeFromParent()
        let sequence = SKAction.sequence([explosionSound,func1, func2])
        explosion.run(sequence)
    }
    
    
    
    
    //Shoot on touch Function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame{
            startGame()
            
        }else if currentGameState == gameState.inGame{
            fire_bullet()
        }
    }
    
    //Move player on drag Function
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousTouchPoint = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousTouchPoint.x
            
            print("tapped")
            
            if currentGameState == gameState.inGame{
                player.position.x  += amountDragged
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
    
    
    
    //Update function for scrolling background
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMove: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMove * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background", using: {
            background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        })
        
    }
    
    
    
}
