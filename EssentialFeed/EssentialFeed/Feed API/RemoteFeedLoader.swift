//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 06/06/22.
//

import Foundation

public final class RemoteFeedLoader {

    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, response))

            case .failure: completion(.failure(.connectivity))
            }
        }
    }

    /*
     Though we have decided to move the mapping logic to the FeedItemsMapper, we may have to return if self is nil on receiving the result.
        this is because we do not what the implementation of the HTTPClient would look like.
        If it is a singleton, it may outlive the RemoteFeedLoader, and we will recieve the completion callback even after the RemoteFeedLoader has been deallocated.. So it is upto us, if we want to  carry on with the code in the completion block even after remote feed loader has been deallocated.
     */
}
