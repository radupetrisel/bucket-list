//
//  EditView.swift
//  BucketList
//
//  Created by Radu Petrisel on 20.07.2023.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    private let onSave: (Location) -> Void
    
    @StateObject private var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Location name", text: $viewModel.name)
                    TextField("Location description", text: $viewModel.description)
                }
                
                Section {
                    switch viewModel.loadingState {
                    case .loading:
                        ProgressView {
                            Text("Loading...")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
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
                    let newLocation = viewModel.updateLocation()
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await viewModel.loadPages()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
        self.onSave = onSave
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: .preview) { _ in }
    }
}
