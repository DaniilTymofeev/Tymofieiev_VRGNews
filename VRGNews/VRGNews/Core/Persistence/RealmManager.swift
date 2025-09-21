//
//  RealmManager.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift

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
    
    func fetchFiltered<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchFilteredAndSorted<T: Object>(_ type: T.Type, predicate: NSPredicate, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return realm.objects(type).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
    }
}
