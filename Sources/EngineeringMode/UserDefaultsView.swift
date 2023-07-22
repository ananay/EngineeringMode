//
//  UserDefaultsView.swift
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI

@available(iOS 15.0, *)
struct UserDefaultsView: View {
    @State private var userDefaultsData: [(key: String, value: Any)] = []
    
    var body: some View {
        List(userDefaultsData, id: \.key) { item in
            VStack(alignment: .leading) {
                Text(item.key)
                    .font(.headline)
                Text(String(describing: item.value))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            fetchUserDefaultsData()
        }
    }
    
    /**
     * Fetches the user defaults and adds it to the State array.
     */
    func fetchUserDefaultsData() {
        userDefaultsData = []
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            userDefaultsData.append((key: key, value: value))
        }
    }
}
