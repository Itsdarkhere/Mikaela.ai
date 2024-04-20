//
//  Recording.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 15.4.2024.
//

import Foundation
import SwiftData

@Model
class Recording {
    @Attribute(.unique) var id: String
    var title: String
    var fileName: String
    var transcript: String
    var createdAt = Date()
    
    init(id: String, title: String, fileName: String, transcript: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.transcript = transcript
        self.createdAt = createdAt
    }
}
