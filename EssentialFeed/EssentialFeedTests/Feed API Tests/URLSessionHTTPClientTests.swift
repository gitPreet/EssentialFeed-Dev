//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 20/06/22.
//

import XCTest

class URLSessionHTTPClient {

    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url)
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "http://any-url.com")!

        sut.get(from: url)

        XCTAssertEqual(session.recievedURLs, [url])
    }

    private class URLSessionSpy: URLSession {

        var recievedURLs = [URL]()

        override func dataTask(with url: URL) -> URLSessionDataTask {
            recievedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
