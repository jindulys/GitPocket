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
    var URL: NSURL? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderURLKey) as? NSURL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var block: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderBlockKey)
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func load(URL: URLLiteralConvertible) {
        load(URL, placeholder:nil){ _ in }
    }
    
    func load(URL: URLLiteralConvertible, placeholder: UIImage?) {
        load(URL, placeholder: placeholder) { _ in }
    }
    
    func load(URL: URLLiteralConvertible, placeholder: UIImage?, completionHandler:(NSURL, UIImage?, NSError?) -> ()){
        if let placeholder = placeholder {
            image = placeholder
        }
        
        let URL = URL.URL
        self.URL = URL
        _load(URL, completionHandler: completionHandler)
    }
    
    class var _requesting_queue: dispatch_queue_t {
        struct Static {
            static let queue = dispatch_queue_create("GitPocket.imageloader.queues.requesting", DISPATCH_QUEUE_SERIAL)
        }
        return Static.queue
    }
    
    func _load(URL: NSURL, completionHandler:(NSURL, UIImage?, NSError?) -> ()) {
        weak var wSelf = self
        let completionHandler: (NSURL, UIImage?, NSError?) -> () = {
            URL, image, error in
            
            if wSelf == nil {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()){
                if self.URL != nil && self.URL!.isEqual(URL) {
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
        
        dispatch_async(UIImageView._requesting_queue) {
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