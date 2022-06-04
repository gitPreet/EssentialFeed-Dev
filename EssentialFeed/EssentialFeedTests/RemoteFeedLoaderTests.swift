//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 04/06/22.
//

import XCTest

class RemoteFeedLoader {

    func load() {
        //Since this is going to be production code, we would not want to capture URL's using the requestedURL property. Instead let's call some sort of a get method on the HTTPClient.
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static let shared = HTTPClient()

    private init() {}

    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }

    // this will be test code, so let's move the requested URL to a derived class.(Spy)
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
