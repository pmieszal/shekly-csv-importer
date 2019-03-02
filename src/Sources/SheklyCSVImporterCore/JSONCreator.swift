//
//  JSONCreator.swift
//  SheklyCSVImporterCore
//
//  Created by Patryk Mieszała on 02/03/2019.
//

import Foundation

final class JSONCreator {
    
    let encoder: JSONEncoder
    
    init() {
        let encoder: JSONEncoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .useDefaultKeys
        
        self.encoder = encoder
    }
    
    func getJSONData(fromExpenses expenses: [Expense]) throws -> Data {
        let data = try encoder.encode(expenses)
        
        return data
    }
}
