//
//  NetEngine.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit



class NetEngine {
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
      if let name = NSUserDefaults.standardUserDefaults().valueForKey("GitPocketUserName") as? String {
        return name
      }
      return nil
    }
  }
  
  static let SharedInstance = NetEngine()
  
  
  func requestOAuthAccess() {
    let url = "\(githubOAuthURL)client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  }
  
  func requestTokenFromURL(url: NSURL){
    // get code from callback url
    let query = url.query
    let components = query?.componentsSeparatedByString("code=")
    let code = components?.last
    
    // generate query url
    let requestURL = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code!)"
    
    // generate request
    let request = NSMutableURLRequest(URL: NSURL(string: githubTokenURL)!)
    request.HTTPMethod = "POST"
    let postData = requestURL.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    let length = postData!.length
    request.setValue("\(length)", forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = postData
    
    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{
      (data, response, error) -> Void in
      
      if error != nil {
        print("Token couldn't been accessed")
      } else {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
            case 200...204:
              print("Success")
              guard let tokenResponse = NSString(data:data!, encoding: NSASCIIStringEncoding) else {
                return
              }
              print(tokenResponse)
              let components = tokenResponse.componentsSeparatedByString("&")
              for component in components {
                let items = component.componentsSeparatedByString("=")
                var isToken = false
                for item in items {
                  if isToken {
                    NSUserDefaults.standardUserDefaults().setObject(item, forKey: "Token")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.token = item
                    dispatch_async(dispatch_get_main_queue()){
                      NSNotificationCenter.defaultCenter().postNotificationName(kGitPocketSuccessfullyGetTokenKey, object: nil)
                    }
                    self.requestAuthenticatedUser()
                  }
                  
                  if item == "access_token" {
                    isToken = true
                  }
                }
              }
            
            default:
              print("Response Error")
          }
        }
      }
    })!.resume()
  }
  
  func requestAuthenticatedUser() {
    let userURLString = "\(baseURL)user?access_token=\(token!)"
    let userURL = NSURL(string: userURLString)
    let userTask = NSURLSession.sharedSession().dataTaskWithURL(userURL!) { (data, response, error) -> Void in
      if error != nil {
        print("Error Result")
      } else {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
            case 200...299:
              let user = User.parseJSONDataIntoSingleUser(data!)
              NSUserDefaults.standardUserDefaults().setObject(user!.userName!, forKey: "GitPocketUserName")
              NSUserDefaults.standardUserDefaults().synchronize()
              self.currentUser = user
            default:
              print("Authenticated User Response Error")
          }
        }
      }
    }
    
    userTask!.resume()
  }
  
  func requestTokenURL(url:String, completionHandler:(dict:NSDictionary?, error: NSError?) -> Void) {
    if let token = self.token {
      let requestSession = NSURLSession.sharedSession()
      
      let requestURLString = "\(url)?access_token=\(token)"
      let requestTask = requestSession.dataTaskWithURL(requestURLString.URL, completionHandler: {(data, response, error) -> Void in
        if error != nil {
          print("URL error")
        } else {
          if let httpResponse = response as? NSHTTPURLResponse {
            switch httpResponse.statusCode {
              case 200...299:
                // Parse data to Dict
                do {
                  if let repoInfo = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    
                    completionHandler(dict:repoInfo, error:nil)
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
      
      requestTask?.resume()
    }
  }
  
  
  // Totally test
  func requestEventWithCompletionHandler(completionHander:(events:[Event]?, error:NSError?)-> Void) {
    // Method1 use access_token
    if let token = self.token {
      // Configure ETag NSURLSessionConfiguration
      var eventSession: NSURLSession
      
// TODO: Here we could not use Etag
//      if let currentEtag = self.eventETag {
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        configuration.HTTPAdditionalHeaders = ["If-None-Match": "\(currentEtag)"]
//        eventSession = NSURLSession(configuration: configuration)
//      } else {
//        eventSession = NSURLSession.sharedSession()
//      }
      
      eventSession = NSURLSession.sharedSession()
      
      let eventURLString = "\(githubEventURL!)access_token=\(token)"
      //let eventURLString = "\(testEventURL)"
      let eventURL = NSURL(string: eventURLString)
      let eventTask = eventSession.dataTaskWithURL(eventURL!, completionHandler: { (data, response, error) -> Void in
        if error != nil {
          print("event error")
        } else {
          if let httpResponse = response as? NSHTTPURLResponse {
            switch httpResponse.statusCode {
              case 200...299:
                self.eventETag = httpResponse.allHeaderFields["ETag"] as? String
                
                if let events = Event.parseJSONDataIntoEvents(data!) {
                  dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHander(events: events, error: nil)
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
      eventTask?.resume()
    }
  }
}

/** Learn how to better wrapping basic objects
*   Reference https://github.com/hirohisa/ImageLoaderSwift
*/
typealias CompletionHandler = (NSURL, UIImage?, NSError?) -> ()

protocol URLLiteralConvertible {
  var URL: NSURL { get }
}

extension NSURL: URLLiteralConvertible {
  var URL: NSURL {
    return self
  }
}

extension String: URLLiteralConvertible {
  var URL: NSURL {
    if let string = stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
      return NSURL(string: string)!
    }
    
    return NSURL(string: self)!
  }
}

class Block: NSObject {
  let completionHandler: CompletionHandler
  init(completionHandler:CompletionHandler) {
    self.completionHandler = completionHandler
  }
}

protocol ImageCache: NSObjectProtocol {
  subscript(aKey: NSURL) -> UIImage? {
    get
    set
  }
}

enum State {
  case Ready
  case Running
  case Suspended
}

class Manager {
  let session: NSURLSession
  let cache: ImageCache
  let delegate: SessionDataDelegate = SessionDataDelegate()
  
  let decompressingQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
  // overridable computed properties
  class var sharedInstance: Manager {
    struct Singleton {
      static let instance = Manager()
    }
    
    return Singleton.instance
  }
  
  init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(), cache: ImageCache = DiskCached()) {
    session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    self.cache = cache
  }
  
  var state: State {
    var status: State = .Ready
    
    for loader: Loader in delegate.loaders.values {
      switch loader.state {
        case .Running:
          status = .Running
        case .Suspended:
          if status == .Ready {
            status = .Suspended
          }
        default:
          break
      }
    }
    
    return status
  }
  
  // MARK: loading
  func load(URL: URLLiteralConvertible) -> Loader {
    let URL = URL.URL
    if let loader = delegate[URL] {
      loader.resume()
      return loader
    }
    
    let request = NSMutableURLRequest(URL: URL)
    request.setValue("image/*", forHTTPHeaderField: "Accept")
    let task = session.dataTaskWithRequest(request)
    
    let loader = Loader(task: task!, delegate: self)
    delegate[URL] = loader
    return loader
  }
  
  func suspend(URL: URLLiteralConvertible) -> Loader? {
    let URL = URL.URL
    
    if let loader = delegate[URL] {
      loader.suspend()
      return loader
    }
    
    return nil
  }
  
  func cancel(URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
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
  
  
  class SessionDataDelegate: NSObject, NSURLSessionDataDelegate {
    let _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
    var loaders: [NSURL: Loader] = [NSURL: Loader]()
    
    subscript(URL: NSURL) -> Loader? {
      get {
        var loader: Loader?
        dispatch_sync(_queue) {
          loader = self.loaders[URL]
        }
        return loader
      }
      
      set {
        dispatch_barrier_async(_queue) {
          self.loaders[URL] = newValue!
        }
      }
    }
    
    func remove(URL: NSURL) -> Loader? {
      if let loader = self[URL] {
        loaders.removeValueForKey(URL)
        return loader
      }
      
      return nil
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
      if let URL = dataTask.originalRequest?.URL, let loader = self[URL] {
        loader.receive(data)
      }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
      completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
      if let URL = task.originalRequest?.URL, let loader = self[URL] {
        loader.complete(error)
      }
    }
  }
  
}

class Loader {
  unowned let delegate: Manager
  let task: NSURLSessionDataTask
  var receivedData: NSMutableData = NSMutableData()
  var blocks: [Block] = []
  
  var state: NSURLSessionTaskState {
    return task.state
  }
  
  init(task: NSURLSessionDataTask, delegate: Manager) {
    self.task = task
    self.delegate = delegate
    self.resume()
  }
  
  func completionHandler(completionHandler:CompletionHandler) -> Self {
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
  
  func remove(block: Block) {
    var newBlocks: [Block] = []
    for b:Block in blocks {
      if !b.isEqual(block) {
        newBlocks.append(b)
      }
    }
    
    blocks = newBlocks
  }
  
  func receive(data: NSData) {
    receivedData.appendData(data)
  }
  
  func complete(error: NSError?) {
    if let URL = task.originalRequest?.URL {
      if let error = error {
        failure(URL, error: error)
        return
      }
      
      dispatch_async(delegate.decompressingQueue) {
        self.success(URL, data: self.receivedData)
      }
    }
  }
  
  func success(URL: NSURL, data: NSData) {
    let image = UIImage(data: data)
    _toCache(URL, image: image)
    
    for block: Block in blocks {
      block.completionHandler(URL, image, nil)
    }
    
    blocks = []
  }
  
  func failure(URL: NSURL, error:NSError) {
    for block: Block in blocks {
      block.completionHandler(URL, nil, error)
    }
    blocks = []
  }
  
  func _toCache(URL: NSURL, image _image: UIImage?) {
    let image = _image
    if let image = image {
      delegate.cache[URL] = image
    }
  }
}

func load(URL: URLLiteralConvertible) -> Loader {
  return Manager.sharedInstance.load(URL)
}

func suspend(URL: URLLiteralConvertible) -> Loader? {
  return Manager.sharedInstance.suspend(URL)
}

func cancel(URL: URLLiteralConvertible) -> Loader? {
  return Manager.sharedInstance.cancel(URL)
}

func cache(URL: URLLiteralConvertible) -> UIImage? {
  let mURL = URL.URL
  
  return Manager.sharedInstance.cache[mURL]
}

var state: State {
  return Manager.sharedInstance.state
}
