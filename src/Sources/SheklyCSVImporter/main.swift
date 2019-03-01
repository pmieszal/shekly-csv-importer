import SheklyCSVImporterCore

let importer = SheklyCSVImporter()

do {
    try importer.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
