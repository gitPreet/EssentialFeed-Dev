//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 04/06/22.
//

import XCTest

class RemoteFeedLoader {

    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {

    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURL, url)
    }

    // MARK: - Helper methods

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    /*
     why makeSUT() return the tuple (sut, client).
     If it only return sut, we can access client like "sut.client".

     We could access the `sut.client` directly, but we recommend not doing it because the class properties are internal details. Ideally, the tests shouldn't access internal details directly. This way, we can change internal details without breaking the tests. For example, in a future lecture, all the properties will be made private without breaking the tests.

     */

    private class HTTPClientSpy: HTTPClient {

        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}
