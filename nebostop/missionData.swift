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
    var enteredByIconName: String?
    var enteredByProfileImageData: Data?
    
    init(
        wakeuptime: Date = Date(),
        mission: String = "",
        reportImageData: Data? = nil,
        reportCreatedAt: Date? = nil,
        createdAt: Date? = Date(),
        enteredByIconName: String? = nil,
        enteredByProfileImageData: Data? = nil
    ) {
        self.wakeuptime = wakeuptime
        self.mission = mission
        self.reportImageData = reportImageData
        self.reportCreatedAt = reportCreatedAt
        self.createdAt = createdAt
        self.enteredByIconName = enteredByIconName
        self.enteredByProfileImageData = enteredByProfileImageData
    }
}
