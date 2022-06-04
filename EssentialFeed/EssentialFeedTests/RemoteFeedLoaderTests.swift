//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 04/06/22.
//

import XCTest

class RemoteFeedLoader {

    func load() {
        // This is a problem.
        // The remote feed loader needs to locate the instance and needs to know which method to call
        // This is creating a strong coupling with the Singleton class.
        // Instead, we need to inject the HTTPClient in the RemoteFeedLoader.
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {

    static var shared = HTTPClient()

    func get(from url: URL) {

    }
}

class HTTPClientSpy: HTTPClient {

    var requestedURL: URL?

    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
