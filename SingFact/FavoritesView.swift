//
//  FavoritesView.swift
//  SingFact
//
//  Created by Vinkas on 14/12/24.
//

import SwiftData
import SwiftUI
import VinkasUI

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var favorites: [Favorite]

    var body: some View {
        List {
            ForEach(favorites) { favorite in
                Text(favorite.text)
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .overlay(Group {
            if favorites.isEmpty {
                ToastView(toast: .init(type: .info, text: "No favorites yet. Swipe left or right to add the facts to your favorites."))
            }
        })
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                modelContext.delete(favorites[offset])
            }
        }
    }
}

#Preview {
    FavoritesView()
}
