//
//  GameViewController.swift
//  Space-Game
//
//  Created by Joshua Colley on 28/11/2016.
//  Copyright © 2016 Joshua Colley. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    var backingAudio = AVAudioPlayer()
    @IBOutlet weak var adBanner: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adBanner.delegate = self
        adBanner.adUnitID = "ca-app-pub-4814152743531622/7522565999"
        adBanner.rootViewController = self
        adBanner.load(request)
        
        if let view = self.view as! SKView? {
            // Load the First Scene
            
            let filePath = Bundle.main.path(forResource: "theme-tune", ofType: "mp3")
            let audioNSURL = NSURL(fileURLWithPath: filePath!)
            
            do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL)}
            catch {return print("Audio Error")}
            
            backingAudio.numberOfLoops = -1
            backingAudio.volume = 1
            backingAudio.play()
            
            let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
            
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            
            }
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
