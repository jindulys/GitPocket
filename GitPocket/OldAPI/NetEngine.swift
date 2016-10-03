//
//  NetEngine.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit



open class NetEngine {
    let clientID = "bf39a01edfbf0035cb42"
    let clientSecret = "fd9c0462e830bc6936a217975b024e703d32adc0"
    let githubOAuthURL = "https://github.com/login/oauth/authorize?"
    let redirectURI = "gitpocket://admin"
    let scope = "user,repo"
    let githubTokenURL = "https://github.com/login/oauth/access_token"
    let baseURL = "https://api.github.com/"
    let testEventURL = "https://api.github.com/users/jindulys/received_events"
    
    
    
    // Some properties that may change later
    //let githubEventURL = "https://api.github.com/users/jindulys/received_events?"
    
    var githubEventURL:String?{
        get{
            if let currentUser = self.currentUserName {
                return "https://api.github.com/users/\(currentUser)/received_events?"
            }
            return nil
        }
    }
    
    var token: String?
    var currentUser: User?
    var eventETag: String?
    var currentUserName:String? {
        get{
            if let name = UserDefaults.standard.value(forKey: "GitPocketUserName") as? String {
                return name
            }
            return nil
        }
    }
    
    static let SharedInstance = NetEngine()
    
    
    func requestOAuthAccess() {
        let url = "\(githubOAuthURL)client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    func requestTokenFromURL(_ url: URL){
        // get code from callback url
        let query = url.query
        let components = query?.components(separatedBy: "code=")
        let code = components?.last
        
        // generate query url
        let requestURL = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code!)"
        
        // generate request
        let request = NSMutableURLRequest(url: URL(string: githubTokenURL)!)
        request.httpMethod = "POST"
        let postData = requestURL.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let length = postData!.count
        request.setValue("\(length)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
//        URLSession.shared.dataTask(with: request, completionHandler:{
//            (data, response, error) -> Void in
//            
//            if error != nil {
//                print("Token couldn't been accessed")
//            } else {
//                if let httpResponse = response as? HTTPURLResponse {
//                    switch httpResponse.statusCode {
//                    case 200...204:
//                        print("Success")
//                        guard let tokenResponse = NSString(data:data!, encoding: String.Encoding.ascii) else {
//                            return
//                        }
//                        print(tokenResponse)
//                        let components = tokenResponse.components(separatedBy: "&")
//                        for component in components {
//                            let items = component.components(separatedBy: "=")
//                            var isToken = false
//                            for item in items {
//                                if isToken {
//                                    UserDefaults.standard.set(item, forKey: "Token")
//                                    UserDefaults.standard.synchronize()
//                                    self.token = item
//                                    DispatchQueue.main.async{
//                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kGitPocketSuccessfullyGetTokenKey), object: nil)
//                                    }
//                                    self.requestAuthenticatedUser()
//                                }
//                                
//                                if item == "access_token" {
//                                    isToken = true
//                                }
//                            }
//                        }
//                        
//                    default:
//                        print("Response Error")
//                    }
//                }
//            }
//        }).resume()
    }
    
