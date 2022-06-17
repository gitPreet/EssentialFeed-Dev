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
     If we use self.map instead of the FeedItemsMapper.map we may be introducing a retain cycle.
     this is because, the RemoteFeedLoader keeps a strong reference to the client and the block would keep a strong ref to the Remote Feed Loader. And we do not know if the implementation of the HTTP client captures the completion handler strongly or not.
        class HTTPClientImpl: HTTPClient {
            var completion: (HTTPClientResult) -> Void?
            func get( completion: ...) {
                self.completion = completion //this would cause a retain cycle

                RemoteFeedLoader -> HTTPClient -> Closure (completion block) -> RemoteFeedLoader
            }
        }
     */
}
