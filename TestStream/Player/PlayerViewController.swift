//
//  ViewController.swift
//  TestStream
//
//  Created by Alexander Balogh on 6/22/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController, AVAudioPlayerDelegate {
    let urlM3U8 = URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!
    let baseUrl:String = "http://pubcache1.arkiva.de/test/"
    var playlistUrl:String = ""
    var filename : URL? = nil
    let playerView: PlayerView = PlayerView.shared
    var pangesture = UIPanGestureRecognizer()
    var topSafeArea : CGFloat = 0.0
    var bottomSafeArea : CGFloat = 0.0
    var leftSafeArea : CGFloat = 0.0
    var rightSafeArea : CGFloat = 0.0
    var offsetX : CGFloat = 0.0
    var offsetY : CGFloat = 0.0
    var isIphoneX = false
    var iphoneXSafeArea : [String : CGFloat] = ["top" : 0.0, "bottom" : 0.0, "left" : 0.0, "right" : 0.0]
    var statusBarHeight : CGFloat = 0.0
    var itemsURL:[String] = []
    var rewriteStartCoord = true
    var velocity : CGFloat = 0.0
    var swipeLimit : CGFloat = 70.0
    var startCoord : [String : CGFloat] = [:]
    let notifCenter = NotificationCenter.default
    var audioURL : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        playerView.center = self.view.center
        self.view.addSubview(playerView)
        self.pangesture = UIPanGestureRecognizer.init(target: self, action: #selector(playerViewDidDragged(_:)))
        self.playerView.addGestureRecognizer(self.pangesture)
        playerView.setup()
    }
    
    
    func getHtmlContent(callback:@escaping (_ result:String, _ stautus:Bool) -> ()) {
        let task = URLSession.shared.dataTask(with: urlM3U8) { (data, response, error) in
            if error != nil {
                print(error)
                callback("", false)
            } else {
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let arrayHtmlContent = htmlContent?.components(separatedBy: "#")
                for item in arrayHtmlContent! {
                    if item.contains("MEDIA:TYPE=AUDIO") {
                        self.audioURL.append(item)
                    }
                }
                let highestQuality = self.chooseTheHighestQuality()
                if highestQuality != "" {
                    callback(self.baseUrl + highestQuality, true)
                }
            }
        }
        task.resume()
    }
    
    
    func chooseTheHighestQuality() -> String {
        var URIArray : [String] = []
        var qualityArray : [String] = []
        var quality : Int = 0
        var highestQualityIndex = 0
        if self.audioURL.count > 0 {
            for item in self.audioURL {
                var cuttedItem = item.components(separatedBy: ",").last!.components(separatedBy: "_")[1]
                cuttedItem.remove(at: cuttedItem.index(before: cuttedItem.endIndex))
                cuttedItem.remove(at: cuttedItem.startIndex)
                qualityArray.append(cuttedItem)
                var URI = item.components(separatedBy: "URI=\"").last!.components(separatedBy: ".").first!
                URIArray.append("\(URI.components(separatedBy: "_").first!)_\(URI.components(separatedBy: "_")[1]).ts")
            }
            
            for i in 0..<qualityArray.count {
                if Int(qualityArray[i])! > quality {
                    quality = Int(qualityArray[i])!
                    highestQualityIndex = i
                }
            }
            self.playlistUrl = URIArray[highestQualityIndex]
            return URIArray[highestQualityIndex]
        }
        return ""
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.playerView.layer.frame.origin.x = (size.width - self.playerView.frame.width) / 2
        self.playerView.layer.frame.origin.y = (size.height - self.playerView.frame.height) / 2
        self.setUpSafeArea(size : size)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        notifCenter.addObserver(self, selector : #selector(self.play), name : NSNotification.Name(rawValue : "download"), object : nil)
        setUpSafeArea(size: self.view.frame.size)
    }
    
    
    @objc func playerViewDidDragged(_ sender:UIPanGestureRecognizer) {
        var newPoint = pangesture.location(in: self.view)
        velocity = (abs(sender.velocity(in: self.view).x) + abs(sender.velocity(in: self.view).y)) / 1500
        if velocity > 1.5 {
            if rewriteStartCoord {
                self.startCoord["x"] = pangesture.location(in: self.view).x
                self.startCoord["y"] = pangesture.location(in: self.view).y
            }
            rewriteStartCoord = false
        } else {
            rewriteStartCoord = true
        }
        
        if sender.state == .began {
            offsetX = newPoint.x - playerView.center.x
            offsetY = newPoint.y - playerView.center.y
        }
        
        newPoint.x -= offsetX
        newPoint.y -= offsetY
        
        if newPoint.x > self.leftSafeArea && newPoint.x < self.rightSafeArea && newPoint.y  < self.bottomSafeArea && newPoint.y > self.topSafeArea {
            self.playerView.center = newPoint
        } else {
            if newPoint.x <= self.leftSafeArea {
                playerView.center = CGPoint(x: self.leftSafeArea, y: newPoint.y)
            }
            if newPoint.x >= self.rightSafeArea {
                playerView.center = CGPoint(x: self.rightSafeArea, y: newPoint.y )
            }
            if newPoint.y >= self.bottomSafeArea {
                playerView.center = CGPoint(x: newPoint.x, y: self.bottomSafeArea)
            }
            if newPoint.y <= self.topSafeArea {
                playerView.center = CGPoint(x: newPoint.x, y: self.topSafeArea)
            }
            
            if newPoint.x <= self.leftSafeArea && newPoint.y >= self.bottomSafeArea {
                playerView.center = CGPoint(x: self.leftSafeArea, y: self.bottomSafeArea)
            }
            if newPoint.x <= self.leftSafeArea && newPoint.y <= self.topSafeArea {
                playerView.center = CGPoint(x: self.leftSafeArea, y: self.topSafeArea)
            }
            if newPoint.x >= self.rightSafeArea && newPoint.y >= self.bottomSafeArea {
                playerView.center = CGPoint(x: self.rightSafeArea, y: self.bottomSafeArea)
            }
            if newPoint.x >= self.rightSafeArea && newPoint.y <= self.topSafeArea {
                playerView.center = CGPoint(x: self.rightSafeArea, y: self.topSafeArea)
            }
            
            sender.setTranslation(playerView.center, in: self.view)
        }
        
        
        if sender.state == .ended {
            if velocity >= 1.8 {
                if abs(pangesture.location(in: self.view).x - self.startCoord["x"]!) > 70 || abs(pangesture.location(in: self.view).y - self.startCoord["y"]!) > 70 || (abs(pangesture.location(in: self.view).x - self.startCoord["x"]!) + abs(pangesture.location(in: self.view).y - self.startCoord["y"]!)) > 100 {
                    var up = false
                    var left = false
                    if pangesture.location(in: self.view).x >= self.startCoord["x"]! {
                        left = false
                    } else {
                        left = true
                    }
                    
                    if pangesture.location(in: self.view).y >= self.startCoord["y"]! {
                        up = false
                    } else {
                        up = true
                    }
                    
                    if self.startCoord["x"]! < self.leftSafeArea + swipeLimit && (abs(pangesture.location(in: self.view).x - self.startCoord["x"]!)) < swipeLimit {
                        left = true
                    }
                    
                    if self.startCoord["x"]! >  self.rightSafeArea - swipeLimit && (abs(pangesture.location(in: self.view).x - self.startCoord["x"]!)) < swipeLimit {
                        left = false
                    }
                    
                    if self.startCoord["y"]! > self.bottomSafeArea - swipeLimit && (abs(pangesture.location(in: self.view).y - self.startCoord["y"]!)) < swipeLimit {
                        up = false
                    }
                    
                    if self.startCoord["y"]! < self.topSafeArea + swipeLimit && (abs(pangesture.location(in: self.view).y - self.startCoord["y"]!)) < swipeLimit {
                        up = true
                    }
                    
                    if up {
                        if left {
                            self.movePlayerToEdge(coordinates: CGPoint(x: self.leftSafeArea, y: self.topSafeArea))
                        } else {
                            self.movePlayerToEdge(coordinates: CGPoint(x: self.rightSafeArea, y: self.topSafeArea))
                        }
                    } else {
                        if left {
                            self.movePlayerToEdge(coordinates: CGPoint(x: self.leftSafeArea, y: self.bottomSafeArea))
                        } else {
                            self.movePlayerToEdge(coordinates: CGPoint(x: self.rightSafeArea, y: self.bottomSafeArea))
                        }
                    }
                }
            }
        }
    }
}


