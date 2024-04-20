//
//  ViewExtension.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 15.4.2024.
//

import SwiftUI

extension View {
    func format(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
