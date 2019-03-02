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
        
        let categoryImporter = CategoryImporter()
        
        let categories = try categoryImporter.getCategories(fromDirectory: filesDirectory)
        
    }
}
