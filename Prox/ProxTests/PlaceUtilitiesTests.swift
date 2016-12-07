/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
import CoreLocation

@testable import Prox

private let Gregorian = Calendar.init(identifier: .gregorian)

class PlaceUtilitiesTests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    


    func testSortingByDistance() {
        // Mozilla London Office
        let currentLocation = CLLocation(latitude: 51.5046323, longitude: -0.0992547)

        let yelpProvider = ReviewProvider(url: "https://mozilla.org")
        // London Bridge Station

        let emptyCategories = (names: [""], ids: [""])
        let place1 = Place(id: "1", name: "Place 1", latLong: CLLocationCoordinate2D(latitude: 51.5054704, longitude: -0.0943248), categories: emptyCategories, yelpProvider: yelpProvider)
        // old Mozilla London office
        let place2 = Place(id: "2", name: "Place 2", latLong: CLLocationCoordinate2D(latitude: 51.5100773, longitude: -0.1257861), categories: emptyCategories, yelpProvider: yelpProvider)
        // Kensington Palace
        let place3 = Place(id: "3", name: "Place 3", latLong: CLLocationCoordinate2D(latitude: 51.4998605, longitude: -0.177838), categories: emptyCategories, yelpProvider: yelpProvider)
        let places = [place1, place2, place3]

        let sortedAscending = PlaceUtilities.sort(places: places, byDistanceFromLocation: currentLocation, ascending: true)
        XCTAssertNotNil(sortedAscending)
        XCTAssertEqual(sortedAscending[0].id, place1.id)
        XCTAssertEqual(sortedAscending[1].id, place2.id)
        XCTAssertEqual(sortedAscending[2].id, place3.id)

        let sortedDescending = PlaceUtilities.sort(places: places, byDistanceFromLocation: currentLocation, ascending: false)
        XCTAssertNotNil(sortedDescending)
        XCTAssertEqual(sortedDescending[0].id, place3.id)
        XCTAssertEqual(sortedDescending[1].id, place2.id)
        XCTAssertEqual(sortedDescending[2].id, place1.id)
    }

    /*
     * This logic can change a lot so it's not worth writing comprehensive tests for, I think.
     * This is more of a sanity check.
     */
    func testShouldShowPlaceByRatingAndReviewCount() {
        let lowRatingLowReviewPlace = getPlace(forRating: 1.0, reviewCount: 3)
        XCTAssertFalse(PlaceUtilities.shouldShowPlaceByRatingAndReviewCount(lowRatingLowReviewPlace))

        let highRatingHighReviewPlace = getPlace(forRating: 5.0, reviewCount: 3634)
        XCTAssertTrue(PlaceUtilities.shouldShowPlaceByRatingAndReviewCount(highRatingHighReviewPlace))
    }

    private func getPlace(forRating rating: Float, reviewCount: Int) -> Place {
        let yelpProvider = ReviewProvider(url: "url", rating: rating, reviews: nil, totalReviewCount: reviewCount)
        return Place(id: "id", name: "name", latLong: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                     categories: ([], []), yelpProvider: yelpProvider)
    }

    func testShouldShowPlaceByOpeningHoursIsOpenNow() {
        let mondayHours = OpenHours(hours: [.monday : [getOpenPeriod(openHour: 10, openMin: 0, closeHour: 20, closeMin: 0)]])
        let place = Place(id: "", name: "", latLong: getCoordOrigin(), categories: ([], []),
                          yelpProvider: ReviewProvider(url: ""), hours: mondayHours)

        let currentTime = getMonday(hour: 12, min: 0)
        XCTAssertTrue(PlaceUtilities.shouldShowByOpeningHours(place, atTime: currentTime))
    }

    func testShouldShowPlaceByOpeningHoursIsClosedNow() {
        let mondayHours = OpenHours(hours: [.monday : [getOpenPeriod(openHour: 10, openMin: 0, closeHour: 20, closeMin: 0)]])
        let place = Place(id: "", name: "", latLong: getCoordOrigin(), categories: ([], []),
                          yelpProvider: ReviewProvider(url: ""), hours: mondayHours)

        let currentTime = getMonday(hour: 9, min: 0)
        XCTAssertFalse(PlaceUtilities.shouldShowByOpeningHours(place, atTime: currentTime))
    }

    func testShouldShowPlaceByOpeningHoursHasNoHours() {
        let noHours = Place(id: "", name: "", latLong: getCoordOrigin(), categories: ([], []),
                            yelpProvider: ReviewProvider(url: ""))
        XCTAssertTrue(PlaceUtilities.shouldShowByOpeningHours(noHours, atTime: getMonday(hour: 0, min: 0)))
    }

    func testShouldShowPlaceByOpeningHoursHasNoHoursToday() {
        let noHoursMonday = OpenHours(hours: [.tuesday : [getOpenPeriod(openHour: 10, openMin: 0, closeHour: 20, closeMin: 0)]])
        let placeNoMonday = Place(id: "", name: "", latLong: getCoordOrigin(), categories: ([], []),
                                  yelpProvider: ReviewProvider(url: ""), hours: noHoursMonday)
        XCTAssertFalse(PlaceUtilities.shouldShowByOpeningHours(placeNoMonday, atTime: getMonday(hour: 10, min: 0)))
    }

    private func getCoordOrigin() -> CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }

    private func getOpenPeriod(openHour: Int, openMin: Int, closeHour: Int, closeMin: Int) -> OpenPeriodDateComponents {
        let open = DateComponents.init(calendar: Gregorian, hour: openHour, minute: openMin)
        let close = DateComponents.init(calendar: Gregorian, hour: closeHour, minute: closeMin)
        return (open, close)
    }

    private func getMonday(hour: Int, min: Int) -> Date {
        return DateComponents.init(calendar: Gregorian, year: 2016, month: 12, day: 5, hour: hour, minute: min).date!
    }
}
