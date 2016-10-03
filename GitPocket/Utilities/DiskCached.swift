//
//  DiskCached.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-23.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func escape() -> String {
        let str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            self as CFString!,
            nil,
            "!*'\"();:@&=+$,/?%#[]% " as CFString!,
            CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
        )
        
        return str as! String
    }
}



class DiskCached: NSObject {
    var images = [URL: UIImage]()
    
    class Directory {
        init() {
            createDirectory()
        }
        
        func createDirectory() {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                return
            }
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create file failed")
            }
            
        }
        
        var path:String {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                .userDomainMask, true)[0] as String
            let directoryName = "GitPocket.diskcached"
            
            return cacheDirectory.stringByAppendingPathComponent(directoryName)
        }
    }
    
    let directory = Directory()
    let _set_queue = DispatchQueue(label: "GitPocket.queues.diskcached.set", attributes: [])
    let _subscript_queue = DispatchQueue(label: "GitPocket.queues.diskcached.subscript", attributes: DispatchQueue.Attributes.concurrent)
}

extension DiskCached {
    func objectForKey(_ aKey: URL) -> UIImage? {
        if let image = images[aKey] {
            return image
        }
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: savePath(aKey.absoluteString))) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func savePath(_ name: String) -> String {
        return directory.path.stringByAppendingPathComponent(name.escape())
    }
    
    func setObject(_ anImage: UIImage, forkey aKey: URL) {
        images[aKey] = anImage
        
        let block: ()->() = {
            if let data = UIImageJPEGRepresentation(anImage, 1.0) {
                try? data.write(to: URL(fileURLWithPath: self.savePath(aKey.absoluteString)), options: [])
            }
            
            self.images[aKey] = nil
        }
        
        _set_queue.async(execute: block)
    }
}

extension DiskCached: ImageCache {
    subscript(aKey: URL) -> UIImage? {
        get {
            var value: UIImage?
            _subscript_queue.sync {
                value = self.objectForKey(aKey)
            }
            return value
        }
        set {
            _subscript_queue.async(flags: .barrier, execute: {
                self.setObject(newValue!, forkey: aKey)
            }) 
        }
    }
    
    var savePath: String {
        return self.directory.path
    }
}
