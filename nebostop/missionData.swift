//
//  missionData.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//
import Foundation
import SwiftData

@Model
class MissionData {
    var wakeuptime: Date
    var mission: String
    var actualwakeuptime: Date?
    var reportImageData: Data?
    var reportCreatedAt: Date?
    var createdAt: Date?
    
    init(
        wakeuptime: Date = Date(),
        mission: String = "",
        reportImageData: Data? = nil,
        reportCreatedAt: Date? = nil,
        createdAt: Date? = Date()
    ) {
        self.wakeuptime = wakeuptime
        self.mission = mission
        self.reportImageData = reportImageData
        self.reportCreatedAt = reportCreatedAt
        self.createdAt = createdAt
    }
}
