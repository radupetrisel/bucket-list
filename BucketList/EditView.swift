//
//  EditView.swift
//  BucketList
//
//  Created by Radu Petrisel on 20.07.2023.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    let location: Location
    let onSave: (Location) -> Void
    
    @State private var name: String
    @State private var description: String
    
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Location name", text: $name)
                    TextField("Location description", text: $description)
                }
                
                Section {
                    switch loadingState {
                    case .loading:
                        ProgressView {
                            Text("Loading...")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                            + Text(": ")
                            + Text(page.description.capitalized)
                                .italic()
                        }
                    case .failure:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await loadPages()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    private func loadPages() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad URL")
            loadingState = .failure
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(Result.self, from: data)
            pages = result.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            loadingState = .failure
        }
    }
    
    
    enum LoadingState {
        case loading, loaded, failure
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: .preview) { _ in }
    }
}
