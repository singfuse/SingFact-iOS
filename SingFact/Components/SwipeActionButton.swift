//
//  SwipeActionButton.swift
//  SingFact
//
//  Created by Vinkas on 14/12/24.
//

import SwiftData
import SwiftUI

struct SwipeActionButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query var favorites: [Favorite]
    var fact: Fact
    
    public init(fact: Fact) {
        self.fact = fact
    }
    
    var body: some View {
        let favorite = favorites.first(where: { $0.id == fact.id })

        if (favorite != nil) {
            Button {
                modelContext.delete(favorite!)
            } label: {
                Label("Remove Favorite", systemImage: "heart.slash")
            }
        } else {
            Button {
                let favorite = Favorite(id: fact.id, text: fact.text)
                modelContext.insert(favorite)
            } label: {
                Label("Add Favorite", systemImage: "heart")
            }
            .tint(Color.pink)
        }
    }
}
