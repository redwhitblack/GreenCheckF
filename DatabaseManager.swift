//
//  DatabaseManager.swift
//  GreencheckF
//
import SQLite  // Stephen Celis's SQLite.swift
import Foundation

typealias Expression = SQLite.Expression

enum DatabaseError: Error {
    case notConnected
    case insertionFailed
    case unknown
}

struct DBProduct {
    var id: Int64?
    var barcode: String
    var name: String
    var details: String
    var createdAt: String
    var category: String
    var isFavorite: Bool
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    // MARK: - Table Definition
    private let products = Table("products")
    private let id = Expression<Int64>("id")
    private let barcode = Expression<String>("barcode")
    private let name = Expression<String>("name")
    private let details = Expression<String>("details")
    private let createdAt = Expression<String>("created_at")
    private let category = Expression<String>("category")
    private let isFavorite = Expression<Bool>("is_favorite")

    // Table definition
    private let scansTable = Table("scans")
    
    // Column definitions
    private let code = Expression<String>("code")
    private let isValid = Expression<Bool>("is_valid")
    private let scanDate = Expression<Date>("scan_date")

    // Change from private to public
    public init() {
        setupDatabase()
    }

    private func setupDatabase() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsPath = paths.first {
            do {
                db = try Connection("\(documentsPath)/db.sqlite3")
                try createTables()
                print("Database connected at: \(documentsPath)/db.sqlite3")
            } catch {
                print("DatabaseManager: Failed to connect: \(error)")
            }
        }
    }

    // Change from private to public
    public func createTables() throws {
        guard let db = db else { return }
        try db.run(products.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(barcode)
            table.column(name)
            table.column(details)
            table.column(createdAt)
            table.column(category)
            table.column(isFavorite, defaultValue: false)
        })
        try db.run(scansTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(code)
            table.column(isValid)
            table.column(scanDate)
        })
    }

    // MARK: - CRUD

    // Create
    func saveProduct(_ product: DBProduct) throws -> DBProduct {
        guard let db = db else { throw DatabaseError.notConnected }

        let insert = products.insert(
            barcode <- product.barcode,
            name <- product.name,
            details <- product.details,
            createdAt <- product.createdAt,
            category <- product.category,
            isFavorite <- product.isFavorite
        )

        do {
            let rowid = try db.run(insert)
            var saved = product
            saved.id = rowid
            return saved
        } catch {
            print("Insertion failed: \(error)")
            throw DatabaseError.insertionFailed
        }
    }

    // Read
    func getAllProducts() throws -> [DBProduct] {
        guard let db = db else { throw DatabaseError.notConnected }
        var items = [DBProduct]()

        for row in try db.prepare(products) {
            let product = DBProduct(
                id: row[id],
                barcode: row[barcode],
                name: row[name],
                details: row[details],
                createdAt: row[createdAt],
                category: row[category],
                isFavorite: row[isFavorite]
            )
            items.append(product)
        }
        return items
    }

    // Update
    func updateProduct(_ product: DBProduct) throws {
        guard let db = db else { throw DatabaseError.notConnected }
        guard let productID = product.id else { return }

        let item = products.filter(id == productID)
        let update = item.update(
            barcode <- product.barcode,
            name <- product.name,
            details <- product.details,
            createdAt <- product.createdAt,
            category <- product.category,
            isFavorite <- product.isFavorite
        )
        try db.run(update)
    }

    // Delete
    func deleteProduct(_ product: DBProduct) throws {
        guard let db = db else { throw DatabaseError.notConnected }
        guard let productID = product.id else { return }

        let item = products.filter(id == productID)
        try db.run(item.delete())
    }

    // Save code
    func saveCode(code scanCode: String, isValid valid: Bool) {
        do {
            guard let db = db else { return }
            
            let insert = scansTable.insert(
                code <- scanCode,
                isValid <- valid,
                scanDate <- Date()
            )
            
            try db.run(insert)
        } catch {
            print("Insert error: \(error)")
        }
    }
    
    // Get scanned codes
    func getScannedCodes() -> [(code: String, isValid: Bool, date: Date)] {
        var results: [(code: String, isValid: Bool, date: Date)] = []
        
        do {
            guard let db = db else { return [] }
            
            // Order by most recent first
            let query = scansTable.order(scanDate.desc)
            
            for row in try db.prepare(query) {
                results.append((
                    code: row[code],
                    isValid: row[isValid],
                    date: row[scanDate]
                ))
            }
        } catch {
            print("Query error: \(error)")
        }
        
        return results
    }
    
    // Delete all scans
    func deleteAllScans() {
        do {
            guard let db = db else { return }
            try db.run(scansTable.delete())
        } catch {
            print("Delete error: \(error)")
        }
    }
    
    // Delete code
    func deleteCode(withId scanId: Int64) {
        do {
            guard let db = db else { return }
            let scan = scansTable.filter(id == scanId)
            try db.run(scan.delete())
        } catch {
            print("Delete error: \(error)")
        }
    }
}
