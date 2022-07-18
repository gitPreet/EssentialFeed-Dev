//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Preetham Baliga on 18/07/22.
//

import XCTest

class LocalFeedLoader {
    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
