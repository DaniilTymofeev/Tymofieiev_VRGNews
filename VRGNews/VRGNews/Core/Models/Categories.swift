//
//  Categories.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import SwiftUI

enum Category: String, CaseIterable {
    case business = "business"
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
    
    var displayName: String {
        switch self {
        case .general:
            return "General"
        case .business:
            return "Business"
        case .entertainment:
            return "Entertainment"
        case .health:
            return "Health"
        case .science:
            return "Science"
        case .sports:
            return "Sports"
        case .technology:
            return "Technology"
        }
    }
    
    var color: Color {
        switch self {
        case .general:
            return .blue
        case .business:
            return .green
        case .entertainment:
            return .yellow
        case .health:
            return .red
        case .science:
            return .purple
        case .sports:
            return .orange
        case .technology:
            return .blue
        }
    }
}
