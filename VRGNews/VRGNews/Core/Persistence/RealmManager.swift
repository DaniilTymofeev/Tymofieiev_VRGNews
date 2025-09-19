//
//  RealmManager.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift

// MARK: - Generic Realm Manager
class RealmManager {
    static let shared = RealmManager()
    
    private let realm: Realm
    
    private init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Generic Save Operations
    func save<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) {
        do {
            try realm.write {
                realm.add(object, update: update)
            }
        } catch {
            print("Error saving \(T.self): \(error)")
        }
    }
    
    func saveArray<T: Object>(_ objects: [T], update: Realm.UpdatePolicy = .modified) {
        do {
            try realm.write {
                realm.add(objects, update: update)
            }
        } catch {
            print("Error saving \(T.self) array: \(error)")
        }
    }
    
    // MARK: - Generic Delete Operations
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting \(T.self): \(error)")
        }
    }
    
    func deleteById<T: Object>(_ type: T.Type, id: Any) {
        guard let object = realm.object(ofType: type, forPrimaryKey: id) else { return }
        delete(object)
    }
    
    func deleteAll<T: Object>(_ type: T.Type) {
        do {
            try realm.write {
                realm.delete(realm.objects(type))
            }
        } catch {
            print("Error deleting all \(T.self): \(error)")
        }
    }
    
    // MARK: - Generic Fetch Operations
    func fetchAll<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func fetchById<T: Object>(_ type: T.Type, id: Any) -> T? {
        return realm.object(ofType: type, forPrimaryKey: id)
    }
    
    func fetchFiltered<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchSorted<T: Object>(_ type: T.Type, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return realm.objects(type).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    func fetchFilteredAndSorted<T: Object>(_ type: T.Type, predicate: NSPredicate, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return realm.objects(type).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    // MARK: - Generic Count Operations
    func getCount<T: Object>(_ type: T.Type) -> Int {
        return realm.objects(type).count
    }
    
    func getFilteredCount<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Int {
        return realm.objects(type).filter(predicate).count
    }
    
    // MARK: - Generic Update Operations
    func update<T: Object>(_ type: T.Type, id: Any, updateBlock: @escaping (T) -> Void) {
        guard let object = realm.object(ofType: type, forPrimaryKey: id) else { return }
        
        do {
            try realm.write {
                updateBlock(object)
            }
        } catch {
            print("Error updating \(T.self): \(error)")
        }
    }
}
