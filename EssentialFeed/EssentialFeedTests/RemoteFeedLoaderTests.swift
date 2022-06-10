//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 04/06/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversConnectivityErrorOnClientError() {
        //Arrange
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)

        /*
         Right now we are stubbing the client error in the Arrange part (Setting error before load method). This is not reflecting the true asynchronous behaviour of the load method, which should ideally return the error after the get method is called.
         So we should move the error from the Arrange to the act part
         */

        //Act
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {
            capturedError.append($0)
        }

        XCTAssertEqual(capturedError, [.connectivity])
    }

    // MARK: - Helper methods

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {

        var requestedURLs = [URL]()
        var error: NSError?

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURLs.append(url)
            if let error = error {
                completion(error)
            }
        }
    }
}
