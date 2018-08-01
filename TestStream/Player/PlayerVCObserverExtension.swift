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
    
}




