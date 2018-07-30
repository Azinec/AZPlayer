//
//  PlayerView.swift
//  TestStream
//
//  Created by Alexander Balogh on 6/22/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView, AVAudioPlayerDelegate {
    
    enum PlayerStatus {
        case Playing
        case Downloading
        case Paused
        case Stopped
        case End
        case Waiting
    }
    
    var playerStatus:PlayerStatus = .Waiting
    
    var isDownloadedMedia:Bool = false
    var progress:Float = 0.0
    
    static var shared = PlayerView()
    
    var audioPlayer : AVAudioPlayer!
    
    let localURL : String? = Bundle.main.path(forResource: "camilacabello", ofType: "mp3")
    
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var controllerButton: UIButton!
    
    @IBOutlet weak var indicatirViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorViewWidht: NSLayoutConstraint!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    weak var view: UIView!
    
    let notifCenter = NotificationCenter.default
    
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PlayerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
    @IBAction func controllerTapped(_ sender: UIButton) {
        if !isDownloadedMedia && playerStatus == .Waiting {
            notifCenter.post(name: NSNotification.Name(rawValue: "download"), object: self)
            controllerButton.setImage(nil, for: .normal)
            spinner.isHidden = false
            spinner.startAnimating()
        } else {
            self.playMusicF()
        }
        
        
        
        //        DownloadManager().startDownloadD()
        
        //        if isDownloadedMedia && playerStatus == .Playing {
        //            notifCenter.post(name: NSNotification.Name(rawValue: "pause"), object: self)
        //            controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        //        } else if isDownloadedMedia && playerStatus == .Paused {
        //            notifCenter.post(name: NSNotification.Name(rawValue: "continue"), object: self)
        //            controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        //        }
    }
    
    
    func setup() {
        self.view.layer.cornerRadius = self.view.frame.height / 2
        self.view.layer.cornerRadius = self.view.frame.height / 2
        notifCenter.addObserver(self, selector : #selector(self.playMusicF), name: NSNotification.Name(rawValue: "playit"), object: nil)
        notifCenter.addObserver(self, selector : #selector(self.changeToUninitializedState), name: NSNotification.Name(rawValue: "uninitialize"), object: nil)
        spinner.isHidden = true
    }
    
    func setProgress(progress:Float) {
        self.progress = progress
        var progressForCheck = progress
        if progressForCheck <= 0.0 {
            progressForCheck = 1.0
        }
        if progressForCheck == 1.0 {
            self.controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        self.indicatirViewHeight.constant = self.frame.height * CGFloat(progressForCheck)
        self.indicatorViewWidht.constant = self.frame.width * CGFloat(progressForCheck)
        self.indicatorView.layer.cornerRadius = self.indicatorViewWidht.constant / 2
    }
    
    func appendProgress(progress:Float) {
        setProgress(progress: self.progress + progress)
    }
    
    var stoppedMusic = false
    @objc func playMusicF() {
        isDownloadedMedia = true
        spinner.stopAnimating()
        spinner.isHidden = true
        
        
        if stoppedMusic || audioPlayer == nil {
            if let urlPath = self.localURL {
                if !stoppedMusic {
                    do{
                        audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPath))
                        audioPlayer.delegate = self
                        audioPlayer.prepareToPlay()
                        audioPlayer.play()
                        playerStatus = .Playing
                        controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    }
                    catch {
                        print(error)
                    }
                } else {
                    audioPlayer.play()
                    playerStatus = .Playing
                    controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                }
                
                self.stoppedMusic = false
            }
        } else {
            audioPlayer.pause()
            playerStatus = .Paused
            controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.stoppedMusic = true
        }
        
    }
    
    @objc func changeToUninitializedState() {
        self.isDownloadedMedia = false
        spinner.isHidden = true
        spinner.stopAnimating()
        controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        controllerButton.setImage(nil, for: .normal)
        
        spinner.isHidden = false
        spinner.startAnimating()
        
        indicatirViewHeight.constant = 0.0
        indicatorViewWidht.constant = 0.0
        audioPlayer = nil
        
        playerStatus = .Waiting
        isDownloadedMedia = false
        
        DataDownloader(with: URL(string: "http://pubcache1.arkiva.de/test/hls_a256K.ts")!).removeLocallyCachedFile()
        
        //add observer to delete the cached file
        //change the flag isDownloadedMedia to false
        //set the image "play" --> controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
}



