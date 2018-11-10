//
//  ObacoModelService.swift
//  OBANetworkingKit
//
//  Created by Aaron Brethorst on 11/9/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation

@objc(OBAObacoModelService)
public class ObacoModelService: ModelService {
    private let apiService: ObacoService

    public init(apiService: ObacoService, dataQueue: OperationQueue) {
        self.apiService = apiService
        super.init(dataQueue: dataQueue)
    }

    // MARK: - Weather

    @objc public func getWeather(regionID: String) -> WeatherModelOperation {
        let service = apiService.getWeather(regionID: regionID)
        let data = WeatherModelOperation()

        transferData(from: service, to: data) { [unowned service, unowned data] in
            data.apiOperation = service
        }
        return data
    }

    // MARK: - Alarms

    @objc public func postAlarm(secondsBefore: TimeInterval, stopID: String, tripID: String, serviceDate: Int64, vehicleID: String, stopSequence: Int, userPushID: String) -> AlarmModelOperation {
        let service = apiService.postAlarm(secondsBefore: secondsBefore, stopID: stopID, tripID: tripID, serviceDate: serviceDate, vehicleID: vehicleID, stopSequence: stopSequence, userPushID: userPushID)
        let data = AlarmModelOperation()

        transferData(from: service, to: data) { [unowned service, unowned data] in
            data.apiOperation = service
        }

        return data
    }

    @objc public func deleteAlarm(alarm: Alarm) -> NetworkOperation {
        return apiService.deleteAlarm(url: alarm.url)
    }

    // MARK: - Vehicles

    @objc public func getVehicles(matching query: String) -> AgencyVehicleModelOperation {
        let service = apiService.getVehicles(matching: query)
        let data = AgencyVehicleModelOperation()

        transferData(from: service, to: data) { [unowned service, unowned data] in
            data.apiOperation = service
        }

        return data
    }
}
