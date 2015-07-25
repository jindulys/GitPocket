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
      self,
      nil,
      "!*'\"();:@&=+$,/?%#[]% ",
      CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
    )
    
    return str as String
  }
}



class DiskCached: NSObject {
  var images = [NSURL: UIImage]()

  class Directory {
    init() {
      createDirectory()
    }
    
    func createDirectory() {
      let fileManager = NSFileManager.defaultManager()
      if fileManager.fileExistsAtPath(path) {
        return
      }
      do {
        try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("create file failed")
      }
      
    }
    
    var path:String {
      let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
        .UserDomainMask, true)[0] as String
      let directoryName = "GitPocket.diskcached"
      
      return cacheDirectory.stringByAppendingPathComponent(directoryName)
    }
  }
  
  let directory = Directory()
  let _set_queue = dispatch_queue_create("GitPocket.queues.diskcached.set", DISPATCH_QUEUE_SERIAL)
  let _subscript_queue = dispatch_queue_create("GitPocket.queues.diskcached.subscript", DISPATCH_QUEUE_CONCURRENT)
}

extension DiskCached {
  func objectForKey(aKey: NSURL) -> UIImage? {
    if let image = images[aKey] {
      return image
    }
    
    if let data = NSData(contentsOfFile: savePath(aKey.absoluteString)) {
      return UIImage(data: data)
    }
    return nil
  }
  
  func savePath(name: String) -> String {
    return directory.path.stringByAppendingPathComponent(name.escape())
  }
  
  func setObject(anImage: UIImage, forkey aKey: NSURL) {
    images[aKey] = anImage
    
    let block: ()->() = {
      if let data = UIImageJPEGRepresentation(anImage, 1.0) {
        data.writeToFile(self.savePath(aKey.absoluteString), atomically: false)
      }
      
      self.images[aKey] = nil
    }
    
    dispatch_async(_set_queue, block)
  }
}

extension DiskCached: ImageCache {
  subscript(aKey: NSURL) -> UIImage? {
    get {
      var value: UIImage?
      dispatch_sync(_subscript_queue) {
        value = self.objectForKey(aKey)
      }
      return value
    }
    set {
      dispatch_barrier_async(_subscript_queue) {
        self.setObject(newValue!, forkey: aKey)
      }
    }
  }
}