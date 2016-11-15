//
//  GameplayScene.swift
//  Cowboy Runner
//
//  Created by Fahir Mehovic on 3/12/16.
//  Copyright © 2016 Awesome Tuts. All rights reserved.
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    var player = Player();
    
    var obstacles = [SKSpriteNode]();
    
    var canJump = false;
    
    var movePlayer = false;
    var playerOnObstacle = false;
    
    var isAlive = false;
    
    var spawner = Timer();
    var counter = Timer();
    
    var scoreLabel = SKLabelNode();
    
    var score = Int(0);
    
    var pausePanel = SKSpriteNode();
    
    var gamePaused = false;
    
    override func didMove(to view: SKView) {
        initialize();
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isAlive {
            moveBackgroundsAndGrounds();
        }
        
        if movePlayer {
            player.position.x -= 9;
        }
        
        checkPlayersBounds();
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            
            let location = touch.location(in: self);
            
            if atPoint(location).name == "Restart" {
                let gameplay = GameplayScene(fileNamed: "GameplayScene");
                gameplay!.scaleMode = .aspectFill;
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)));
            }
            
            if atPoint(location).name == "Quit" {
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene");
                mainMenu!.scaleMode = .aspectFill;
                self.view?.presentScene(mainMenu!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)));
            }
            
            if atPoint(location).name == "Pause" {
                createPausePanel();
            }
            
            if atPoint(location).name == "Resume" {
                pausePanel.removeFromParent();
                self.scene?.isPaused = false;
                
                spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(2.5, secondNumber: 6)), target: self, selector: #selector(GameplayScene.spawnObstacles), userInfo: nil, repeats: true);
                
                counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameplayScene.incrementScore), userInfo: nil, repeats: true);
                
                Timer.scheduledTimer(timeInterval: TimeInterval(0.4), target: self, selector: #selector(GameplayScene.unPauseGame), userInfo: nil, repeats: false);
                
            }
            
            if atPoint(location).name == "Quit" {
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene");
                mainMenu!.scaleMode = .aspectFill;
                self.view?.presentScene(mainMenu!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)));
            }
            
        }
        
        if !gamePaused {
            if canJump {
                canJump = false;
                player.jump();
            }
            
            if playerOnObstacle {
                player.jump();
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" {
            canJump = true;
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            
            if !canJump {
                movePlayer = true;
                playerOnObstacle = true;
            }
            
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Cactus" {
            // kill the player and promt the buttons
            playerDied();
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            movePlayer = false;
            playerOnObstacle = false;
        }
        
    }
    
    func initialize() {
        
        physicsWorld.contactDelegate = self;
        
        isAlive = true;
        
        createPlayer();
        createBG();
        createGrounds();
        createObstales();
        getLabel();
        
       spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(2.5, secondNumber: 6)), target: self, selector: #selector(GameplayScene.spawnObstacles), userInfo: nil, repeats: true);
        
        counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameplayScene.incrementScore), userInfo: nil, repeats: true);
        
    }
    
    func createPlayer() {
        player = Player(imageNamed: "Player 1");
        player.initialize();
        player.position = CGPoint(x: -10, y: 20);
        self.addChild(player);
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG");
            bg.name = "BG";
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0);
            bg.zPosition = 0;
            self.addChild(bg);
        }
    }
    
    func createGrounds() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "Ground");
            bg.name = "Ground";
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2));
            bg.zPosition = 3;
            bg.physicsBody = SKPhysicsBody(rectangleOf: bg.size);
            bg.physicsBody?.affectedByGravity = false;
            bg.physicsBody?.isDynamic = false;
            bg.physicsBody?.categoryBitMask = ColliderType.Ground;
            self.addChild(bg);
        }
    }
    
    func moveBackgroundsAndGrounds() {
        
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode;
            
            bgNode.position.x -= 4;
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3;
            }
            
        }));
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode;
            
            bgNode.position.x -= 2;
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3;
            }
            
        }));
        
    }
    
    func createObstales() {
        
        for i in 0...5 {
            
            let obstacle = SKSpriteNode(imageNamed: "Obstacle \(i)");
            
            if i == 0 {
                obstacle.name = "Cactus";
                obstacle.setScale(0.4);
            } else {
                obstacle.name = "Obstacle";
                obstacle.setScale(0.5);
            }
            
            obstacle.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            obstacle.zPosition = 1;
            
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size);
            obstacle.physicsBody?.allowsRotation = false;
            obstacle.physicsBody?.categoryBitMask = ColliderType.Obstacle;
            
            obstacles.append(obstacle);
        }
        
    }
    
    func spawnObstacles() {
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count)));
        
        let obstacle = obstacles[index].copy() as! SKSpriteNode;
        
        obstacle.position = CGPoint(x: self.frame.width + obstacle.size.width, y: 50);
        
        let move = SKAction.moveTo(x: -(self.frame.size.width * 2), duration: TimeInterval(15));
        
        let remove = SKAction.removeFromParent();
        
        let sequence = SKAction.sequence([move, remove]);
        
        obstacle.run(sequence);
        
        self.addChild(obstacle);
    }
    
    func randomBetweenNumbers(_ firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
        
        // arc4random returns a number between 0 to (2**32)-1
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber);
        
    }
    
    func checkPlayersBounds() {
        if isAlive {
            if player.position.x < -(self.frame.size.width / 2) - 35 {
                playerDied();
            }
        }
    }
    
    func getLabel() {
        scoreLabel = self.childNode(withName: "Score Label") as! SKLabelNode;
        scoreLabel.text = "0M";
    }
    
    func incrementScore() {
        score += 1;
        scoreLabel.text = "\(score)M"
    }
    
    func createPausePanel() {
        
        gamePaused = true;
        
        spawner.invalidate();
        counter.invalidate();
        
        self.scene?.isPaused = true;
        
        pausePanel = SKSpriteNode(imageNamed: "Pause Panel");
        pausePanel.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        pausePanel.position = CGPoint(x: 0, y: 0);
        pausePanel.zPosition = 10;
        
        let resume = SKSpriteNode(imageNamed: "Play");
        let quit = SKSpriteNode(imageNamed: "Quit");
        
        resume.name = "Resume";
        resume.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        resume.position = CGPoint(x: -155, y: 0);
        resume.setScale(0.75);
        resume.zPosition = 9;
        
        quit.name = "Quit";
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        quit.position = CGPoint(x: 155, y: 0);
        quit.setScale(0.75);
        quit.zPosition = 9;
        
        pausePanel.addChild(resume);
        pausePanel.addChild(quit);
        
        self.addChild(pausePanel);
        
    }
    
    func playerDied() {
        
        let highscore = UserDefaults.standard.integer(forKey: "Highscore");
        
        if highscore < score {
            UserDefaults.standard.set(score, forKey: "Highscore");
        }
        
        player.removeFromParent();
        
        for child in children {
            if child.name == "Obstacle" || child.name == "Cactus" {
                // if either of these are true we will execute this if statement
                child.removeFromParent();
            }
        }
        
        spawner.invalidate();
        counter.invalidate();
        
        isAlive = false;
        
        let restart = SKSpriteNode(imageNamed: "Restart");
        let quit = SKSpriteNode(imageNamed: "Quit");
        
        restart.name = "Restart";
        restart.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        restart.position = CGPoint(x: -200, y: -150);
        restart.zPosition = 10;
        restart.setScale(0);
        
        quit.name = "Quit";
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        quit.position = CGPoint(x: 200, y: -150);
        quit.zPosition = 10;
        quit.setScale(0);
        
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval(0.5));
        
        restart.run(scaleUp);
        quit.run(scaleUp);
        
        self.addChild(restart);
        self.addChild(quit);
        
    }
    
    func unPauseGame() {
        gamePaused = false;
    }
    
}






































