//
//  FlickrService.swift
//  DDMvvm_Example
//
//  Created by ToanDK on 8/28/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class FlickrService {
//    static let shared = FlickrService()
    
    private let flickrProvider = MoyaProvider<FlickrAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func search(keyword: String, page: Int) -> Single<FlickrSearchResponse> {
        return flickrProvider.rx
            .request(.search(keyword: keyword, page: page))
            .filterSuccessfulStatusAndRedirectCodes()
            .mapObject(FlickrSearchResponse.self)
    }
}
