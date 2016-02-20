//
//  AuthenticationRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-18.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import UIKit

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

class GithubAccessTokenRequest {
    let clientID: String
    let clientSecret: String
    let code: String
    
    init(clientID: String, clientSecret: String, code: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.code = code
    }
}

class GithubAccessTokenRequestSerializer: JSONSerializer {
    init() { }
    
    func serialize(value: GithubAccessTokenRequest) -> JSON {
        let retVal = "client_id=\(value.clientID)&client_secret=\(value.clientSecret)&code=\(value.code)"
        return .Str(retVal)
    }
    
    func deserialize(json: JSON) -> GithubAccessTokenRequest {
        fatalError("No Need for deserialize Access Token")
    }
}

class GithubAuthenticationRoutes {
    unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    func requestAuthentication(scopes:[String], clientID: String, redirectURI: String) {
        guard let login = self.client.baseHosts["login"] else { return }
        let path = "/login/oauth/authorize"
        // TODO: optimize params generate process, use a cooler way.
        let urlString = "\(login)\(path)?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scopes.joinWithSeparator(","))"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            fatalError("Client should have login URL")
        }
    }
    
    func requestAccessToken(clientID: String, clientSecret: String, code: String) -> RpcRequest<StringSerializer, StringSerializer> {
        let accessTokenRequest = GithubAccessTokenRequest(clientID: clientID, clientSecret: clientSecret, code: code)
        return RpcRequest(client: self.client, host: "login", route: "/login/oauth/access_token", method: .POST, params: ["":""], postParams: GithubAccessTokenRequestSerializer().serialize(accessTokenRequest), responseSerializer: StringSerializer(), errorSerializer: StringSerializer())
    }
}
