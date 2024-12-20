//
//  FactDocument.swift
//  SingFact
//
//  Created by Vinkas on 11/12/24.
//

import SwiftUI
import FirebaseFirestore

struct FactDocument: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
}
