//
//  SingFact.swift
//  SingFact
//
//  Created by Vinkas on 15/12/24.
//

import FirebaseFirestore
import SwiftData
import Vinkas

public class SingFact: Vinkas, @unchecked Sendable {
    public static let shared = SingFact()

    public static func modelContainer() -> ModelContainer {
        let schema = Schema([
            Fact.self,
            Favorite.self,
            Setting.self
        ])
        
        let configurations = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier("group.com.singfact"),
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configurations])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override public func onFirebaseConfigurationComplete() {
        Firestore.firestore()
    }
}
