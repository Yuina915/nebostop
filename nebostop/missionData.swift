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
    
    init(wakeuptime: Date = Date(), mission: String = "") {
            self.wakeuptime = wakeuptime
            self.mission = mission
        }
}
