//
//  GameScene.swift
//  Bird
//
//  Created by Bookman on 2018/2/21.
//  Copyright © 2018年 Ware. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameStatus{
    case idle   //初始化状态
    case running //游戏中
    case over    //游戏结束
    
}

let birdCategory:UInt32 = 0x1<<0
let pipeCategory:UInt32 = 0x1<<1
let floorCategory:UInt32 = 0x1<<2


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var floor1:SKSpriteNode!
    var floor2:SKSpriteNode!
    var bird:Bird!
    var gameStatus:GameStatus = .idle    //点的含义是省略的类型名
    lazy var gameStartLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed:"Chalkduster")
        label.text = "Start"
        label.fontSize = 65
        label.fontColor = SKColor.black
        label.position = CGPoint(x: frame.midX, y: frame.midY+80)
        return label
    }()
    lazy var gameOverLabel:SKLabelNode = { //lazy懒加载：只有第一次用时才初始化，而不是创建scene类时
        let label = SKLabelNode(fontNamed:"Chalkduster")
        label.text = "Game Over"
        label.fontSize = 65
        label.fontColor = SKColor.black
        
        return label
    }()
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.blue
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        
        
        addChild(gameStartLabel)
        
        floor1 = SKSpriteNode(imageNamed:"floor")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)//注意设置了新锚点,SKScene场景的默认锚点为(0,0)即左下角，SKSpriteNode的默认锚点为(0.5,0.5)即它的中心点
        floor1.position = CGPoint(x:0,y:0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "floor")
        floor2.anchorPoint = CGPoint(x:0,y:0)
        floor2.position = CGPoint(x:floor1.size.width,y:0)
        addChild(floor2)
        
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
        floor1.physicsBody?.categoryBitMask = floorCategory
        
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
        floor2.physicsBody?.categoryBitMask = floorCategory
        
        
        bird = Bird()
        addChild(bird)
        
        bird.physicsBody = SKPhysicsBody(texture:bird.texture!,size:bird.size)
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = floorCategory | pipeCategory
        
        
        
        shuffle()
        
    }
    
    func shuffle(){
        //游戏初始化处理方法
        gameStatus = .idle
        removeAllPipesNode()
        bird.position = CGPoint(x: frame.midX, y: frame.midY)
        bird.physicsBody?.isDynamic = false
        birdStartFly()
        
    }



    func startGame(){
        //游戏开始处理方法
        gameStatus = .running
        gameStartLabel.removeFromParent()
        bird.physicsBody?.isDynamic = true//是否会受到物理环境
        startCreateRandomPipesAction()
        
    }

    func gameOver(){
        //游戏结束处理方法
        gameStatus = .over
        birdStopFly()
        stopCreateRandomPipesAction()
        isUserInteractionEnabled = false //禁止用户点击屏幕
        addChild(gameOverLabel)
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height)
        gameOverLabel.run(SKAction.move(by: CGVector(dx:0,dy:-self.size.height*0.5), duration: 0.5),completion:{
            self.isUserInteractionEnabled = true
        })
        
    }

    //点击屏幕触发事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameStatus {
        case .idle:
            startGame()
        case .running:
            bird.physicsBody?.applyImpulse(CGVector(dx:0,dy:20))
        case .over:
            shuffle()
        }
    }


    func birdStartFly(){

        bird.Fly()
        
        
    }

    func birdStopFly(){
        bird.removeAction(forKey: "fly")
    }

    func startCreateRandomPipesAction(){
        
         //创建一个等待的action,等待时间的平均值为3.5秒，变化范围为1秒
        let waitAct = SKAction.wait(forDuration: 3.5,withRange:1.0)
        
        let generatePipeAct = SKAction.run {
            self.createRandomPipes()
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([waitAct,generatePipeAct])),withKey:"createPipe")
        
    }
    
    func stopCreateRandomPipesAction(){
        
        self.removeAction(forKey: "createPipe")
    }
    
    func createRandomPipes(){
        
        let height = self.size.height-self.floor1.size.height
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*3
        let pipeWidth = CGFloat(60.0)
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height-pipeGap)))
        let bottomipeHeight = height-pipeGap-topPipeHeight
        addPipes(topSize: CGSize(width:pipeWidth,height:topPipeHeight), bottomSize: CGSize(width: pipeWidth, height: bottomipeHeight))
        
        
    }
    
    func addPipes(topSize:CGSize,bottomSize:CGSize){
        
        let topTexture = SKTexture(imageNamed: "topPipe")
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        topPipe.name = "pipe"
        topPipe.position = CGPoint(x: self.size.width+topPipe.size.width*0.5, y: self.size.height-topPipe.size.height*0.5)
        
        let bottomTexture = SKTexture(imageNamed: "bottomPipe")
        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
        bottomPipe.name = "pipe"
        bottomPipe.position = CGPoint(x: self.size.width+bottomPipe.size.width*0.5, y: self.floor1.size.height+bottomPipe.size.height*0.5)
        
        topPipe.physicsBody = SKPhysicsBody(texture:topTexture,size:topSize)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        bottomPipe.physicsBody = SKPhysicsBody(texture:bottomTexture,size:bottomSize)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        
        addChild(topPipe)
        addChild(bottomPipe)
        
    }
    
    func removeAllPipesNode(){
        //循环检查场景的子节点，同时这个子节点的名字要为pipe
        for pipe in self.children where pipe.name == "pipe"{
            pipe.removeFromParent()
        }
        gameOverLabel.removeFromParent()
        
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStatus != .running{return}
        
        //物体的碰撞与锚点有关
        var bodyA:SKPhysicsBody
        var bodyB:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        }
        else{
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        if bodyA.categoryBitMask == birdCategory && (bodyB.categoryBitMask == pipeCategory ||  bodyB.categoryBitMask == floorCategory){
            
            gameOver()
        }
        
    }
    
    
    func moveScene(){
        
        floor1.position = CGPoint(x: floor1.position.x-2, y: floor1.position.y)
        floor2.position = CGPoint(x:floor2.position.x-2,y:floor2.position.y)
        
        if floor1.position.x < -floor1.size.width{
            floor1.position = CGPoint(x:floor2.position.x+floor2.size.width,y:floor1.position.y)
            
        }
        
        if floor2.position.x < -floor2.size.width{
            floor2.position = CGPoint(x:floor1.position.x+floor1.size.width,y:floor2.position.y)
        }
        
        for pipeNode in self.children where pipeNode.name == "pipe"{
            
            if let pipeSprite = pipeNode as? SKSpriteNode{
                pipeSprite.position = CGPoint(x:pipeSprite.position.x-2,y:pipeSprite.position.y)
                
                if pipeSprite.position.x < -pipeSprite.size.width*0.5{
                    pipeSprite.removeFromParent()
                }
            }
        }
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
       // update()方法为SKScene自带的系统方法，在画面每一帧刷新的时候就会调用一次
        
        self.moveScene()
 
    }
}




