//
//  GameViewContnrollerNoBubble.swift
//  GraduateWork
//
//  Created by Sato Masayuki on 2022/10/19.
//

import UIKit
import SpriteKit
import GameplayKit
import GameController
import MultipeerConnectivity
import CoreMotion
import AudioToolbox
import AVFoundation

class GameViewControllerNoBubble: UIViewController, AVAudioPlayerDelegate {
    
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
    var forwardCount = 1
    var countDownCount = 0
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
    var labelArray = ["5", "4", "3", "2", "1", "0"]
    var button = UIButton()
    var image1 = UIImageView()
    var image2 = UIImageView()
    var messageLabel = UILabel()
    var fadeTimer = Timer()
    var countDownTimer = Timer()
    var vibrateTimer = Timer()
    var goAheadTimer = Timer()
    var lightTimer = Timer()
    var goSignTimer = Timer()
    var player: AVAudioPlayer?
    var player2: AVAudioPlayer?
    var titleIsShown = false
    
    private var externalWindow: UIWindow?
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addExternalDisplay(notification:)),
            name: UIScreen.didConnectNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(removeExternalDisplay(notification:)),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )
    }
    
    @objc func addExternalDisplay(notification : Notification) {

        guard let newScreen = notification.object as? UIScreen else {
            return
        }

        let screenDimensions = newScreen.bounds
        let newWindow = UIWindow(frame: screenDimensions)

        newWindow.screen = newScreen
        self.view.frame = newWindow.frame
        newWindow.addSubview(self.view)
        newWindow.isHidden = false

        // window を破棄させないため プロパティに保持
        externalWindow = newWindow
    }

    @objc func removeExternalDisplay(notification : Notification) {
        externalWindow = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tappedFunc), name: NSNotification.Name(rawValue: "tap"), object: nil)
        
        let peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: self.serviceType)
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
        
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: self.serviceType)
        self.browser.delegate = self
        self.browser.startBrowsingForPeers()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            image1.image = UIImage(named: "shakingGesture1") ?? UIImage()
            image2.image = UIImage(named: "shakingGesture2") ?? UIImage()
            image1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            image2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            image1.backgroundColor = .darkGray
            image2.backgroundColor = .darkGray
            image1.alpha = 0.0
            image2.alpha = 0.0
            
            messageLabel.text = "スマホを前後に振ってください"
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 4)
            messageLabel.alpha = 0.0
            
            button.setTitle("画面をタップ", for: .normal)
            button.backgroundColor = .systemGray4
            button.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            button.addTarget(self, action: #selector(buttonFunc), for: .touchUpInside)
            self.view.addSubview(button)
            
            startMotion()
        } else {
            setupNotificationCenter()
            
            if let view = self.view as! SKView? {
                if let scene = self.scene {
                    scene.scaleMode = .aspectFill
                    scene.backgroundColor = .black
                    view.presentScene(scene)
                    
                    showTitlePage()
                    titleIsShown = true
                }
                
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }
    
    func showTitlePage() {
        sceneIndex = 0
        textIndex = 0
        tapCount = 0
        bgmIndex = 0
        forwardCount = 1
        countDownCount = 0
                
        if let scene = self.scene {
            blackScreen = SKShapeNode(rect: CGRect(x: -scene.size.width / 2, y: -scene.size.height / 2, width: scene.size.width, height: scene.size.height))
            blackScreen.fillColor = .black
            blackScreen.strokeColor = .clear
            blackScreen.zPosition = CGFloat(ZPositions.otherNodes.rawValue)
            blackScreen.alpha = 1.0
            scene.addChild(blackScreen)
            
            let i = SKSpriteNode(imageNamed: "title2")
            i.size = CGSize(width: scene.size.width, height: scene.size.width * i.size.height / i.size.width)
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
                    i.size = CGSize(width: scene.size.width + 200, height: (scene.size.width + 200) * i.size.height / i.size.width)
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
        // たまに切れない時があるのでここで切断
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        session.disconnect()
        
        stopMotion()
    }
    
    @objc func timerFunc() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @objc func buttonFunc() {
        let message = "tapped"
        do {
            try session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            AudioServicesPlaySystemSound(1519)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func tappedFunc() {
        if titleIsShown {
            titleIsShown = false
            sceneChanged = true
            goContent()
        } else {
            changeLabel()
        }
    }
    
    @objc func xFunc() {
        //goForwardAnimation(nodes: backgroundImages[sceneIndex], scale: 1.0 + 0.1 * CGFloat(forwardCount), duration: 0.7)
        //vibrateScreen()
        //addObject()
        //punch()
    }
    
    @objc func yFunc() {
        //addObject()
    }
    
    @objc func zFunc() {
        //changeLabel()
    }
    
    @objc func fadeInOutAnimation() {
        if fadeChanged == false {
            alertNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
            sendSignal(signal: "inDanger")
        } else {
            alertNode.run(SKAction.fadeAlpha(to: 0.2, duration: 0.5))
            sendSignal(signal: "inDanger")
        }
        fadeChanged.toggle()
    }
    
    @objc func intervalVibration() {
        vibrateScreen()
        sendSignal(signal: "vibration")
    }
    
    @objc func countDownFunc() {
        if countDownCount < labelArray.count - 1 {
            let text = SKLabelNode()
            text.text = labelArray[countDownCount]
            addObject(node: text)
            sendSignal(signal: "countDown")
            countDownCount += 1
        }
    }
    
    @objc func goAhead() {
        if forwardCount == 4 {
            textIndex += 1
            changeLabel()
            goAheadTimer.invalidate()
            sendSignal(signal: "stopGoSign")
        }
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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if let keyboard = GCKeyboard.coalesced?.keyboardInput {
            if (keyboard.button(forKeyCode: .spacebar)?.isPressed ?? false) {
                changeLabel()
            } else if (keyboard.button(forKeyCode: .keyA)?.isPressed ?? false) {
                vibrateScreen()
            } else if (keyboard.button(forKeyCode: .keyS)?.isPressed ?? false) {
                //intervalAddObject()
            } else if (keyboard.button(forKeyCode: .keyD)?.isPressed ?? false) {
                //addObject()
            } else if (keyboard.button(forKeyCode: .keyE)?.isPressed ?? false) {
                //changeLabel()
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
                            countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownFunc), userInfo: nil, repeats: true)
                        } else if textIndex == rocketVibrated {
                            countDownTimer.invalidate()
                            let text = SKLabelNode()
                            text.text = labelArray.last!
                            addObject(node: text)
                            
                            vibrateTimer = Timer.scheduledTimer(timeInterval: 0.21, target: self, selector: #selector(intervalVibration), userInfo: nil, repeats: true)
                            
                            playAudio2(name: bgmArray[bgmIndex][1])
                        }
                    } else if sceneIndex == dangerIndex {
                        if textIndex == startDanger {
                            alertNode = alertScene()
                            scene.addChild(alertNode)
                            fadeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fadeInOutAnimation), userInfo: nil, repeats: true)
                            playAudio2(name: bgmArray[bgmIndex][1])
                        } else if textIndex == texts[dangerIndex].count - 5 {
                            fadeTimer.invalidate()
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
                        
                        if self.sceneIndex == self.atUniverseIndex {
                            if self.textIndex == self.texts[self.atUniverseIndex].count {
                                self.sceneChanged = true
                                self.sendSignal(signal: "showGoSign")
                                self.goAheadTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.goAhead), userInfo: nil, repeats: true)
                            }
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
                        self.vibrateTimer.invalidate()
                        self.goAheadTimer.invalidate()
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
                            for i in scene.children {
                                if i != scene.childNode(withName: "//helloLabel") as? SKLabelNode && i != scene.childNode(withName: "//textRectangle") as? SKShapeNode {
                                    scene.removeChildren(in: [i])
                                }
                            }
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
        var waitTime = TimeInterval(0.3)
        if let scene = self.scene {
            for (index, i) in backgroundImages[sceneIndex].enumerated() {
                i.size = CGSize(width: scene.size.width + 200, height: (scene.size.width + 200) * i.size.height / i.size.width)
                if sceneIndex == earthIndex || sceneIndex == universeIndex {
                    i.setScale(CGFloat(2 + index))
                }
                
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
                
                if self.sceneIndex == self.earthIndex || self.sceneIndex == self.universeIndex {
                    waitTime = TimeInterval(1.3)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let zoomOut = SKAction.scale(to: 1, duration: 2)
                        i.run(zoomOut)
                    }
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
    
    func alertScene() -> SKNode {
        if let scene = self.scene {
            let alertScreen = SKShapeNode(rect: CGRect(x: -scene.size.width / 2, y: -scene.size.height / 2, width: scene.size.width, height: scene.size.height))
            alertScreen.fillColor = .red.withAlphaComponent(0.5)
            alertScreen.strokeColor = .clear
            alertScreen.alpha = 0.0
            alertScreen.zPosition = CGFloat(ZPositions.effect.rawValue)
            
            return alertScreen
        }
        
        return SKNode()
    }
    
    func goForwardAnimation(nodes: [SKSpriteNode], scale: CGFloat, duration: TimeInterval) {
        if sceneIndex == atUniverseIndex && textIndex == texts[atUniverseIndex].count {
            for i in nodes {
                let zoomIn = SKAction.scale(to: scale, duration: duration)
                let moveUp = SKAction.moveTo(y: 20, duration: duration/2)
                let moveDown = SKAction.moveTo(y: 0, duration: duration/2)
                i.run(zoomIn)
                i.run(moveUp)
                DispatchQueue.main.asyncAfter(deadline: .now() + duration/2) {
                    i.run(moveDown)
                }
            }
            forwardCount += 1
            sendSignal(signal: "goForward")
        }
    }
    
    func vibrateScreen() {
        if let scene = self.scene {
            for i in scene.children {
                if i == backgroundImages[sceneIndex].filter({ $0 == i }).first {
                    for count in 0..<6 {
                        if count % 2 == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(count) * 0.03) {
                                i.position = CGPoint(x: 5, y: 7)
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(count) * 0.03) {
                                i.position = CGPoint(x: -5, y: -7)
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                        i.position = CGPoint(x: 0, y: 0)
                    }
                }
            }
        }
    }
    
    func vibrateObject(object: SKNode) {
        let position = object.position
        for i in 0..<6 {
            if i % 2 == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                    UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
                        object.position = CGPoint(x: position.x + 5.0, y: position.y + 5.0)
                    }, completion: nil)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                    UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
                        object.position = CGPoint(x: position.x - 5.0, y: position.y - 5.0)
                    }, completion: nil)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
            UIView.animate(withDuration: 0.015, delay: 0, options: .curveLinear, animations: {
                object.position = CGPoint(x: position.x, y: position.y)
            }, completion: nil)
        }
    }
    
    func addObject(node: SKLabelNode) {
        node.fontSize = 120
        node.fontName = "ArialMTBold"
        node.position = CGPoint(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -40...40))
        node.zPosition = CGFloat(ZPositions.player.rawValue)
        node.alpha = 1.0
        
        if let scene = self.scene {
            scene.addChild(node)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                node.run(SKAction.fadeOut(withDuration: 0.3))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    scene.removeChildren(in: [node])
                }
            }
        }
    }
    
    func intervalAddObject() {
        if addObjectBool {
            let label = SKLabelNode(fontNamed: "system")
            label.text = labelArray[Int.random(in: 0...labelArray.count-1)]
            label.fontSize = CGFloat(80)
            label.fontColor = UIColor.white
            label.position = CGPoint(x: CGFloat.random(in: 60 - self.view.frame.width/3...self.view.frame.width/3 - 60), y: CGFloat.random(in: 60 - self.view.frame.height/3...self.view.frame.height/3 - 60))
            label.zPosition = CGFloat(ZPositions.foreground.rawValue)
            label.alpha = 0.0
            
            if let scene = self.scene {
                scene.addChild(label)
                label.run(SKAction.fadeIn(withDuration: 0.5))
                label.run(SKAction.scale(by: 3, duration: 0.5))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    label.run(SKAction.fadeOut(withDuration: 0.5))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        scene.removeChildren(in: [label])
                    }
                }
            }
            
            addObjectBool.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.addObjectBool = true
            }
        }
    }
    
    func punch() {
        let emitter = SKEmitterNode(fileNamed: "SparkParticle")!
        emitter.position = CGPoint(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -40...40))
        emitter.zPosition = CGFloat(ZPositions.otherNodes.rawValue)
        
        if let scene = self.scene {
            scene.addChild(emitter)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                emitter.run(SKAction.fadeOut(withDuration: 0.15))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scene.removeChildren(in: [emitter])
                }
            }
        }
    }
    
    func startMotion() {
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.04
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (motionData, _: Error?) in
            self.motionManager.startGyroUpdates(to: OperationQueue.current!) { gyroData, err in
                self.updateMotionData(motionData: motionData!, gyroData: gyroData!)
            }
        }
    }
    
    func stopMotion() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    func updateMotionData(motionData: CMAccelerometerData, gyroData: CMGyroData) {
        let rx = motionData.acceleration.x
        let ry = motionData.acceleration.y
        let rz = motionData.acceleration.z
        let rdata = "\(rx)x,\(ry)y,\(rz)z,accel"
        let gx = gyroData.rotationRate.x
        let gy = gyroData.rotationRate.y
        let gz = gyroData.rotationRate.z
        let gdata = "\(gx)x,\(gy)y,\(gz)z,rotate"
        
        do {
            if abs(rx) > 1 {
                try session.send(rdata.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            if abs(ry) > 1 {
                try session.send(rdata.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                //AudioServicesPlaySystemSound(1521)
            }
            
            if abs(rz) > 1 {
                try session.send(rdata.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                //AudioServicesPlaySystemSound(1012)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        updateGyroData(gx: gx, gy: gy, gz: gz, gdata: gdata)
    }
    
    func updateGyroData(gx: Double, gy: Double, gz: Double, gdata: String) {
        do {
            try session.send(gdata.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendSignal(signal: String) {
        do {
            try session.send(signal.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send a signal.")
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

extension GameViewControllerNoBubble: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    private func notificate(message: String) {
        if message.contains("tapped") {
            if sceneChanged == false, tapInterval {
                tapInterval = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tap"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tapInterval = true
                }
            }
        } else if message.contains("countDown") {
            AudioServicesPlaySystemSound(1102)
        } else if message.contains("vibration") {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if message.contains("inDanger") {
            AudioServicesPlaySystemSound(1012)
        } else if message.contains("goForward") {
            AudioServicesPlaySystemSound(1521)
        } else if message.contains("showGoSign") {
            AudioServicesPlaySystemSound(1102)
            button.alpha = 0.0
            image1.alpha = 1.0
            messageLabel.alpha = 1.0
            goSignTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(showSign), userInfo: nil, repeats: true)
        } else if message.contains("stopGoSign") {
            button.alpha = 1.0
            image1.alpha = 0.0
            image2.alpha = 0.0
            messageLabel.alpha = 0.0
            goSignTimer.invalidate()
        } else if message.contains("accel") {
            let array = message.components(separatedBy: CharacterSet(charactersIn: ","))
            var x = array[0]
            x.removeLast(1)
            var y = array[1]
            y.removeLast(1)
            var z = array[2]
            z.removeLast(1)
            
            if ((Float(y) ?? 0) > 0.7 && accelIntervalY) && (((Float(x) ?? 0) > 0.7 && accelIntervalX) || ((Float(x) ?? 0) < -0.7 && accelIntervalX)) {
                accelIntervalZ = false
                accelIntervalY = false
                accelIntervalX = false
                goForwardAnimation(nodes: backgroundImages[sceneIndex], scale: 1.0 + 0.1 * CGFloat(forwardCount), duration: 0.7)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.accelIntervalZ = true
                    self.accelIntervalY = true
                    self.accelIntervalX = true
                }
            }
            
            if abs(Float(x) ?? 0) > 2, accelIntervalX {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accelX"), object: nil)
                accelIntervalX = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.accelIntervalX = true
                }
            }
            if abs(Float(y) ?? 0) > 2, accelIntervalY {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accelY"), object: nil)
                accelIntervalY = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.accelIntervalY = true
                }
            }
            if abs(Float(z) ?? 0) > 2, accelIntervalZ {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accelZ"), object: nil)
                accelIntervalZ = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.accelIntervalZ = true
                }
            }
        } else if message.contains("rotate") {
            let array = message.components(separatedBy: CharacterSet(charactersIn: ","))
            var x = array[0]
            x.removeLast(1)
            var y = array[1]
            y.removeLast(1)
            var z = array[2]
            z.removeLast(1)
            
            moveBackground(nodes: backgroundImages[sceneIndex], x: -CGFloat((Float(z) ?? 0) * 1.5), y: CGFloat((Float(x) ?? 0) * 1.5))
        }
    }
    
    @objc func showSign() {
        if image1.alpha != 0.0 {
            image1.alpha = 0.0
            image2.alpha = 1.0
        } else {
            image1.alpha = 1.0
            image2.alpha = 0.0
        }
    }
    
    func moveBackground(nodes: [SKSpriteNode], x: CGFloat, y: CGFloat) {
        for (index, n) in nodes.enumerated() {
            let division = CGFloat((Float(index) / Float(nodes.count - 1)) + 1.0)
            let xPosition = n.position.x - x / division
            let yPosition = n.position.y - y / division
            let moveX = SKAction.moveTo(x: xPosition, duration: 0.04)
            let moveY = SKAction.moveTo(y: yPosition, duration: 0.04)
            
            if abs(n.position.x) > 20 {
                if n.position.x < 0 {
                    n.position.x = -20
                } else {
                    n.position.x = 20
                }
            } else {
                n.run(moveX)
            }
            
            if abs(n.position.y) > 20 {
                if n.position.y < 0 {
                    n.position.y = -20
                } else {
                    n.position.y = 20
                }
            } else {
                n.run(moveY)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = String(data: data, encoding: .utf8) else { return }
        
        DispatchQueue.main.async {
            self.notificate(message: message)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        assertionFailure("Not Suppported.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        assertionFailure("Not Suppported.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        assertionFailure("Not Suppported.")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        
        print("browserDiscovered")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        
        print("advertiserRecieved")
    }
}
