//
//  FlickrAPI.swift
//  DTMvvm_Example
//
//  Created by ToanDK on 8/28/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Moya

// 1:
enum FlickrAPI {
    
    // MARK: - Cameras
    case search(keyword: String, page: Int)
}

extension FlickrAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL { return URL(string: "https://api.flickr.com/services/rest")! }
    
    var path: String {
        switch self {
        case .search:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .search(let keyword, let page):
            let parameters: [String: Any] = [
                "method": "flickr.photos.search",
                "api_key": "dc4c20e9d107a9adfa54917799e44650", // please provide your API key
                "format": "json",
                "nojsoncallback": 1,
                "page": page,
                "per_page": 10,
                "text": keyword
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
