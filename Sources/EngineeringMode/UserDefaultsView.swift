//
//  UserDefaultsView.swift
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI

struct UserDefaultItem: Identifiable {
    let id = UUID()
    let key: String
    let value: Any
}

@available(iOS 15.0, *)
struct UserDefaultsView: View {
    @State private var userDefaultsData: [UserDefaultItem] = []
    @State private var expandedItems: Set<UUID> = []

    var body: some View {
        List {
            ForEach(userDefaultsData) { item in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedItems.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedItems.insert(item.id)
                            } else {
                                expandedItems.remove(item.id)
                            }
                        }
                    )
                ) {
                    Text(String(describing: item.value))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                } label: {
                    Text(item.key)
                        .font(.headline)
                }
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
        userDefaultsData = UserDefaults.standard.dictionaryRepresentation()
            .map { UserDefaultItem(key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        UserDefaultsView()
            .onAppear {
                let defaults = UserDefaults.standard
                defaults.set("test@example.com", forKey: "userEmail")
                defaults.set(true, forKey: "isLoggedIn")
            }
    } else {
        Text("UserDefaultsView is not available on this platform.")
    }
}
