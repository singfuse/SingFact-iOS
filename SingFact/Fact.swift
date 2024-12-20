//
//  Fact.swift
//  SingFact
//
//  Created by Vinkas on 15/12/24.
//

import SwiftData

@Model
final class Fact {
    @Attribute(.unique) var id: String
    @Attribute var text: String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

