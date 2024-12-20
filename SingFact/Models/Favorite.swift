//
//  Favorite.swift
//  SingFact
//
//  Created by Vinkas on 14/12/24.
//

import SwiftData

@Model
final class Favorite {
    @Attribute(.unique) var id: String
    @Attribute var text: String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
