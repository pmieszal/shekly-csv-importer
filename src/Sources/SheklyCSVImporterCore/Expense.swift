//
//  Expense.swift
//  SheklyCSVImporterCore
//
//  Created by Patryk Mieszała on 02/03/2019.
//

import Foundation

struct Expense: Codable {
    
    let amount: Double
    let date: Date
    let category: String
    let subcategory: String
    
}
