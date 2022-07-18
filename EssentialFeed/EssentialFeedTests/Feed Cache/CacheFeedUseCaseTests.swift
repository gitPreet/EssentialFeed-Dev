//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 18/07/22.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] (error) in
            if error == nil {
                self.store.insert(items, timestamp: currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0

    private var deletionCompletions = [DeletionCompletion]()

    var insertions = [(items: [FeedItem], timestamp: Date)]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items: items, timestamp: timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    func test_save_requestsCacheInsertionUponSuccessfulDeletion() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT()

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_requestsCacheInsertionWithTimestampUponSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT {
            timestamp
        }

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions[0].timestamp, timestamp)
        XCTAssertEqual(store.insertions[0].items, items)
    }

    // MARK: - Helper methods

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }

    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
