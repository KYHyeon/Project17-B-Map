//
//  ClusteringTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

import XCTest
import NMapsMap
@testable import BoostClusteringMaB

class MapViewMock: NMFMapViewProtocol {
    var coveringBounds: NMGLatLngBounds
    var projection: NMFProjection

    init(coveringBounds: NMGLatLngBounds, projection: NMFProjection) {
        self.coveringBounds = coveringBounds
        self.projection = projection
    }
}

class NMFProjectionMock: NMFProjection {
    override func point(from coord: NMGLatLng) -> CGPoint {
        return CGPoint(x: coord.lat, y: coord.lng)
    }
}

class ClusterMock: Cluster {
    override func combine(other: Cluster) {
        self.center += other.center
    }

    override func area() -> [LatLng] {
        return [.init(lat: 30, lng: 40),
                .init(lat: 40, lng: 50),
                .init(lat: 50, lng: 60)]
    }
}

class ClusteringTests: XCTestCase {
    func test_init() {
        // Given
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }
}
