//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 04/06/22.
//

import XCTest

class RemoteFeedLoader {

    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        /*
         So far we have been hardcoding the URL, but there can be multiple URLs like staging / dev / prod.
         It is not the responsibility of the RemoteFeedLoader to decide or know what is the URL.
         It should be given to it instead. Let's inject the URL
         */
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {

    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {

    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
