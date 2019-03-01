import Foundation
import CSV

public final class SheklyCSVImporter {
    
    enum Error: Swift.Error {
        case missingFolderName
    }
    
    private let arguments: [String]
    
    private let fileManager = FileManager.default
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 1 else {
            throw Error.missingFolderName
        }
        
        let folderName = arguments[1]
        
        let home: URL = fileManager.homeDirectoryForCurrentUser
        let filesDirectory: URL = home.appendingPathComponent(folderName)
        
        let files: [String] = try fileManager.contentsOfDirectory(atPath: filesDirectory.path)
        let months: [String] = Locale.current.calendar.standaloneMonthSymbols
        
        let monthFiles: [String] = files
            .filter { months.contains($0.replacingOccurrences(of: "-Tabela 1.csv", with: "").lowercased()) }
            .sorted { left, right -> Bool in
                let leftIndex: Int = months.firstIndex(of: left.replacingOccurrences(of: "-Tabela 1.csv", with: "").lowercased()) ?? 0
                let rightIndex: Int = months.firstIndex(of: right.replacingOccurrences(of: "-Tabela 1.csv", with: "").lowercased()) ?? 0
                
                return leftIndex < rightIndex
        }
        
        let monthWithFilenameDictionary: [String: String] = months
            .reduce(into: [:]) { (dict, month) in
                let index = months.index(of: month)!
                
                dict[month] = monthFiles[index]
        }
        
        let categoriesImporter = CategoriesImporter()
        
        let categories = try categoriesImporter.getCategories(fromDirectory: filesDirectory)
        
    }
}

struct Category {
    let name: String
    let row: Int
}

final class CategoriesImporter {
    
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
        
        let homeCategories: [Category] = self.getCategories(fromSlice: homeCategoriesRowsSlice, orginalRows: rows)
        
        let flatCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Mieszkanie;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let flatCategories: [Category] = self.getCategories(fromSlice: flatCategoriesRowsSlice, orginalRows: rows)
        
        let transportCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Transport;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let transportCategories: [Category] = self.getCategories(fromSlice: transportCategoriesRowsSlice, orginalRows: rows)
        
        let hygieneCategoriesRowsSlice: ArraySlice<[String]> = rows
            .split(separator: [";Higiena;;;"])
            .last!
            .split(separator: ["; ;;;"])
            .first!
        
        let hygieneCategories: [Category] = self.getCategories(fromSlice: hygieneCategoriesRowsSlice, orginalRows: rows)
        
        //TODO: categories-subcategories
        
        return homeCategories + flatCategories + transportCategories + hygieneCategories
    }
    
    private func getCategories(fromSlice slice: ArraySlice<[String]>, orginalRows: [[String]]) -> [Category] {
        
        let rows: [String] = Array(slice).joined().compactMap { $0 }
        let rowsClean: [String] = rows.map { $0.replacingOccurrences(of: ";", with: "") }
        
        let categories: [Category] = rowsClean
            .reduce(into: []) { (categories, category) in
                guard category != "." else { return }
                
                let row = slice.filter { $0.contains { $0.contains(category) } }.first!
                let index = orginalRows.index(of: row)!
                
                let category: Category = Category(name: category, row: index + rowOffset)
                
                categories.append(category)
        }
        
        return categories
    }
}
