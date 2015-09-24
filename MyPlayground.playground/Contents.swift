//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var myString = "W/\"ec0648b82a4ed3525d0e0511c2fe58b3\""

var results = myString.componentsSeparatedByString("\"")
print(results[1])

var a:[String] = ["hello", "你好"]
a += ["This", "is", "a"]
a.extend(["add","some", "new"])

func queryComponents(key: String, value: AnyObject) -> [(String, String)] {
  var components: [(String, String)] = []
  if let dictionary = value as? [String: AnyObject] {
    for (nestedKey, value) in dictionary {
      components += queryComponents("\(key)[\(nestedKey)]", value)
    }
  } else if let array = value as? [AnyObject] {
    for value in array {
      components += queryComponents("\(key)[]", value)
    }
  } else {
    components.extend([(escape(key), escape("\(value)"))])
  }
  
  return components
}

func escape(string: String) -> String {
  let legalURLCharactersToBeEscaped: CFStringRef = ":&=;+!@#$()',*"
  return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
}

func query(parameters: [String: AnyObject]) -> String {
  var components: [(String, String)] = []
  for key in sorted(Array(parameters.keys), <) {
    let value: AnyObject! = parameters[key]
    components += queryComponents(key, value)
  }
  
  return join("&", components.map{"\($0)=\($1)"} as [String])
}

let easyOne: [String: AnyObject] = ["key1":["val1","val3"], "key2":"val2"]

println(query(easyOne))
