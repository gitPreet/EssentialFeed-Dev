//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 01/06/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
