//
//  EngineeringMode.swift
//  Timebound
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI


@available(iOS 15.0, *)
public struct EngineeringMode: View {
    
    @State private var viewSelection = 0
    @State var defaultViews: [AnyView] = [
//        AnyView(EngineeringModeMainView()),
        AnyView(UserDefaultsView()),
        AnyView(NotificationsView()),
        AnyView(PermissionsView()),
        AnyView(NetworkView()),
    ]
    @State var defaultViewTitles: [String] = [
//        "Main",
        "User Defaults",
        "Notifications",
        "Permissions",
        "Network"
    ]
    
    @State var customViews: [AnyView]
    @State var customViewTitles: [String]
    @State var showCustomViewsFirst: Bool = true
    
    public init(customViews: [AnyView] = [], customViewTitles: [String] = [], showCustomViewsFirst: Bool = true) {
        
        self.customViews = customViews
        self.customViewTitles = customViewTitles
        self.showCustomViewsFirst = showCustomViewsFirst
        
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("🛠️ Engineering Mode")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 25)
                    .padding(.leading, 25)
                Spacer()
                Picker("View", selection: $viewSelection) {
                    if (showCustomViewsFirst == true) {
                        ForEach(0..<customViewTitles.count) { index in
                            Text(customViewTitles[index])
                                .tag(index)
                        }
                        ForEach(0..<defaultViewTitles.count) { index in
                            Text(defaultViewTitles[index])
                                .tag(index + customViewTitles.count)
                        }
                    }
                    
                    if (showCustomViewsFirst == false) {
                        ForEach(0..<defaultViewTitles.count) { index in
                            Text(defaultViewTitles[index])
                                .tag(index)
                        }
                        ForEach(0..<customViewTitles.count) { index in
                            Text(customViewTitles[index])
                                .tag(index + defaultViewTitles.count)
                        }
                    }
                }
                .pickerStyle(.automatic)
                .padding(.top, 25)
                .padding(.trailing, 10)
            }
        
            
            
            if (showCustomViewsFirst == false) {
                if (viewSelection < defaultViewTitles.count) {
                    defaultViews[viewSelection]
                } else {
                    customViews[viewSelection - defaultViewTitles.count]
                }
            } else {
                if (viewSelection < customViewTitles.count) {
                    customViews[viewSelection]
                } else {
                    defaultViews[viewSelection - customViewTitles.count]
                }
            }
            
        }
        
    }
}

@available(iOS 15, *)
struct EngineeringMode_Previews: PreviewProvider {
    @available(iOS 15.0, *)
    static var previews: some View {
        EngineeringMode()
    }
}
