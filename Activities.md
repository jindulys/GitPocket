# Day 1
## July 4, Saturday

**Activities**
- setup repository
- investigate github login API

**Notes**
- github login
  reference to [github API V3](https://developer.github.com/guides/getting-started/)

- vc childViewControllers
  a lot of view controllers use a property **childViewControllers** what does that property used for?


# Day 2
## July 5, Sunday

**Activities**
- learn how to use OAuth 2.0
- how to correctly use redirectURL
 [An instruction on how to properly configure your iOS Application to oper a specific URL schema](http://iosdevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html)
- finished OAuth token access's first step (get the code)


**Notes**
- OAuth 2.0 flow
  **Site A** wants to access **User X's** information on **Site B**
  1. **Site A** registers with **Site B**, and obtains a **Secret** and an **ID**
  2. When **User X** tells **Site A** to access **Site B**, **User X** is sent to **Site B** where
  it tells **Site B** that he would indeed like to give **Site A** permissions to specific information.
  3. **Site B** redirects **User X** back to **Site A**, along with an **Authorization Code**
  4. **Site A** then passes that **Authorization Code** along with its **Secret** back to **Site B** in return for a **Security Token**
  5. **Site A** then makes requests to **Site B** on behalf of **User X** by bundling the **Security Token** along with requests

- Correctly configure your github Application
  1. on **Github Developer Page**(https://github.com/settings/developers) registers your app, remember your **clientID** and **clientSecret**, also set some strange redirectURL like *ilovelittlepolorbear://lollllo*
  2. on your Xcode Info.plist add an new item **URL Types** then add **URL Schema** as key and *ilovelittlepolorbear://lollllo* as value
  3. According to github auth(https://developer.github.com/v3/oauth/), use *https://github.com/login/oauth/authorize* with **clientID** and your redirectURL as parameter, then in your applicationdelegate's method:

            func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
  to retrieve your code and then apply for your token.

- HTTP POST working flow (https://en.wikipedia.org/wiki/POST_(HTTP))

  we use *application/x-www-form-urlencoded* for *Content-Type* in HTTPHeader


# Day 3
## July 6, Monday

**Activities**
- Create a **User** model to save a information about github user
- Get **Event** feed
- Show those feeds in a simple UITableView

**TODO**
- Since I use xcode 7.0 could not use pod, since most of pod files only support xcode 6.3 I couldn't use a better way to parse JSON
  I decided to implement one by myself
- Add Etag to event request http header to avoid repeat request
- Add PullToRefress
- Learn how to use autoLayout in UITableViewCell

# Day 4
## July 7, Tuesday

**Activities**
- Figure out how does Alamofire work to make ETag Request success
  It could be because of iOS SDK difference

**Note**
- Here is a syntax that avoid strong reference cycle in swift, I finally understand that

      self.someClosure = { [weak self] someVariable in
          // Note self is an optional, and may be nil
          if let strongSelf = self {
              strongSelf.doSomeFunction()
          }
      }
 - After tried many times I find that Etag only work on iOS 8.3 not on iOS 9.0 NSURLDataSession, I don't know why.

# Day 5
## July 8, Wednesday

**Activities**
- Figure out how Alamofire underlying thread mechanism
   Finally understand it, could check this StackOverFlow question(http://stackoverflow.com/questions/31298485/how-alamofire-could-guarantee-response-method-would-be-called-after-get-all-the)

   Here I found a more detailed StackOverflow question about how the queue hopped around by **Alamofire** (http://stackoverflow.com/questions/29852431/alamofire-asynchronous-completionhandler-for-json-request)
