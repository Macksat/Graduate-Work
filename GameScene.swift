//
//  GameScene.swift
//  GraduateWork
//
//  Created by Sato Masayuki on 2022/06/28.
//

import SpriteKit
import GameplayKit
import AudioToolbox

enum ZPositions: Int {
    case background
    case effect
    case foreground
    case player
    case playerParts
    case textBox
    case text
    case otherNodes
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var textRec: SKShapeNode?
    
    override func didMove(to view: SKView) {
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// 暗い部屋を用意して没入かんを高める
//研究の目的をまず紹介する
// コンテンツのテーマで研究の目的がつぶれないようにする
// >スポーツ、テトリス、ゲーム、
// 没入かんの測定方法
//　＞脳波、アンケート、アイトラッキング、身体の反応（心拍数など）
// エフェクト、インタラクションの有無による比較
// >比較試験
//　没入かんを図る項目を考える
