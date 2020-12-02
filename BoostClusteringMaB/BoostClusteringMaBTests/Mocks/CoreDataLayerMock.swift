//
//  CoreDataLayerMock.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

@testable import BoostClusteringMaB
import CoreData

class CoreDataLayerMock: CoreDataManager {
    func add(place: Place, completion handler: CoreDataHandler?) {

    }

    func add(places: [Place], completion handler: CoreDataHandler?) {

    }

    func fetch(sorted: Bool) -> [ManagedPOI]? {
        return nil
    }

    func fetch(by classification: String, sorted: Bool) -> [ManagedPOI]? {
        return nil
    }

    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool) -> [ManagedPOI]? {
        return nil
    }

    func remove(poi: ManagedPOI, completion handler: CoreDataHandler?) {

    }

    func removeAll(completion handler: CoreDataHandler?) {

    }

    func makeFetchResultsController(southWest: LatLng, northEast: LatLng) -> NSFetchedResultsController<ManagedPOI> {
        return .init()
    }
}