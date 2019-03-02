//
//  CategoryImporter.swift
//  SheklyCSVImporterCore
//
//  Created by Patryk Mieszała on 02/03/2019.
//

import Foundation
import CSV

final class CategoryImporter {
    
    enum Error: Swift.Error {
        case missingCategoriesFile
    }
    
    private let fileManager = FileManager.default
    private let rowOffset: Int = 50
    
    func getCategories(fromDirectory directory: URL) throws -> [Category] {
        let files = try fileManager.contentsOfDirectory(atPath: directory.path)
        
        guard let categoryFileIndex: Int = files.index(of: "Wzorzec kategorii-Tabela 1.csv") else {
            throw Error.missingCategoriesFile
        }
        
        let categoryFilename: String = files[categoryFileIndex]
        let categoryUrl = directory.appendingPathComponent(categoryFilename)
        
        let stream = InputStream(url: categoryUrl)!
        let csv: CSVReader = try! CSVReader(stream: stream)
        
        var rows: [[String]] = []
        
        while let row = csv.next() {
            rows.append(row)
        }
        
        let homeCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Dom;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let homeCategories: [Category] = self.getSubcategories(fromSlice: homeCategoriesRowsSlice, orginalRows: rows, categoryName: "Dom")
        
        let flatCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Mieszkanie;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let flatCategories: [Category] = self.getSubcategories(fromSlice: flatCategoriesRowsSlice, orginalRows: rows, categoryName: "Mieszkanie")
        
        let transportCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Transport;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let transportCategories: [Category] = self.getSubcategories(fromSlice: transportCategoriesRowsSlice, orginalRows: rows, categoryName: "Transport")
        
        let hygieneCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Higiena;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let hygieneCategories: [Category] = self.getSubcategories(fromSlice: hygieneCategoriesRowsSlice, orginalRows: rows, categoryName: "Higiena")
        
        return homeCategories + flatCategories + transportCategories + hygieneCategories
    }
    
    private func getSubcategories(fromSlice slice: ArraySlice<[String]>, orginalRows: [[String]], categoryName: String) -> [Category] {
        
        let rows: [String] = Array(slice).joined().compactMap { $0 }
        let rowsClean: [String] = rows.map { $0.replacingOccurrences(of: ";", with: "") }
        
        let categories: [Category] = rowsClean
            .reduce(into: []) { (categories, subcategory) in
                guard subcategory != "." else { return }
                
                let row = slice.filter { $0.contains { $0.contains(subcategory) } }.first!
                let index = orginalRows.index(of: row)!
                
                let category: Category = Category(name: categoryName, subcategory: subcategory, row: index + rowOffset)
                
                categories.append(category)
        }
        
        return categories
    }
}
