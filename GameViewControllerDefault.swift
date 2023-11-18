//
//  GameViewControllerDefault.swift
//  GraduateWork
//
//  Created by Sato Masayuki on 2022/11/11.
//

import UIKit
import SpriteKit
import GameplayKit
import GameController
import MultipeerConnectivity
import CoreMotion
import AudioToolbox
import AVFoundation

class GameViewControllerDefault: UIViewController, AVAudioPlayerDelegate {
    
    private let motionManager = CMMotionManager()
    private let serviceType = "controller"
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    private let bgmArray: [[String]] = [
        ["rocketBGM", "engineSound"],
        ["rocketBGM"],
        ["allMyTears_onEarth"],
        ["none", "mukishitsu_inDanger"],
        ["shuyu_galaxy"]
    ]
    private let backgroundImages: [[SKSpriteNode]] = [
        [SKSpriteNode(imageNamed: "meadow"), SKSpriteNode(imageNamed: "sputnik2")],
        [SKSpriteNode(imageNamed: "earthImage"), SKSpriteNode(imageNamed: "sputnik2")],
        [SKSpriteNode(imageNamed: "earth1"), SKSpriteNode(imageNamed: "earth2")],
        [SKSpriteNode(imageNamed: "earthImage"), SKSpriteNode(imageNamed: "sputnik2")],
        [SKSpriteNode(imageNamed: "universe1"), SKSpriteNode(imageNamed: "universe2"),
         SKSpriteNode(imageNamed: "universe3"), SKSpriteNode(imageNamed: "universe4")]
    ]
    private let texts: [[(text: String, bubble: String, font: UIFont.Weight)]] = [
        [("私は今、狭い部屋の中にいる。", "rectangle", .regular), ("ほんの少しだけ隙間があり、多少前後に移動することはできるけど、\nそれくらいしか動けないので窮屈である。", "rectangle", .regular), ("普段も狭い空間に長時間座らされる訓練をしているけど、今回もそれと同じ訓練なのだろうか？", "rectangle", .regular), ("そんなことを考えていると、外からカウントダウンが始まった。", "rectangle", .regular), ("何のカウントダウンなのだろう？", "circle", .regular), ("今は訓練の前段階で、これから始まるってこと？", "circle", .regular), ("その瞬間、凄まじい轟音と振動が私を襲った。", "rectangle", .regular), ("こんなに激しい振動は、今まで体験したことがない。", "rectangle", .regular), ("これからどうなるの？", "wave", .regular), ("私、死んじゃうの？", "wave", .regular), ("怖いよ...ここから出して...！", "wave", .medium), ("誰か...誰か助けて！！", "spike", .bold)],
        [("しばらくすると、轟音も振動も鳴り止んでいた。", "rectangle", .regular), ("恐怖のあまり瞑っていた目を開けると、外が暗くなっていることに気づいた。", "rectangle", .regular), ("え...？さっきまで明るかったのに、どうして？", "polygon", .regular), ("外は今どうなっているんだろう？確かめなくちゃ。", "circle", .regular)],
        [("外を見ると、そこには真っ暗な空と小さく輝く沢山の星、そして大きな青い球体があった。", "rectangle", .regular), ("うわぁ...綺麗！", "flower", .medium), ("こんなに大きな球体、今まで見たことがない。", "circle", .regular), ("私たちが住む地球にこんなにも大きな球体なんてあっただろうか？", "circle", .regular), ("だとしたらとっくの昔に気づいていたはずなのに...", "circle", .regular), ("あれ？そう言えばここはどこなのだろうか？", "circle", .regular), ("だって今の時間空はまだ明るいはずだし、地面だって見えるはず。", "circle", .regular), ("地面...？", "circle", .regular), ("そう言えばさっき大きな振動が鳴っていた時、私は空に飛ばされていたような...", "circle", .regular), ("ということは、今見えている球体の場所に地面があるはず。", "circle", .regular), ("えっ？それってつまり、この青い球体は地球ってこと！？", "polygon", .medium), ("それが本当だとすると、地球は青くて巨大な球体ってことなの？", "polygon", .medium), ("私たちが住んでいる場所が、こんなにも美しいとは思ってもいなかった。", "flower", .regular), ("もしかして、この美しい地球の姿を見たのは私が初めてなのではないだろうか？", "circle", .regular), ("だとしたら、少し誇らしい気分だ。", "flower", .regular), ("帰ったらみんなに伝えたいな。", "flower", .regular)],
        [("...それにしても、少し暑いな。", "circle", .regular), ("さっきから徐々に体が熱くなってきているのを感じる。", "rectangle", .regular), ("それに、息苦しいな。", "circle", .regular), ("もっと広いところでリラックスしたいけど、ここにはこの狭い部屋しかない。", "rectangle", .regular), ("はぁ...はぁ...はぁ...", "wave", .thin), ("暑い...苦しい...", "wave", .thin), ("心拍数がだんだん上がっていくのを感じる。", "rectangle", .regular), ("いくら今まで過酷な訓練を受けてきたとはいえ、流石にこれはきつい。", "rectangle", .regular), ("水が飲みたい...涼しい風に当たりたい...", "wave", .thin), ("あれ...？ぼーっとしてきた。", "wave", .thin), ("視界も狭まってきているような気がする。", "wave", .thin), ("もしかして私、死ぬのかな？", "wave", .thin), ("この狭い部屋で一人、死ぬのかな？", "wave", .thin), ("でも、それでも。", "circle", .regular), ("最後にあんなに美しい地球が見られてよかった。", "flower", .regular), ("この景色を見ながら死んでゆく私はきっと幸せ者だ。", "flower", .regular), ("死ぬ前に、もっとこの景色を眺めていたいな。", "circle", .regular), ("もっと...もっと...", "circle", .thin)],
        [("気がつくと、そこには星がたくさん輝いていた。", "rectangle", .regular), ("なんて、綺麗なんだろう...！", "flower", .medium), ("これは夢なのかな？だって、さっきまで意識が朦朧としていたし。", "circle", .regular), ("でも、夢だとしても、こんなに美しい景色が見られて良かった。", "flower", .regular), ("これから死ぬのだとしても、そんなことなんてどうでもよくなるくらい気分がいい。", "flower", .regular), ("今まで過酷な訓練ばっかりの人生だったけど、それがこの景色を見るためのものだったと考えると、\n悪くない人生だったな。", "circle", .regular), ("ねえ、みんな見てる？", "circle", .medium), ("宇宙は、こんなにも綺麗なんだよ。", "circle", .medium), ("どんなに悩んでいたり、苦しんだりしていても、\nこの景色を前にしたらそんなことがちっぽけに思えるくらい。", "circle", .medium), ("生きてて良かった。そう思えるくらい。", "circle", .medium), ("どうかみんなに、それが伝わりますように。", "circle", .medium)]
    ]
    let beforeUniverseIndex = 0
    let countDown = 3
    let rocketVibrated = 6
    let atUniverseIndex = 1
    let earthIndex = 2
    let dangerIndex = 3
    let startDanger = 4
    let almostDeath = 12
    let universeIndex = 4
    var sceneIndex = 0
    var textIndex = 0
    var bgmIndex = 0
    var tapCount = 0
    let scene = SKScene(fileNamed: "GameScene")
    var blackScreen = SKShapeNode()
    var alertNode = SKNode()
    let ud = UserDefaults.standard
    var addObjectBool = true
    var tapInterval = true
    var accelIntervalX = true
    var accelIntervalY = true
    var accelIntervalZ = true
    var sceneChanged = false
    var fadeChanged = false
    private var label : SKLabelNode?
    var textBubble: SKNode?
    var lightTimer = Timer()
    var player: AVAudioPlayer?
    var player2: AVAudioPlayer?
    var titleIsShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = self.scene {
                scene.scaleMode = .aspectFill
                scene.backgroundColor = .black
                view.presentScene(scene)
                
                titleIsShown = true
                showTitlePage()
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func showTitlePage() {
        sceneIndex = 0
        textIndex = 0
        tapCount = 0
        bgmIndex = 0
                
        if let scene = self.scene {
            blackScreen = SKShapeNode(rect: CGRect(x: -scene.size.width / 2, y: -scene.size.height / 2, width: scene.size.width, height: scene.size.height))
            blackScreen.fillColor = .black
            blackScreen.strokeColor = .clear
            blackScreen.zPosition = CGFloat(ZPositions.otherNodes.rawValue)
            blackScreen.alpha = 1.0
            scene.addChild(blackScreen)
            
            let i = SKSpriteNode(imageNamed: "title")
            i.size = CGSize(width: scene.size.width + 200, height: (scene.size.width + 200) * i.size.height / i.size.width)
            i.zPosition = CGFloat(Float(ZPositions.background.rawValue))
            scene.addChild(i)
            if let black = scene.children.first(where: { $0 == blackScreen }) {
                black.run(.fadeOut(withDuration: 0.5))
                sceneChanged = false
            }
        }
    }
    
    func goContent() {
        if let scene = self.scene {
            if let black = scene.children.first(where: { $0 == blackScreen }) {
                black.run(.fadeIn(withDuration: 0.5))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let i = scene.children.first(where: { $0 == SKSpriteNode(imageNamed: "title") }) { 
                    scene.removeChildren(in: [i])
                }
                
                for (index, i) in self.backgroundImages[self.sceneIndex].enumerated() {
                    i.size = CGSize(width: scene.size.width, height: scene.size.width * i.size.height / i.size.width)
                    i.zPosition = CGFloat(Float(ZPositions.background.rawValue) + 0.1 * Float((index + 1)))
                    scene.addChild(i)
                }
                
                self.playAudio(name: self.bgmArray[self.bgmIndex][0])
                self.appearTextBox()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.blackScreen.run(SKAction.fadeOut(withDuration: 0.5))
                    self.sceneChanged = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.changeLabel()
                    }
                }
            }
        }
    }
    
    func appearTextBox() {
        if let scene = self.scene {
            guard let label = scene.childNode(withName: "//helloLabel") as? SKLabelNode else { return }
            guard let rec = scene.childNode(withName: "//textRectangle") as? SKShapeNode else { return }
            
            label.alpha = 0.0
            label.zPosition = CGFloat(ZPositions.text.rawValue)
            label.fontColor = .white
            label.text = ""
            
            rec.alpha = 0.0
            rec.zPosition = CGFloat(ZPositions.textBox.rawValue)
            rec.fillColor = .black.withAlphaComponent(0.5)
            rec.strokeColor = .clear
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                label.run(SKAction.fadeIn(withDuration: 0.5))
                rec.run(SKAction.fadeIn(withDuration: 0.5))
            }
            
            rec.fillColor = .black.withAlphaComponent(0.5)
            rec.strokeColor = .black.withAlphaComponent(0.5)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @objc func timerFunc() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @objc func lightFunc() {
        if let scene = self.scene {
            if let earth = scene.children.filter( { $0 == backgroundImages[earthIndex][1] } ).first {
                if let lightNode = earth.children.first as? SKLightNode {
                    lightNode.lightColor = UIColor(red: 1, green: 1, blue: 1, alpha: CGFloat.random(in: 0.93...1.0))
                }
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if let _ = GCKeyboard.coalesced?.keyboardInput {
            if sceneChanged == false, tapInterval {
                if titleIsShown {
                    titleIsShown = false
                    sceneChanged = true
                    goContent()
                } else {
                    changeLabel()
                }
                
                tapInterval = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tapInterval = true
                }
            }
        }
    }
    
    func changeLabel() {
        if let scene = self.scene {
            self.label = scene.childNode(withName: "//helloLabel") as? SKLabelNode
            if let label = self.label {
                label.run(SKAction.fadeOut(withDuration: 0.3))
                if self.textIndex < self.texts[sceneIndex].count {
                    if sceneIndex == beforeUniverseIndex {
                        if textIndex == countDown {
                        } else if textIndex == rocketVibrated {
                            playAudio2(name: bgmArray[bgmIndex][1])
                        }
                    } else if sceneIndex == dangerIndex {
                        if textIndex == startDanger {
                            playAudio2(name: bgmArray[bgmIndex][1])
                        } else if textIndex == texts[dangerIndex].count - 5 {
                            alertNode.run(SKAction.fadeAlpha(to: 0.0, duration: 0.5))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                scene.removeChildren(in: [self.alertNode])
                            }
                            stopAudio()
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if self.textIndex < self.texts[self.sceneIndex].count {
                            label.text = self.texts[self.sceneIndex][self.textIndex].text
                            self.textIndex += 1
                        }
                        
                        label.run(SKAction.fadeIn(withDuration: 0.3))
                    }
                } else {
                    sceneChanged = true
                    if let rec = scene.childNode(withName: "//textRectangle") as? SKShapeNode {
                        rec.run(SKAction.fadeOut(withDuration: 1))
                    }
                    
                    for i in scene.children {
                        if i == blackScreen {
                            i.run(SKAction.fadeAlpha(to: 1.0, duration: 1))
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.textIndex = 0
                        self.stopAudio()
                        self.bgmIndex += 1
                        self.lightTimer.invalidate()
                        for (index, i) in self.backgroundImages[self.sceneIndex].enumerated() {
                            if self.sceneIndex == self.earthIndex && index == 1 {
                                i.removeAllChildren()
                            }
                            i.setScale(CGFloat(1))
                        }
                        scene.removeChildren(in: self.backgroundImages[self.sceneIndex])
                        if self.sceneIndex < self.backgroundImages.count - 1 {
                            self.sceneIndex += 1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.changeScene()
                            }
                        } else {
                            // go title.
                            scene.removeChildren(in: [self.blackScreen])
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showTitlePage()
                                self.titleIsShown = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func changeScene() {
        let waitTime = TimeInterval(0.3)
        if let scene = self.scene {
            for (index, i) in backgroundImages[sceneIndex].enumerated() {
                i.size = CGSize(width: scene.size.width + 200, height: (scene.size.width + 200) * i.size.height / i.size.width)
                
                if sceneIndex == earthIndex && index == 1 {
                    let light = SKLightNode()
                    light.position = CGPoint(x: scene.position.x, y: scene.position.y)
                    light.categoryBitMask = 1
                    light.falloff = 0.01
                    light.ambientColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
                    light.zPosition = CGFloat(Float(ZPositions.background.rawValue) + 0.1 * Float((index + 2)))
                    
                    i.addChild(light)
                    i.lightingBitMask = 1
                    
                    lightTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(lightFunc), userInfo: nil, repeats: true)
                    
                    i.zPosition = CGFloat(Float(ZPositions.background.rawValue) + 0.1 * Float((index + 1)))
                    scene.addChild(i)
                } else {
                    i.zPosition = CGFloat(Float(ZPositions.background.rawValue) + 0.1 * Float((index + 1)))
                    scene.addChild(i)
                }
            }
            
            for i in scene.children {
                if i == blackScreen {
                    i.run(SKAction.fadeAlpha(to: 0.0, duration: 1))
                }
            }
            
            playAudio(name: bgmArray[bgmIndex][0])
            if bgmIndex == 1 {
                player?.volume = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sceneChanged = false
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    if let textBox = scene.childNode(withName: "//textRectangle") as? SKShapeNode {
                        textBox.run(SKAction.fadeIn(withDuration: 0.5))
                    }
                    self.changeLabel()
                }
            }
        }
    }
    
    func playAudio(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("file not found")
            return
        }
        do {
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.player?.volume = 1.0
            self.player?.numberOfLoops = -1
            self.player?.play()
        } catch let error as NSError {
            // if self.player is nil
            print("Error: " + error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func playAudio2(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("file not found")
            return
        }
        do {
            self.player2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.player2?.delegate = self
            self.player2?.prepareToPlay()
            self.player2?.volume = 1.0
            self.player2?.numberOfLoops = -1
            self.player2?.play()
        } catch let error as NSError {
            // if self.player is nil
            print("Error: " + error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func stopAudio() {
        UIView.transition(with: self.view, duration: 1) {
            self.player?.volume = 0.0
            self.player2?.volume = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.player?.stop()
            self.player = AVAudioPlayer()
            self.player2?.stop()
            self.player2 = AVAudioPlayer()
        }
    }
}

