//
//  FirstViewController.swift
//  James
//
//  Created by Vansa Pha on 5/30/18.
//  Copyright © 2018 Vansa Pha. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var neIma: UIImageView!
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        neIma.layer.cornerRadius = 50
        NotificationCenter.default.addObserver(self, selector: #selector(gifConfig), name: NSNotification.Name(rawValue: "gif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remove), name: NSNotification.Name(rawValue: "regif"), object: nil)
        let giffirework = UIImage.gifImageWithName("giphy")
        bgImage.image = giffirework
        playSound()
    }
    
    @objc func gifConfig() {
        if bgImage.isHidden == true {
            player?.play()
            bgImage.isHidden = false
        }
    }
    
    @objc func remove() {
        if bgImage.isHidden == false {
            player?.stop()
            bgImage.isHidden = true
        }
    }
    
    private func playSound() {
        let url = Bundle.main.url(forResource: "firework_sound", withExtension: "mp3")
        do {
            guard let url = url else {return}
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else {return}
            player.numberOfLoops = -1
            player.prepareToPlay()
        }catch let error as NSError {
            print(error.description)
        }
    }

}
