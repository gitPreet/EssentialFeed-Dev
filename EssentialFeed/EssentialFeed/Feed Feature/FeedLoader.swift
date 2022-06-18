//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 01/06/22.
//

import Foundation

/*
 The test is forcing us to use Equatable since we cannot equate LoadFeedResult
 We conformed to Equatable just to make our tests work but in production we don't need it to be Equatable
 */

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error

    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
