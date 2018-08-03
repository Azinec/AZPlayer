//
//  PlayerVCExtension.swift
//  TestStream
//
//  Created by Azinec LLC on 7/12/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import Foundation

extension PlayerViewController {
    
    @objc func play () {
        self.getHtmlContent { (url, status) in
            if status{
                PlaylistManager().fetchPlaylist(url : url)
            }
        }
    }
    
}





