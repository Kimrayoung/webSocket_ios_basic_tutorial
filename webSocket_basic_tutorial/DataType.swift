//
//  DataType.swift
//  webSocket_basic_tutorial
//
//  Created by 김라영 on 2023/04/24.
//

import Foundation

// MARK: - SocketResponse
struct SocketResponse: Codable {
    let op: String?
    let msg: Msg?
    
    enum CodingKeys: String, CodingKey {
        case op
        case msg = "x"
    }
}

// MARK: - X
struct Msg: Codable {
    let type, value, exchangeName, priceBase: String?

    enum CodingKeys: String, CodingKey {
        case type, value
        case exchangeName = "exchange_name"
        case priceBase = "price_base"
    }
}
