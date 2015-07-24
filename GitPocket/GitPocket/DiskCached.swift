//
//  DiskCached.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-23.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

class DiskCached: NSObject {
}

extension DiskCached: ImageCache {
  subscript(aKey: NSURL) -> UIImage? {
    get {
      var value: UIImage?
      return value
    }
    set {
      
    }
  }
}