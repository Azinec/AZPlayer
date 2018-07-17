//
//  PlalistManager.swift
//  TestStream
//
//  Created by Azinec LLC on 7/4/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import UIKit
import M3U8Kit
import AVKit


class PlaylistManager: NSObject {
    
    private var baseUrlString:String = ""
    private var baseUrl:URL  {
        get {
            return URL(string: self.baseUrlString)!
        }
    }
    
    override init() {
        super.init()
    }
    
    init(url:String) {
        baseUrlString = url
    }
    
    func fetchPlaylist() {
        do {
            if let playlist = try M3U8PlaylistModel(url: baseUrl).audioPl {
                let tempName = "\(NSDate().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "")
                if let segmentUrl = playlist.allSegmentURLs().first as? URL {
                    let downloader = DataDownloader(with: segmentUrl)
                    downloader.startDownload(tempName: tempName)
                }
                
            }
            
        } catch  {
            print(error)
        }
    }
    
    
}

var genData:Data? = nil
var isPlaying:Bool = false
class DataDownloader:NSObject {
    
    private var baseURL:URL? = nil
    private var generalDataFile:Data? = nil
    
    var dataManager:DataManager!
    
    init(with url:URL) {
        self.baseURL = url
    }
    
    func startDownload(tempName:String="", threaddNumber:Int = 2) {
        for i in 0...threaddNumber {
            if let url = self.baseURL {
                DispatchQueue(label: Bundle.main.bundleIdentifier! + ".concurrentQueue\(i)", qos: .utility, attributes: .concurrent).async {
                    let dT = DataDownloader(with: url)
                    dT.dataManager = DataManager(name: tempName)
                    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: dT, delegateQueue: nil)
                    let task = session.dataTask(with: url)
                    task.resume()
                }
            }
            
        }
        
        
    }
    
}



class DataManager:NSObject {
    private var tempName:String = "tempfile"
    private var ext:String = "ts"
    override init() {
        super.init()
    }
    
    init(name:String) {
        self.tempName = name
    }
    
    
    
    func getTempName() -> String {
        return self.tempName + "." + self.ext
    }
    
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    func writeToFile(data:Data) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(getTempName())
        do {
            try data.write(to: fileURL, options: .noFileProtection)
        } catch {
            print(error)
        }
        print(fileURL)
    }
    
    func deleteDownloadedChunks() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let tempDirPath = dirPath.appending("Temp")
        do {
            let directoryContents: [String] = try! FileManager.default.contentsOfDirectory(atPath: tempDirPath)
            for path in directoryContents {
                let fullPath = dirPath.appending(path)
                try FileManager.default.removeItem(atPath: fullPath)
            }
        } catch {
            debugPrint(error)
        }
    }
}



extension DataDownloader: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let tmpData = NSMutableData()
        if let gD = generalDataFile {
            tmpData.append(gD)
        }
        tmpData.append(data)
        generalDataFile = tmpData as Data
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let dM = self.dataManager, let gD = generalDataFile {
            dM.writeToFile(data: gD)
            DispatchQueue.main.async {
                PlayerView.shared.setProgress(progress: 1.0)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playit"), object: nil, userInfo: ["name": self.dataManager.getTempName()])
            }
            
        }
    }
    
    
}