    func requestAuthenticatedUser() {
        let userURLString = "\(baseURL)user?access_token=\(token!)"
        let userURL = URL(string: userURLString)
        let userTask = URLSession.shared.dataTask(with: userURL!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print("Error Result")
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        let user = User.parseJSONDataIntoSingleUser(data!)
                        UserDefaults.standard.set(user!.userName!, forKey: "GitPocketUserName")
                        UserDefaults.standard.synchronize()
                        self.currentUser = user
                    default:
                        print("Authenticated User Response Error")
                    }
                }
            }
        }) 
        
        userTask.resume()
    }
    
    func requestTokenURL(_ url:String, completionHandler:@escaping (_ dict:NSDictionary?, _ error: NSError?) -> Void) {
        if let token = self.token {
            let requestSession = URLSession.shared
            
            let requestURLString = "\(url)?access_token=\(token)"
            let requestTask = requestSession.dataTask(with: requestURLString.URL, completionHandler: {(data, response, error) -> Void in
                if error != nil {
                    print("URL error")
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200...299:
                            // Parse data to Dict
                            do {
                                if let repoInfo = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                    
                                    completionHandler(repoInfo, nil)
                                }
                                print("Can't convert Dict")
                            } catch _ {
                                print("Can't parse response")
                            }
                            
                            
                            print("Value")
                        default:
                            print("Error")
                        }
                    }
                }
            })
            
            requestTask.resume()
        }
    }
    
    
    // Totally test
    func requestEventWithCompletionHandler(_ completionHander:@escaping (_ events:[Event]?, _ error:NSError?)-> Void) {
        requestEventWithPage(1, completionHander: completionHander)
    }
    
    
    func requestEventWithPage(_ page: Int, completionHander:@escaping (_ events:[Event]?, _ error:NSError?)-> Void) {
        // Method1 use access_token
        if let token = self.token {
            // Configure ETag NSURLSessionConfiguration
            var eventSession: URLSession
            
            // TODO: Here we could not use Etag
            //      if let currentEtag = self.eventETag {
            //        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            //        configuration.HTTPAdditionalHeaders = ["If-None-Match": "\(currentEtag)"]
            //        eventSession = NSURLSession(configuration: configuration)
            //      } else {
            //        eventSession = NSURLSession.sharedSession()
            //      }
            
            eventSession = URLSession.shared
            
            let eventURLString = "\(githubEventURL!)access_token=\(token)&page=\(page)"
            //let eventURLString = "\(testEventURL)"
            let eventURL = URL(string: eventURLString)
            let eventTask = eventSession.dataTask(with: eventURL!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("event error")
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200...299:
                            self.eventETag = httpResponse.allHeaderFields["ETag"] as? String
                            
                            if let events = Event.parseJSONDataIntoEvents(data!) {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    completionHander(events, nil)
                                })
                            } else {
                                print("no events")
                            }
                        case 304:
                            print("no changes")
                        default:
                            print("Response Error")
                        }
                    }
                }
                
            })
            eventTask.resume()
        }
    }
}

/** Learn how to better wrapping basic objects
*   Reference https://github.com/hirohisa/ImageLoaderSwift
*/
typealias CompletionHandler = (URL, UIImage?, NSError?) -> ()

public protocol URLLiteralConvertible {
    var URL: Foundation.URL { get }
}

extension Foundation.URL: URLLiteralConvertible {
    public var URL: Foundation.URL {
        return self
    }
}

extension String: URLLiteralConvertible {
    public var URL: Foundation.URL {
        if let string = addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return Foundation.URL(string: string)!
        }
        
        return Foundation.URL(string: self)!
    }
}

class Block: NSObject {
    let completionHandler: CompletionHandler
    init(completionHandler:@escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }
}

protocol ImageCache: NSObjectProtocol {
    subscript(aKey: URL) -> UIImage? {
        get
        set
    }
    
    var savePath: String {
        get 
    }
}

enum State {
    case ready
    case running
    case suspended
}

class Manager {
    let session: URLSession
    let cache: ImageCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    
    let decompressingQueue = DispatchQueue(label: "none", attributes: DispatchQueue.Attributes.concurrent)
    // overridable computed properties
    class var sharedInstance: Manager {
        struct Singleton {
            static let instance = Manager()
        }
        
