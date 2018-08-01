//
//  PlayerVCUIUXExtension.swift
//  TestStream
//
//  Created by Azinec LLC on 7/12/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


extension PlayerViewController {
    
    func safeArea4 (top : CGFloat, bottom : CGFloat, left : CGFloat, right : CGFloat) {
        self.topSafeArea = top + self.playerView.frame.size.height / 2 + iphoneXSafeArea["top"]!
        self.bottomSafeArea = bottom - self.playerView.frame.size.height / 2 - iphoneXSafeArea["bottom"]!
        self.leftSafeArea = left + self.playerView.frame.size.width / 2 + iphoneXSafeArea["left"]!
        self.rightSafeArea = right - self.playerView.frame.size.width / 2 - iphoneXSafeArea["right"]!
    }
    
    
    func setUpSafeArea (size : CGSize) {
        self.checkIsIphoneX()
        switch UIDevice.current.orientation {
            
        case UIDeviceOrientation.landscapeLeft:
            if isIphoneX {
                self.safeAreaIphoneX4(top: 0, bottom: 23, left: 34, right: 0)
            }
            self.safeArea4(top: 0 ,
                           bottom: size.height,
                           left: 0,
                           right: size.width)
            break
            
        case UIDeviceOrientation.landscapeRight:
            if isIphoneX {
                self.safeAreaIphoneX4(top: 0, bottom: 23, left: 0, right: 34)
            }
            
            self.safeArea4(top: 0,
                           bottom: size.height,
                           left: 0,
                           right: size.width)
            break
            
        case UIDeviceOrientation.portrait:
            if isIphoneX {
                self.safeAreaIphoneX4(top: 0, bottom: 44, left: 0, right: 0)
            }
            self.statusBarHeight = UIApplication.shared.statusBarFrame.height >= 20.0 ? UIApplication.shared.statusBarFrame.height : CGFloat(20.0)
            self.safeArea4(top:  self.statusBarHeight,
                           bottom: size.height,
                           left: 0,
                           right: size.width)
            break
            
        default:
            if isIphoneX {
                self.safeAreaIphoneX4(top: 0, bottom: 44, left: 0, right: 0)
            }
            self.statusBarHeight = UIApplication.shared.statusBarFrame.height >= 20.0 ? UIApplication.shared.statusBarFrame.height : CGFloat(20.0)
            self.safeArea4(top:  self.statusBarHeight,
                           bottom: size.height,
                           left: 0,
                           right: size.width)
            break
        }
    }
    
    
    func safeAreaIphoneX4 (top : CGFloat, bottom : CGFloat, left : CGFloat, right : CGFloat) {
        iphoneXSafeArea["top"] = top
        iphoneXSafeArea["bottom"] = bottom
        iphoneXSafeArea["left"] = left
        iphoneXSafeArea["right"] = right
    }
    
    
    func checkIsIphoneX () {
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            isIphoneX = true
        } else {
            isIphoneX = false
        }
    }
    
    
    func movePlayerToEdge (coordinates : CGPoint) {
        let distance = sqrt(pow(abs(self.startCoord["x"]! - coordinates.x), 2) + pow(abs(self.startCoord["y"]! - coordinates.y), 2))
        let time = Double (distance / velocity / 230)
        UIView.animate(withDuration: time, delay: 0, options: [.curveEaseInOut], animations: {
            self.playerView.center = CGPoint(x: coordinates.x, y: coordinates.y)}, completion: nil)
    }
    
}

