import UIKit
import Foundation

/*
 MY GOALS
 1) Fetch all categories
 https://api.publicapis.org/categories
 
 2) Fetch all all Entry for a specific category
 https://api.publicapis.org/entries?category=animals
 
 */

// MARK: - MODEL
struct TopLevelObject : Decodable {
    let count: Int
    let entries: [Entry]
}

struct Entry : Decodable {
    let API: String
    let Description: String
    let Auth: String
    let HTTPS: Bool
    let Cors: String
    let Link: URL
    let Category: String
}

// MARK: - MODEL CONTROLLER
class EntryController {
    
    static let baseURL = URL(string: "https://api.publicapis.org/")
    static let entriesEndpoint = "entries"
    static let categoriesEndpoint = "categories"
    static let categoryQueryItemName = "category"
    
    static func fetchAllCategories(completion: @escaping ([String]) -> Void) {
        
        // 1 - URL
        guard let baseURL = baseURL else { return completion([]) }
        let categoriesURL = baseURL.appendingPathComponent(categoriesEndpoint)
        print(categoriesURL)
        
        // 2 - Data Task
        URLSession.shared.dataTask(with: categoriesURL) { (data, _, error) in
            // 3 - Error Handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion([])
            }
            
            // 4 - Check for Data
            guard let data = data else { return completion([]) }
            
            // 5 - Decode Data
            do {
                let categories = try JSONDecoder().decode([String].self, from: data)
                return completion(categories)
                
            } catch {
                print(error, error.localizedDescription)
                return completion([])
            }
        }.resume()
    }
    static func fetchAllEntries(for category: String, completion: @escaping ([Entry]) -> Void) {
        
        // URL
        guard let baseURL = baseURL else { return completion([]) }
        let entriesURL = baseURL.appendingPathComponent(entriesEndpoint)
        
        var urlComponents = URLComponents(url: entriesURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [URLQueryItem(name: categoryQueryItemName, value: category)]
        
        guard let finalURL = urlComponents?.url else { return completion([]) }
        print(finalURL)
        
        // DataTask
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in

            // Error Handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion([])
            }
            
            // Check for Data
            guard let data = data else { return completion([])}
            
            // Decode Data
            do {
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                let entries = topLevelObject.entries
                return completion(entries)
                
            } catch {
                print(error, error.localizedDescription)
                return completion([])
            }
            
        }.resume()
    }
}

// MARK: - "View Controller"
EntryController.fetchAllCategories { (categories) in
    for category in categories {
        print(category)
    }
}

EntryController.fetchAllEntries(for: "Social") { (entries) in
    for entry in entries {
        print("""
            --------------------------
            Name: \(entry.API)
            Desc: \(entry.Description)
            Link: \(entry.Link)
        """)
    }
}
