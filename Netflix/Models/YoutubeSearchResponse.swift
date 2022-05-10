//
//  YoutubeSearchResponse.swift
//  Netflix
//
//  Created by Antonio Torres-Ruiz on 5/5/22.
//

import Foundation
struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
