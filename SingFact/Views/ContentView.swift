//
//  ContentView.swift
//  SingFact
//
//  Created by Vinkas on 6/12/24.
//

import FirebaseFirestore
import SwiftData
import SwiftUI
import VinkasFirebase
import VinkasUI
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var settings: [Setting]
    @Query var facts: [Fact]
    @Query var favorites: [Favorite]

    @ObservedObject private var authModel = AuthModel()
    @State var factsText: String? = "Loading..."
    @State var factDocuments = [FactDocument]()
    @State var db: Firestore?
    @State var toast: Toast?

    @State private var showingForm = false
    @State private var submittingForm = false

    @State var text: String = ""
    @State var url: String = ""
    
    func initializeDatabase() {
        if (db == nil) {
            self.db = Firestore.firestore()
        }
    }
    
    func getFacts() async {
        initializeDatabase()
        db!.collection("random/facts/daily").addSnapshotListener({ snapshot, error in
            if (snapshot != nil) {
                factDocuments = snapshot!.documents.compactMap { (QueryDocumentSnapshot) -> FactDocument? in
                    return try? QueryDocumentSnapshot.data(as: FactDocument.self)
                }
                storeFacts()
                factsText = nil
            } else if (error != nil) {
                factsText = error?.localizedDescription
            } else {
                factsText = "Empty"
            }
        })
    }
    
    func storeFacts() {
        do {
            try modelContext.delete(model: Fact.self)
        } catch {
            fatalError("Could not delete facts: \(error.localizedDescription)")
        }

        factDocuments.forEach { factDocument in
            let fact = Fact(id: factDocument.id!, text: factDocument.text)
            modelContext.insert(fact)
        }

        let hasFacts = self.settings.first(where: { $0.id == "hasFacts" })
        if hasFacts != nil {
            hasFacts?.value = (factDocuments.count > 0).description
        } else {
            let hasFacts = Setting(id: "hasFacts", value: (factDocuments.count > 0).description)
            modelContext.insert(hasFacts)
        }
    }
    
    func AddFact() async {
        initializeDatabase()
        let userId = authModel.service.currentUser!.uid
        do {
            try await db!.collection("submissions/facts/\(userId)/").addDocument(data: [
                "text": text,
                "url": url
            ])
            
            text = ""
            url = ""
            showingForm = false
            toast = Toast(type: .success, text: "Successfully submitted the fact to review queue.")
        } catch {
            toast = Toast(type: .error, text: "There was an error submitting your request. \(error)")
        }
    }

    var body: some View {
        NavigationStack {
            if authModel.isAuthenticated {
                List {
                    if (factsText != nil) {
                        if (factsText == "Loading...") {
                            LoadingAnimation()
                        }

                        Text(factsText!)
                            .font(.subheadline)
                            .task {
                                await getFacts()
                            }
                    } else {
                        ForEach(facts) { fact in
                            Text(fact.text)
                                .swipeActions(edge: .leading) {
                                    SwipeActionButton(fact: fact)
                                }
                                .swipeActions(edge: .trailing) {
                                    SwipeActionButton(fact: fact)
                                }
                        }
                    }
                }
                .navigationTitle("Facts of the Day")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showingForm = true
                        }, label: {
                            Label("Add Fact", systemImage: "plus")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: FavoritesView(), label: {
                            Label("Favorites", systemImage: "heart")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("...", systemImage: "ellipsis.circle") {
                            Link(destination: URL(string: "https://singfact.com")!) {
                                Label("Visit Website", systemImage: "globe")
                            }
                            Link(destination: URL(string: "https://github.com/vinkashq/SingFact-iOS")!) {
                                Label("Star on GitHub", systemImage: "star")
                            }
                            Link(destination: URL(string: "https://github.com/vinkashq/SingFact-iOS")!) {
                                Label("View Source Code", systemImage: "text.document")
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                         Text("Random Singapore facts will be generated daily")
                             .font(.footnote)
                             .foregroundColor(.secondary)
                             .frame(maxWidth: .infinity)
                         }
                }
                .sheet(isPresented: $showingForm) {
                    Section(content: {
                        ZStack(alignment: .leading) {
                            if text.isEmpty {
                                VStack {
                                    Text("Enter the fact text...")
                                        .padding(.top, 10)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                            TextEditor(text: $text)
                                .opacity(text.isEmpty ? 0.75 : 1)
                        }
                        TextField("Source URL (optional)", text: $url)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }, header: {
                        Spacer()
                        Text("Add New Fact")
                            .font(.title3)
                    }, footer: {
                        HStack(spacing: 16) {
                            Button {
                                submittingForm = true
                                Task {
                                    await AddFact()
                                    submittingForm = false
                                }
                            } label: {
                                Text("Submit")
                            }
                            .disabled(submittingForm)
                            
                            Button {
                                showingForm = false
                            } label: {
                                Text("Cancel")
                            }
                            .foregroundStyle(Color.gray)
                        }
                    })
                    .scenePadding()
                    .presentationDetents([.medium])
                }
            } else {
                LoadingAnimation()
                    .navigationTitle("SingFact")
                    .task {
                        authModel.service.signInAnonymously()
                    }
            }
        }
        .toaster(toast: $toast)
        .onAppear(perform: authModel.onAppear)
        .onDisappear(perform: authModel.onDisappear)
    }
}

#Preview {
    ContentView()
}
