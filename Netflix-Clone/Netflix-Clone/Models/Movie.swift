//
//  Movie.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/13.
//

import Foundation

struct TrendingMoviesResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int
    let media_type: String?
    let origin_name: String?
    let origin_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let vote_average: Double
}