//
//  UIImageView+ImageLoader.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-24.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

var ImageLoaderURLKey: UInt = 0
var ImageLoaderBlockKey: UInt = 0

extension UIImageView {
    // MARK: - properties
    var URL: Foundation.URL? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderURLKey) as? Foundation.URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var block: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderBlockKey) as AnyObject?
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func load(_ URL: URLLiteralConvertible) {
        load(URL, placeholder:nil){ _ in }
    }
    
    func load(_ URL: URLLiteralConvertible, placeholder: UIImage?) {
        load(URL, placeholder: placeholder) { _ in }
    }
    
    func load(_ URL: URLLiteralConvertible, placeholder: UIImage?, completionHandler:@escaping (Foundation.URL, UIImage?, NSError?) -> ()){
        if let placeholder = placeholder {
            image = placeholder
        }
        
        let URL = URL.URL
        self.URL = URL as URL
        _load(URL as URL, completionHandler: completionHandler)
    }
    
    class var _requesting_queue: DispatchQueue {
        struct Static {
            static let queue = DispatchQueue(label: "GitPocket.imageloader.queues.requesting", attributes: [])
        }
        return Static.queue
    }
    
    func _load(_ URL: Foundation.URL, completionHandler:@escaping (Foundation.URL, UIImage?, NSError?) -> ()) {
        weak var wSelf = self
        let completionHandler: (Foundation.URL, UIImage?, NSError?) -> () = {
            URL, image, error in
            
            if wSelf == nil {
                return
            }
            
            DispatchQueue.main.async{
                if self.URL != nil && (self.URL! == URL) {
                    if let image = image {
                        wSelf!.image = image
                    }
                }
                completionHandler(URL, image, error)
            }
        }
        
        if let image = Manager.sharedInstance.cache[URL] {
            completionHandler(URL, image, nil)
            return
        }
        
        UIImageView._requesting_queue.async {
            let loader = Manager.sharedInstance.load(URL).completionHandler(completionHandler)
            self.block = loader.blocks.last
            return
        }
        
    }
    
    func cancelLoading() {
        if let URL = URL {
            Manager.sharedInstance.cancel(URL, block: block as? Block)
        }
    }
}
