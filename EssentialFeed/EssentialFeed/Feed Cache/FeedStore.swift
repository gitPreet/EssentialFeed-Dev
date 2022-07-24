//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 24/07/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    typealias InsertionCompletion = (Error?) -> Void
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
