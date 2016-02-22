//
//  XHSmokePuffImageView.swift
//  XHSmokePuff
//
//  Created by Henry Huang on 2/20/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

import UIKit
import AVFoundation

class XHSmokePuffImageView: UIImageView {
    
    let animationImageSets: [UIImage] = [
        UIImage(named: "smoke1.png")!,
        UIImage(named: "smoke2.png")!,
        UIImage(named: "smoke3.png")!,
        UIImage(named: "smoke4.png")!,
        UIImage(named: "smoke5.png")!
    ]
    let puffTime = 0.3
    let audioName = "puff_smoke"
    var audioPlayer: AVAudioPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.animationImages = animationImageSets
        self.animationDuration = puffTime
        self.animationRepeatCount = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func playAnimation(withCompletionHandler completionHandler: () -> Void) {
        self.startAnimating()
        
        delay(puffTime, completion: completionHandler)
    }
    
    func playAudio() {
        if let audioPlayer = self.setupAudioPlayerWithFile(audioName, type:"m4a") {
            self.audioPlayer = audioPlayer
        }
        audioPlayer?.play()
    }
    
    private func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    private func delay(seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
}
