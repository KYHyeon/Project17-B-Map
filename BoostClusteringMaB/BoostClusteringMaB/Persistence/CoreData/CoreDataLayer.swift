//
//  CoreDataLayer.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/23.
//

import CoreData

enum CoreDataError: Error {
    case invalidCoordinate
    case invalidFetch
    case saveError
}

typealias CoreDataHandler = (Result<Void, CoreDataError>) -> Void
typealias POIHandler = (Result<[POI], CoreDataError>) -> Void

protocol CoreDataManager {
    func add(place: Place, completion handler: CoreDataHandler?)
    func add(places: [Place], completion handler: CoreDataHandler?)
    func fetch(sorted: Bool) -> [POI]?
    func fetch(by classification: String, sorted: Bool) -> [POI]?
    func fetch(southWest: LatLng,
               northEast: LatLng,
               sorted: Bool) -> [POI]?
    func remove(poi: POI, completion handler: CoreDataHandler?)
    func removeAll(completion handler: CoreDataHandler?)
}

final class CoreDataLayer: CoreDataManager {
    private lazy var childContext: NSManagedObjectContext = {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = CoreDataContainer.shared.mainContext
        return childContext
    }()

    private func add(place: Place, isSave: Bool, completion handler: CoreDataHandler? = nil) {
        guard let latitude = Double(place.y),
              let longitude = Double(place.x) else {
            handler?(.failure(.invalidCoordinate))
            return
        }
        
        childContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            let poi = POI(context: self.childContext)
            poi.id = place.id
            poi.category = place.category
            poi.imageURL = place.imageURL
            poi.latitude = latitude
            poi.longitude = longitude
            poi.name = place.name
            if isSave {
                do {
                    try self.save()
                } catch {
                    handler?(.failure(.saveError))
                    return
                }
            }
            handler?(.success(()))
        }
    }

    func add(place: Place, completion handler: CoreDataHandler? = nil) {
        add(place: place, isSave: true, completion: handler)
    }

    func add(places: [Place], completion handler: CoreDataHandler? = nil) {
        let group = DispatchGroup()
        
        places.forEach { place in
            group.enter()
            add(place: place, isSave: false) { result in
                switch result {
                case .failure(let error):
                    handler?(.failure(error))
                    return
                case .success(_):
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            do {
                try self.save()
                handler?(.success(()))
            } catch {
                handler?(.failure(.saveError))
            }
        }
    }

    func fetch(sorted: Bool = true) -> [POI]? {
        let request: NSFetchRequest = POI.fetchRequest()
        request.sortDescriptors = makeSortDescription(sorted: sorted)
    
        return try? childContext.fetch(request)
    }
    
    func fetch(by classification: String,
               sorted: Bool = true) -> [POI]? {
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", classification)
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        return try? childContext.fetch(request)
    }
    
    func fetch(southWest: LatLng,
               northEast: LatLng,
               sorted: Bool = true) -> [POI]? {
        guard northEast.lat > southWest.lat,
              northEast.lng > southWest.lng else {
            return nil
        }
        
        let latitudePredicate = NSPredicate(format: "latitude BETWEEN {%@, %@}",
                                            argumentArray: [southWest.lat, northEast.lat])
        let longitudePredicate = NSPredicate(format: "longitude BETWEEN {%@, %@}",
                                             argumentArray: [southWest.lng, northEast.lng])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latitudePredicate, longitudePredicate])
        
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = makeSortDescription(sorted: sorted)

        return try? childContext.fetch(request)
    }
    
    private func makeSortDescription(sorted: Bool) -> [NSSortDescriptor]? {
        let latitudeSort = NSSortDescriptor(key: "latitude", ascending: true)
        let longitudeSort = NSSortDescriptor(key: "longitude", ascending: true)
        
        return sorted ? [latitudeSort, longitudeSort] : nil
    }
    
    func remove(poi: POI, completion handler: CoreDataHandler?) {
        do {
            childContext.delete(poi)
            try self.save()
            handler?(.success(()))
        } catch {
            handler?(.failure(.saveError))
        }
    }
    
    func removeAll(completion handler: CoreDataHandler?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "POI")
        let removeAll = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try childContext.execute(removeAll)
            try self.save()
            handler?(.success(()))
        } catch {
            handler?(.failure(.saveError))
        }
    }
    
    private func save() throws {
        if childContext.hasChanges {
            try childContext.save()
            CoreDataContainer.shared.saveContext()
        }
    }
}