        return Singleton.instance
    }
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, cache: ImageCache = DiskCached()) {
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        self.cache = cache
    }
    
    var state: State {
        var status: State = .ready
        
        for loader: Loader in delegate.loaders.values {
            switch loader.state {
            case .running:
                status = .running
            case .suspended:
                if status == .ready {
                    status = .suspended
                }
            default:
                break
            }
        }
        
        return status
    }
    
    // MARK: loading
    func load(_ URL: URLLiteralConvertible) -> Loader {
        let URL = URL.URL
        if let loader = delegate[URL] {
            loader.resume()
            return loader
        }
        
        let request = NSMutableURLRequest(url: URL)
        request.setValue("image/*", forHTTPHeaderField: "Accept")
				let finalRequest = request as URLRequest
        //let task = self.session.dataTask(with: finalRequest)
			let task = self.session.dataTask(with: finalRequest)
        let loader = Loader(task: task, delegate: self)
        delegate[URL] = loader
        return loader
    }
    
    func suspend(_ URL: URLLiteralConvertible) -> Loader? {
        let URL = URL.URL
        
        if let loader = delegate[URL] {
            loader.suspend()
            return loader
        }
        
        return nil
    }
    
    func cancel(_ URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        let URL = URL.URL
        
        if let loader = delegate[URL] {
            
            if let block = block {
                loader.remove(block)
            }
            
            if loader.blocks.count == 0 || block == nil {
                loader.cancel()
                delegate.remove(URL)
            }
            
            return loader
        }
        
        return nil
    }
    
    
    class SessionDataDelegate: NSObject, URLSessionDataDelegate {
        let _queue = DispatchQueue(label: "none", attributes: DispatchQueue.Attributes.concurrent)
        var loaders: [URL: Loader] = [URL: Loader]()
        
        subscript(URL: URL) -> Loader? {
            get {
                var loader: Loader?
                _queue.sync {
                    loader = self.loaders[URL]
                }
                return loader
            }
            
            set {
                _queue.async(flags: .barrier, execute: {
                    self.loaders[URL] = newValue!
                }) 
            }
        }
        
        func remove(_ URL: Foundation.URL) -> Loader? {
            if let loader = self[URL] {
                loaders.removeValue(forKey: URL)
                return loader
            }
            
            return nil
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if let URL = dataTask.originalRequest?.url, let loader = self[URL] {
                loader.receive(data)
            }
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let URL = task.originalRequest?.url, let loader = self[URL] {
                loader.complete(error as NSError?)
            }
        }
    }
    
}

class Loader {
    unowned let delegate: Manager
    let task: URLSessionDataTask
    var receivedData: NSMutableData = NSMutableData()
    var blocks: [Block] = []
    
    var state: URLSessionTask.State {
        return task.state
    }
    
    init(task: URLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        self.resume()
    }
    
    func completionHandler(_ completionHandler:@escaping CompletionHandler) -> Self {
        let block = Block(completionHandler: completionHandler)
        blocks.append(block)
        
        return self
    }
    
    func suspend() {
        task.suspend()
    }
    
    func resume() {
        task.resume()
    }
    
    func cancel() {
        task.cancel()
    }
    
    func remove(_ block: Block) {
        var newBlocks: [Block] = []
        for b:Block in blocks {
            if !b.isEqual(block) {
                newBlocks.append(b)
            }
        }
        
        blocks = newBlocks
    }
    
    func receive(_ data: Data) {
        receivedData.append(data)
    }
    
    func complete(_ error: NSError?) {
        if let URL = task.originalRequest?.url {
            if let error = error {
                failure(URL, error: error)
                return
            }
            
            delegate.decompressingQueue.async {
                self.success(URL, data: self.receivedData as Data)
            }
        }
    }
    
    func success(_ URL: Foundation.URL, data: Data) {
        let image = UIImage(data: data)
        _toCache(URL, image: image)
        
        for block: Block in blocks {
            block.completionHandler(URL, image, nil)
        }
        
        blocks = []
    }
    
    func failure(_ URL: Foundation.URL, error:NSError) {
        for block: Block in blocks {
            block.completionHandler(URL, nil, error)
        }
        blocks = []
    }
    
    func _toCache(_ URL: Foundation.URL, image _image: UIImage?) {
        let image = _image
        if let image = image {
            delegate.cache[URL] = image
        }
    }
}

func load(_ URL: URLLiteralConvertible) -> Loader {
    return Manager.sharedInstance.load(URL)
}

func suspend(_ URL: URLLiteralConvertible) -> Loader? {
    return Manager.sharedInstance.suspend(URL)
}

func cancel(_ URL: URLLiteralConvertible) -> Loader? {
    return Manager.sharedInstance.cancel(URL)
}

func cache(_ URL: URLLiteralConvertible) -> UIImage? {
    let mURL = URL.URL
    
    return Manager.sharedInstance.cache[mURL]
}

var state: State {
    return Manager.sharedInstance.state
}
