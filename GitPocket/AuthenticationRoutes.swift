//
//  AuthenticationRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-18.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

class GithubAuthentication {
    let id: Int32
    let token: String
    let hashedToken: String
    
    init(id:Int32, token: String, hashedToken: String) {
        self.id = id
        self.token = token
        self.hashedToken = hashedToken
    }
}

class GithubAuthenticationSerializer: JSONSerializer {
    init() { }
    
    func serialize(value: GithubAuthentication) -> JSON {
        var retVal:[String: JSON] = [:]
        retVal["id"] = Serialization._Int32Serializer.serialize(value.id)
        retVal["token"] = Serialization._StringSerializer.serialize(value.token)
        retVal["hashed_token"] = Serialization._StringSerializer.serialize(value.hashedToken)
        return .Dictionary(retVal)
    }
    
    func deserialize(json: JSON) -> GithubAuthentication {
        switch json {
            case .Dictionary(let dict):
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .Null)
                let token = Serialization._StringSerializer.deserialize(dict["token"] ?? .Null)
                let hashedToken = Serialization._StringSerializer.deserialize(dict["hashed_token"] ?? .Null)
                return GithubAuthentication(id: id, token: token, hashedToken: hashedToken)
            default:
                fatalError("Wrong Type")
        }
    }
}
