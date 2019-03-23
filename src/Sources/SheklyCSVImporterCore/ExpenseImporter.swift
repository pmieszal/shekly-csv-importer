//
//  ExpenseImporter.swift
//  SheklyCSVImporterCore
//
//  Created by Patryk Mieszała on 02/03/2019.
//

import Foundation
import CSV

final class ExpenseImporter {
    
    private let fileManager = FileManager.default
    private let daysIndexesRange = 8...38
    
    func getExpenses(forMonthWithFilenameDictionary dictionary: [String: String], months: [String], filesDirectory directory: URL, categories: [Category]) throws -> [Expense] {
        
        let expenses: [Expense] = try dictionary
            .map { (month, filename) -> [Expense] in
                let fileUrl: URL = directory.appendingPathComponent(filename)
                let monthIndex: Int = months.index(of: month)!
                let expenses: [Expense] = try getExpenses(forFileUrl: fileUrl, monthIndex: monthIndex, categories: categories)
                
                return expenses
            }
            .joined()
            .compactMap { $0 }
        
        return expenses
    }
    
    private func getExpenses(forFileUrl fileUrl: URL, monthIndex: Int, categories: [Category]) throws -> [Expense] {
        
        let stream = InputStream(url: fileUrl)!
        let csv: CSVReader = try! CSVReader(stream: stream)
        
        var rows: [[String]] = []
        
        while let row = csv.next() {
            rows.append(row)
        }
        
        let expenses: [Expense] = categories
            .map { category -> [Expense] in
                let row: [String] = rows[category.row]
                let rowString: String = row.reduce("") { result, next -> String in
                    if result.isEmpty {
                        return next
                    }
                    
                    return result + "," + next
                }
                
                let rowStringSeparatedByWhitespaces: String = rowString.replacingOccurrences(of: ";", with: " ; ")
                let elements: [String.SubSequence] = rowStringSeparatedByWhitespaces.split(separator: ";")
                
                let datesWithAmounts: [Date: Double] = daysIndexesRange
                    .reduce([:]) { (dict, dayIndex) -> [Date: Double] in
                        
                        var dict: [Date: Double] = dict
                        let amountRaw: String = String(elements[dayIndex])
                        let amountClean: String = amountRaw
                            .replacingOccurrences(of: "zł", with: "")
                            .replacingOccurrences(of: " ", with: "")
                        
                        guard amountClean.isEmpty == false else { return dict }
                        
                        let nf = NumberFormatter()
                        nf.decimalSeparator = ","
                        
                        guard let amountNumber: NSNumber = nf.number(from: amountClean) else { return dict }
                        
                        let amount: Double = amountNumber.doubleValue
                        let dayNumberIndex: ClosedRange<Int>.Index = daysIndexesRange.index(of: dayIndex)!
                        let dayNumber: Int = daysIndexesRange.distance(from: daysIndexesRange.startIndex, to: dayNumberIndex)
                        let dateString: String = "\(dayNumber + 1) \(monthIndex + 1) 2019"
                        
                        let df = DateFormatter()
                        df.dateFormat = "d M yyyy"
                        df.locale = Locale.current
                        df.timeZone = TimeZone(secondsFromGMT: 0)!
                        
                        guard let date = df.date(from: dateString) else { return dict }
                        
                        dict[date] = amount
                        
                        return dict
                }
                
                let expenses: [Expense] = datesWithAmounts
                    .map { date, amount -> Expense in
                        return Expense(amount: amount, date: date, category: category.name, subcategory: category.subcategory)
                }
                
                return expenses
            }
            .joined()
            .compactMap { $0 }
        
        return expenses
    }
}
