//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Preetham Baliga on 01/06/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}
