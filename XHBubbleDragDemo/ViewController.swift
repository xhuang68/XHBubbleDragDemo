//
//  ViewController.swift
//  XHBubbleDragDemo
//
//  Created by Henry Huang on 2/19/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let bubbleColors: [UIColor] = [
        UIColor(red: 243/255, green: 163/255, blue: 79/255, alpha: 1.0),
        UIColor(red: 249/255, green: 98/255, blue: 95/255, alpha: 1.0),
        UIColor(red: 240/255, green: 202/255, blue: 85/255, alpha: 1.0),
        UIColor(red: 111/255, green: 199/255, blue: 87/255, alpha: 1.0),
        UIColor(red: 80/255, green: 183/255, blue: 238/255, alpha: 1.0),
        UIColor(red: 206/255, green: 138/255, blue: 221/255, alpha: 1.0),
        UIColor(red: 162/255, green: 162/255, blue: 164/255, alpha: 1.0),
        UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1.0),
        UIColor(red: 248/255, green: 231/255, blue: 28/255, alpha: 1.0),
        UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1.0),
        UIColor(red: 50/255, green: 162/255, blue: 80/255, alpha: 1.0),
        UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1.0)
    ]
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var disappearSwitch: UISwitch!
    
    @IBOutlet weak var soundImage: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    
    var soundEnable: Bool = true
    var disappearEnable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundSwitch.addTarget(self, action: "soundSwitchHandler:", forControlEvents: UIControlEvents.ValueChanged)
        disappearSwitch.addTarget(self, action: "disappearSwitchHandler:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func soundSwitchHandler(switchState: UISwitch) {
        soundEnable = switchState.on ? true : false
        let imageName = switchState.on ? "sound" : "mute"
        soundImage.image = UIImage(named: imageName)
    }
    
    func disappearSwitchHandler(switchState: UISwitch) {
        disappearEnable = switchState.on ? true : false
        let imageName = switchState.on ? "unlock" : "lock"
        lockImage.image = UIImage(named: imageName)
    }
    
    @IBAction func addBubbleButtonPressed(sender: AnyObject) {
        let viscosity: CGFloat = CGFloat(arc4random_uniform(10) + 1)
        let bubbleWidth: CGFloat = CGFloat(30 + Int(arc4random_uniform(UInt32(120 - 30 + 1))))
        let bubbleColor: UIColor = bubbleColors[Int(arc4random_uniform(UInt32(bubbleColors.count)))]
        
        var option = BubbleOptions()
        option.viscosity = viscosity
        option.bubbleWidth = bubbleWidth
        option.bubbleColor = bubbleColor
        
        let xMin = bubbleWidth/2
        let xMax = view.bounds.width - bubbleWidth/2
        let xPostion = CGFloat(xMin + CGFloat(arc4random_uniform(UInt32(xMax - xMin + 1))))
        
        let yMin = bubbleWidth/2
        let yMax = view.bounds.height - bubbleWidth/2
        let yPostion = CGFloat(yMin + CGFloat(arc4random_uniform(UInt32(yMax - yMin + 1))))
        
        let bubbleView = XHBubbleView(point: CGPointMake(xPostion, yPostion), superView: view, options: option, enableSound: soundEnable, enableDisappear: disappearEnable)
        option.text = "\(Int(viscosity))"
        bubbleView.bubbleOptions = option
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearButtonPressed(sender: AnyObject) {
        for v in self.view.subviews {
            if let v = v as? XHBubbleView {
                v.clean()
            }
        }
    }

}

