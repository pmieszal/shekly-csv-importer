//
//  Wallet.swift
//  SheklyCSVImporterCore
//
//  Created by Patryk Mieszała on 23/03/2019.
//

import Foundation

struct Wallet: Codable {
    
    let name: String
    let expenses: [Expense]
    
}
