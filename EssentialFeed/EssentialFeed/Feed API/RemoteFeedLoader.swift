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
                completion(self.map(data, response: response))
            case .failure: completion(.failure(.connectivity))
            }
        }
    }
    /*
     Here we feel that the mapping logic can be a seperate function to keep the load function light.
     But then we need to use self within the completion block above.
     This can cause a memory leak but we do not have checks for memory leaks. Let's add that
     */

    private func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
