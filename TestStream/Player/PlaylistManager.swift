//
//  PlalistManager.swift
//  TestStream
//
//  Created by Azinec LLC on 7/4/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import UIKit


class PlaylistManager: NSObject {
    
    func fetchPlaylist(url : String) {
        let downloader = DataDownloader()
        downloader.startDownload(urlHQ: URL(string: url))
    }
}


class DataDownloader:NSObject {
    private var generalDataFile:Data? = nil
    private var generalDataFile3:Data? = nil
    private var generalDataFile4:Data? = nil
    var progressFirst : Float = 0
    var progressSecond : Float = 0
    var dataManager:DataManager!
    var newFile = true
    let operationQueue = OperationQueue()
    
    
    func startDownload(urlHQ : URL?) {
        self.generalDataFile = nil
        if let url = urlHQ {
            self.dataManager = DataManager()
            let sessionConfig = URLSessionConfiguration.default
            operationQueue.maxConcurrentOperationCount = 2
            let sessions = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: operationQueue)
            let sessionmnm = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: operationQueue)
            let taskmm = sessionmnm.dataTask(with: url)
            taskmm.resume()
            
            let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
            concurrentQueue.sync {
                let tasks = sessions.dataTask(with: url)
                tasks.taskDescription =  "added"
                tasks.resume()
            }
        }
    }
}


class DataManager:NSObject {
    private var tempName:String = "tempfile"
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    func writeToFile(data:Data) {
        let newDir = self.getDirectory().appendingPathComponent("\(tempName).ts")
        do {
            try  data.write(to: newDir)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playit"), object: data, userInfo: ["sound": data, "name": newDir])
        } catch  {
            print(error)
        }
    }
}



extension DataDownloader: URLSessionDelegate, URLSessionDownloadDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask.taskDescription != nil  {
            if Int(exactly: dataTask.countOfBytesReceived)! < Int(exactly: dataTask.countOfBytesExpectedToReceive)!  / 2  {
                generalDataFile3 = generalDataFile3 != nil ? generalDataFile3! + data : data
                progressFirst = Float(dataTask.countOfBytesReceived) / Float(dataTask.countOfBytesExpectedToReceive)
            }
        } else {
            if Int(exactly: dataTask.countOfBytesReceived)! >= Int(exactly: dataTask.countOfBytesExpectedToReceive)!  / 2 && Int(exactly: dataTask.countOfBytesReceived)! <= Int(exactly: dataTask.countOfBytesExpectedToReceive)! {
                generalDataFile4 = generalDataFile4 != nil ? generalDataFile4! + data : data
                progressSecond = ((Float(dataTask.countOfBytesReceived) - (Float(dataTask.countOfBytesExpectedToReceive) / 2)) / Float(dataTask.countOfBytesExpectedToReceive))
            }
        }
        progress = progressFirst + progressSecond
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fillPlayer"), object: self)
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(progress)
        if progress >= 0.95 {
            progress = 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fillPlayer"), object: self)
        }
        if generalDataFile3 != nil && generalDataFile4 != nil {
            generalDataFile = generalDataFile3! + generalDataFile4!
            if newFile && generalDataFile != nil {
                dataManager.writeToFile(data: generalDataFile!)
                generalDataFile = nil
                newFile = false
            }
        }
    }
    
    
    func removeLocallyCachedFile() {
        let urlPath = DataManager().getDirectory().appendingPathComponent("tempfile.ts")
        var fileManager = FileManager.default
        try! fileManager.removeItem(at: urlPath)
        newFile = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uninitialize"), object: self)
    }
    
    
    func checkExistFile() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("tempfile.ts").path
        let fileManager = FileManager.default
        print(filePath)
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
            return true
        } else {
            print("FILE NOT AVAILABLE")
            return false
        }
    }
    
}


