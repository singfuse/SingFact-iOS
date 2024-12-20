//
//  Data.swift
//  SingFact
//
//  Created by Vinkas on 17/12/24.
//

import SwiftData

@Model
final class Setting {
    @Attribute(.unique) var id: String
    @Attribute var value: String
    
    init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}
