//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 20/06/22.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {

    let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url) { _ in }

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "Error", code: 0)
        session.stub(url: url, error: error)

        let sut = URLSessionHTTPClient(session: session)

        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure. Got \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: Helper methods

    private class HTTPSessionSpy: HTTPSession {

        private var stubs = [URL: Stub]()

        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }

        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couln't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }

    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
    }

    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0

        func resume() {
            resumeCallCount += 1
        }
    }
}

/*
 End-to-end testing of network requests refers to a testing strategy that checks the integration between the client and server communication, by performing real HTTP requests.

 A downside to end-to-end tests for us is that we don’t have a backend to talk to yet (and we don’t want to use it as an excuse to be “blocked”). Also, because of hitting the network, other downsides to this type of tests are: they require a network connection to run, they can be flaky (as network requests may fail, the tests may sometimes fail unexpectedly), and they can be slow (depending on network performance).

 Although a valid solution, there are faster and more reliable alternatives to testing the network requests at the component level. We believe it would be much more beneficial at this stage of development to test URLSessionHTTPClient in isolation. Later on, we can add some end-to-end tests to guarantee correct communication with our backend.


 Testing the URLSession implementation by subclassing and spying/stubbing its methods is a testing strategy that targets the component level without hitting a real HTTP request. It can be faster and more reliable, but we should keep in mind that subclass mocking can be dangerous when we subclass types we don’t own. From our point of view, URLSession is a 3rd-party class (a class we don’t own) which we don’t have access to its implementation. We believe that by not owning the mocked class, we inherently increase the risk in our codebase because of the possible wrongful assumptions we make about it’s mocked behavior. For example, we were surprised when a crash occurred in a test because the FakeURLSessionDataTask subclass didn't override the URLSessionDataTask.resume() instance method. Additionally, URLSession and its collaborators (e.g., URLSessionTask) expose a plethora of methods that we are not overriding in our mock, increasing the risk of wrongful assumptions and future runtime crashes.

 Another downside to subclass mocking is the tight coupling between the tests with the production code. For example, when mocking, the tests end up asserting precise method calls (first we assert that we’ve created a data task with a given URL using a specific API, then we assert that we’ve called resume to start the request, and only then we can assert the behavior we expect).

 When possible, we strive to find strategies that decouple the tests from the production implementation. Doing so allows us to assert only the expected behavior instead of precise method calls. When we decouple the test from the implementation, the production code can be more easily refactored/changed without breaking the tests (as long as we keep the same behavior).

 */

/*
 Another approach for testing the URLSession-based solution is to use protocols that mimic the desired interfaces we’d like to spy on. For example, in the episode, we created a <HTTPSession> protocol with only the specific URLSession method we care about. The URLSessionHTTPClient then collaborates with the <HTTPSession> protocol instead of the concrete URLSession type. By doing so, we believe we improved the test code by hiding unnecessary details about the URLSession APIs. Also, we avoid overriding any methods, oppositely to the mocking by subclassing testing strategy, as we only have to implement and maintain specific methods we care about.

 With the protocol-based mocking strategy we may have solved the mocked assumptions problem of the subclass-based strategy, but we still haven’t solved the tight coupling with the URLSession APIs since the protocols are mimicking its method signatures.

 Additionally, by adding a set of protocols for testing the URLSession-based implementation, we introduce a lot of noise in our production code, as the protocols are created solely for testing purposes.
 */
