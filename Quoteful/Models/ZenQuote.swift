//
//  ZenQuote.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 19.09.2025.
//

import Foundation

struct ZenQuote: Codable {
    let quote: String
    let author: String
    
    enum CodingKeys: String, CodingKey {
        case quote = "q"
        case author = "a"
    }
}
