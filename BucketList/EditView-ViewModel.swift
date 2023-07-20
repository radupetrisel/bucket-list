//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Radu Petrisel on 20.07.2023.
//

import Foundation

extension EditView {
    @MainActor final class ViewModel: ObservableObject {
        let location: Location
        
        @Published var name: String
        @Published var description: String
        
        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()
        
        init(location: Location) {
            self.location = location
            
            _name = Published(initialValue: location.name)
            _description = Published(initialValue: location.description)
        }
        
        func updateLocation() -> Location {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            
            return newLocation
        }
        
        func loadPages() async {
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
}
