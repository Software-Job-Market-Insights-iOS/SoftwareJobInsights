//
//  ColorsModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation


struct ColorConfig {
    let lowColor: RGBColor
    let highColor: RGBColor
    let valueRange: ClosedRange<Double>
}

struct RGBColor {
    let red: Double
    let green: Double
    let blue: Double
   
    // Light colors
    static let lightGreen = RGBColor(red: 0.2, green: 0.8, blue: 0.8)  // Light teal
    static let lightBlue = RGBColor(red: 0.7, green: 0.7, blue: 1.0)
    static let lightPurple = RGBColor(red: 1.0, green: 0.7, blue: 1.0)
    static let lightOrange = RGBColor(red: 1.0, green: 0.9, blue: 0.7)

    // Dark colors
    static let darkGreen = RGBColor(red: 0, green: 0.5, blue: 0.5)    // Dark teal
    static let darkBlue = RGBColor(red: 0, green: 0, blue: 0.8)
    static let darkPurple = RGBColor(red: 0.5, green: 0, blue: 0.5)
    static let darkOrange = RGBColor(red: 0.8, green: 0.4, blue: 0)
}
