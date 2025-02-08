//
//  EngineeringMode.swift
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI

@available(iOS 15.0, *)
public struct EngineeringMode: View {

  @State private var viewSelection = 0
  @State var defaultViews: [AnyView] = [
    AnyView(UserDefaultsView()),
    AnyView(NotificationsView()),
    AnyView(PermissionsView()),
    AnyView(NetworkView()),
    AnyView(MetricsView())
  ]
  @State var defaultViewTitles: [String] = [
    "User Defaults",
    "Notifications",
    "Permissions",
    "Network",
    "MetricKit"
  ]

  @State var customViews: [AnyView] = []
  @State var customViewTitles: [String]
  @State var showCustomViewsFirst: Bool = true

  public init(
    customViews: [AnyView] = [], customViewTitles: [String] = [], showCustomViewsFirst: Bool = true
  ) {

    guard customViews.count == customViewTitles.count else {
      fatalError(
        "Arguments `customViews` and `customViewTitles` must have the same number of array items. Please pass in a title for each Custom View!"
      )
    }

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
          if showCustomViewsFirst {
            ForEach(Array(customViewTitles.enumerated()), id: \.offset) { index, title in
              Text(title)
                .tag(index)
            }
            ForEach(Array(defaultViewTitles.enumerated()), id: \.offset) { index, title in
              Text(title)
                .tag(index + customViewTitles.count)
            }
          } else {
            ForEach(Array(defaultViewTitles.enumerated()), id: \.offset) { index, title in
              Text(title)
                .tag(index)
            }
            ForEach(Array(customViewTitles.enumerated()), id: \.offset) { index, title in
              Text(title)
                .tag(index + defaultViewTitles.count)
            }
          }
        }
        .pickerStyle(.automatic)
        .padding(.top, 25)
        .padding(.trailing, 10)
      }

      if showCustomViewsFirst == false {
        if viewSelection < defaultViewTitles.count {
          defaultViews[viewSelection]
        } else {
          customViews[viewSelection - defaultViewTitles.count]
        }
      } else {
        if viewSelection < customViewTitles.count {
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
