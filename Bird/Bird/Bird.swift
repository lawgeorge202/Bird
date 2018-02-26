//
//  Bird.swift
//  Bird
//
//  Created by Bookman on 2018/2/22.
//  Copyright © 2018年 Ware. All rights reserved.
//

import UIKit
import SpriteKit


class Bird: SKSpriteNode {

    //鸟的纹理集
    let dbAtlas = SKTextureAtlas(named: "Player.atlas")
    //鸟的纹理数组
    var dbFrames = [SKTexture]()
    
     init(){
        //获取纹理集第一个纹理
        let texture = dbAtlas.textureNamed("player1")
        //获得纹理尺寸
        let size = texture.size()
        super.init(texture:texture,color:SKColor.white,size:size)
        
        for i in dbAtlas.textureNames{
            dbFrames.append(dbAtlas.textureNamed(i))
        }
        
        
        //播放动画
        //self.Fly()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func Fly(){
        self.run(SKAction.repeatForever(SKAction.animate(with: dbFrames, timePerFrame: 0.07)),withKey:"fly")
    }
    
}
