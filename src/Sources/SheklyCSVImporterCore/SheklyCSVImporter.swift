import Foundation
import CSV

public final class SheklyCSVImporter {
    
    enum Error: Swift.Error {
        case missingFolderName
        case jsonFileCreation
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
        
        let categoryImporter = CategoryImporter()
        let categories = try categoryImporter.getCategories(fromDirectory: filesDirectory)
        
        let expenseImporter = ExpenseImporter()
        let expenses = try expenseImporter.getExpenses(forMonthWithFilenameDictionary: monthWithFilenameDictionary, months: months, filesDirectory: filesDirectory, categories: categories)
        
        let jsonCreator = JSONCreator()
        let jsonData = try jsonCreator.getJSONData(fromExpenses: expenses)
        
        let jsonPath = filesDirectory.appendingPathComponent("ExpensesJSON.shekly")
        
        let attributes: [FileAttributeKey : Any] = [
            FileAttributeKey.type: "shekly"
        ]
        
        let result = fileManager.createFile(atPath: jsonPath.path, contents: jsonData, attributes: attributes)
        
        guard result == true else {
            throw Error.jsonFileCreation
        }
    }
}
