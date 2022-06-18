//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 06/06/22.
//

import Foundation

/*
 We would like to conform this RemoteFeedLoader to the FeedLoader protocol.
 But the FeedLoader protocol completion contains a result type whose Error is Error type.
 But in our RemoteFeedLoader, the result has a failure which has an error of the RemoteFeedLoader.Error type.
 We could move this to the FeedFeature module but in that case we would be leaking the domain specific error in the
 FeedFeature module which should be agnostic module and should not know if the error is coming from connectivity, database etc.
 */

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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, response))

            case .failure: completion(.failure(.connectivity))
            }
        }
    }
}
