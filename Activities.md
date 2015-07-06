# Day 1
## July 4, Saturday

**Activities**
- setup repository
- investigate github login API

**Notes**

- github login

  reference to [github API V3](https://developer.github.com/guides/getting-started/)

**TODO**

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


**TODO**
- Since I use xcode 7.0 could not use pod, since most of pod files only support xcode 6.3 I couldn't use a better way to parse JSON
  I decided to implement one by myself
