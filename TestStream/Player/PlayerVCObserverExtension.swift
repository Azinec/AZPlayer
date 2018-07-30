//
//  PlayerVCExtension.swift
//  TestStream
//
//  Created by Azinec LLC on 7/12/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

extension PlayerViewController {
    
    @objc func play () {
        self.getHtmlContent { (url, status) in
            if status{
                PlaylistManager(url: url).fetchPlaylist(url : url)
            }
        }
    }
    
    //    @objc func pause() {
    //        if let jB = self.jukeBox {
    //            PlayerView.shared.playerStatus = .Paused
    //            jB.pause()
    //        }
    //    }
    //
    //    @objc func continuePlaying() {
    //        if let jB = self.jukeBox {
    //            PlayerView.shared.playerStatus = .Playing
    //            jB.play()
    //        }
    //    }
    
    //    @objc func playit(notification:Notification) {
    ////        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "playit"), object: nil)
    ////
    //        if let uI = notification.userInfo {
    //            if let name = uI["name"] as? String {
    //                do {
    //                    let dM = DataManager(name: name)
    //                    let path = dM.getDirectory().appendingPathComponent(name)
    //                    print(path)
    //                    let pathString = self.baseUrl+self.playlistUrl
    ////                    self.jukeBox = Jukebox(delegate: self, items: [JukeboxItem(URL: URL(string: pathString)!)])
    ////                    if let jB:Jukebox = self.jukeBox {
    ////                        if PlayerView.shared.playerStatus != .Playing || jB.state != Jukebox.State.playing {
    //                            isPlaying = true
    //                            PlayerView.shared.isDownloadedMedia = true
    //                            PlayerView.shared.playerStatus = .Playing
    //                            jB.play()
    //                        }
    //                    }
    //
    //                } catch {
    //                    print("Something bad happened. Try catching specific errors to narrow things down: \(error  )")
    //                }
    //
    //            }
    //
    //
    //        }
    //    }
    
    
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        downloaded = false
        //        playerTime = nil
        playerView.indicatirViewHeight.constant = 0.0
        playerView.indicatorViewWidht.constant = 0.0
        playerView.controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        //        videoPlayer = nil
    }
    
    //    @objc func statusChanged () {
    //        if videoPlayer == nil {
    //            self.play()
    //            playerView.controllerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    //            playerView.updateConstraintsIfNeeded()
    //        } else {
    //            playerView.controllerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    //            playerTime = (videoPlayer.currentItem?.currentTime())!
    //            videoPlayer.pause()
    //            videoPlayer = nil
    //        }
    //    }
    
}



//extension PlayerViewController: JukeboxDelegate {
//    func jukeboxStateDidChange(_ jukebox: Jukebox) {
//        print(jukebox.state)
//    }
//
//    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
////        print("jukeboxPlaybackProgressDidChange")
//    }
//
//    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
//
//    }
//
//    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
//        print("jukeboxDidLoadItem")
//    }
//
//
//
//
//}



