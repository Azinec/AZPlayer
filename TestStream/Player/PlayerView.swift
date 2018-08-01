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
    var stoppedMusic = false
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
            controllerButton.isUserInteractionEnabled = false
            spinner.isHidden = false
            spinner.startAnimating()
        } else {
            self.playMusicF()
        }
    }
    
    
    @objc func fillPlayer() {
        DispatchQueue.main.async {
            self.indicatirViewHeight.constant = self.view.frame.height * CGFloat(progress)
            self.indicatorViewWidht.constant = self.view.frame.width * CGFloat(progress)
            self.indicatorView.layer.cornerRadius = self.indicatorViewWidht.constant / 2
        }
    }
    
    
    func setup() {
        self.view.layer.cornerRadius = self.view.frame.height / 2
        self.view.layer.cornerRadius = self.view.frame.height / 2
        notifCenter.addObserver(self, selector : #selector(self.playMusicF), name: NSNotification.Name(rawValue: "playit"), object: nil)
        notifCenter.addObserver(self, selector : #selector(self.changeToUninitializedState), name: NSNotification.Name(rawValue: "uninitialize"), object: nil)
        notifCenter.addObserver(self, selector : #selector(self.fillPlayer), name: NSNotification.Name(rawValue: "fillPlayer"), object: nil)
        spinner.isHidden = true
    }
    
    
    @objc func playMusicF() {
        isDownloadedMedia = true
        DispatchQueue.main.async {
            self.controllerButton.isUserInteractionEnabled = true
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }
        
        if stoppedMusic || audioPlayer == nil {
            if let urlPath = self.localURL {
                if !stoppedMusic {
                    do{
                        audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPath))
                        audioPlayer.delegate = self
                        audioPlayer.prepareToPlay()
                        audioPlayer.play()
                        playerStatus = .Playing
                        DispatchQueue.main.async {
                            self.controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                        }
                    }
                    catch {
                        print(error)
                    }
                } else {
                    audioPlayer.play()
                    playerStatus = .Playing
                    DispatchQueue.main.async {
                        self.controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    }
                }
                self.stoppedMusic = false
            }
        } else {
            audioPlayer.pause()
            playerStatus = .Paused
            DispatchQueue.main.async {
                self.controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
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
    }
}
