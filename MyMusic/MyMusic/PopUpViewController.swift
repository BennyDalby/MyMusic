//
//  PopUpViewController.swift
//  MyMusic
//
//  Created by Test on 7/1/20.
//  Copyright © 2020 BennyTest. All rights reserved.
//

import UIKit
import AVKit

class PopUpViewController: UIViewController {
    
    
    var musicList = [MusicModel]()
    var row = Int()
    var player = AVPlayer()
    
    @IBOutlet weak var musicProgress: UIProgressView!
    
    @IBOutlet weak var playPause: UIButton!
    var progressBarTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 20.0
        view.layer.masksToBounds = false
    
        
        playPause.setImage(UIImage(named: "play"), for: .normal)
        playPause.setImage(UIImage(named: "stop"), for: .selected)
        
        self.view.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.67)
        
       
        
        
        
    }
    
    @IBAction func playButton(_ sender: Any) {
        
        playPause.isSelected = !playPause.isSelected
        
        if playPause.isSelected {
            
            musicProgress.progress = 0.0
            
            progressBarTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)

            
            let url = URL(string:musicList[row].preview!)
                   
                   
                   do {

                       let playerItem = AVPlayerItem(url: url!)

                       self.player = try AVPlayer(playerItem:playerItem)
                       player.volume = 1.0
                       player.play()
                   } catch let error as NSError {
                      
                       print(error.localizedDescription)
                   } catch {
                       print("AVAudioPlayer init failed")
                   }
 
        }
        
        else {
            
            player.pause()
            musicProgress.progress = 0.0
             progressBarTimer.invalidate()
            
        }
        
        
    }
    
    @objc func updateProgressView() {
        
      
        
        musicProgress.progress += 1.0 /  30.0
        
               musicProgress.setProgress(musicProgress.progress, animated: true)
               if(musicProgress.progress == 1.0)
               {
                   progressBarTimer.invalidate()
                 playPause.isSelected = !playPause.isSelected
               }
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let touch = touches.first
         if touch?.view == self.view {
            
            player.pause()
            self.view.removeFromSuperview()
        }
    }
    
    
    
  

}
