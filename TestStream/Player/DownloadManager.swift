//
//  DownloadManager.swift
//  TestStream
//
//  Created by Alexander Balogh on 7/27/18.
//  Copyright © 2018 AzinecLLC. All rights reserved.
//

import Foundation
import UIKit


class DownloadManager: NSObject, URLSessionDelegate, URLSessionDataDelegate {


    private var generalDataFile:Data? = nil
    private var generalDataFile3:Data? = nil
    private var generalDataFile4:Data? = nil
    
    
    let asd = OperationQueue()
    func startDownloadD(tempName:String="rrff") {
        print("good")
        self.generalDataFile = nil
//        if let url = self.baseURL {
        let url = URL(string: "http://pubcache1.arkiva.de/test/hls_a256K.ts")!
//        let url = URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!
        
        
        
//            self.dataManager = DataManager()
            let sessionConfig = URLSessionConfiguration.default
            
            asd.maxConcurrentOperationCount = 2
            //            asd.addOperation {
            //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            //                    print("opera")
            //                })
            //            }
            let sessions = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: asd)
            let sessionmnm = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: asd)
            let taskmm = sessionmnm.dataTask(with: url)
            taskmm.resume()
            
            let tasks = sessions.dataTask(with: url)
            tasks.taskDescription =  "eer"
            tasks.resume()
            
//        }
    }
    

    
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print( session.delegateQueue.operations[0].isConcurrent)
        print( session.delegateQueue.operations.count)
        print(dataTask.countOfBytesReceived)
        print(dataTask.countOfBytesExpectedToReceive)
        if dataTask.taskDescription != nil  {
            if Int(exactly: dataTask.countOfBytesReceived)! < Int(exactly: dataTask.countOfBytesExpectedToReceive)!  / 2  {
                generalDataFile3 = generalDataFile3 != nil ? generalDataFile3! + data : data
            }
        } else {
            if Int(exactly: dataTask.countOfBytesReceived)! >= Int(exactly: dataTask.countOfBytesExpectedToReceive)!  / 2 && Int(exactly: dataTask.countOfBytesReceived)! <= Int(exactly: dataTask.countOfBytesExpectedToReceive)! {
                generalDataFile4 = generalDataFile4 != nil ? generalDataFile4! + data : data
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionDataTask, didCompleteWithError error: Error?) {
        print("Task completed: \(task), error: \(error)")
        if generalDataFile3 != nil && generalDataFile4 != nil {
            generalDataFile = generalDataFile3! + generalDataFile4!
//            self.writeToFile(data: generalDataFile!)
            
        }
    }
    
//    let dataTask = session.dataTask(with: request, completionHandler: {data, response,error -> Void in
//        print("Request : \(response)")
//
//        let res = response as! HTTPURLResponse
//
//        print("Status Code : \(res.statusCode)")
//
//        let strResponse = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//        print("Response String :\(strResponse)")
//    })
//    dataTask.resume()
    

}
