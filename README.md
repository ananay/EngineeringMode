# 🛠️ Engineering Mode
EngineeringMode is a highly customizable iOS package to make debugging common things like Notifications, UserDefaults, Permissions and Networking easier.

<div>
  <img src="https://github.com/ananay/EngineeringMode/assets/5569219/edb32e6b-ccab-44e8-a4cb-969d1c71dae4" width="300" />
  <img src="https://github.com/ananay/EngineeringMode/assets/5569219/9150ba17-c0db-4988-bf8f-e108167b082e" width="300" />
  <img src="https://github.com/ananay/EngineeringMode/assets/5569219/2de1cdab-614e-4e5a-abb8-237ba3db5ae7" width="300" />
  <img src="https://github.com/ananay/EngineeringMode/assets/5569219/e4841876-4c0e-4775-ab84-90d84d7004ce" width="300" />
</div>



## Usage

`EngineeringMode` can be added to any SwiftUI view easily. Typically, it's used with a [Sheet](https://developer.apple.com/design/human-interface-guidelines/sheets).


### **Basic usage with a sheet**
```swift
import EngineeringMode

//...

.sheet(isPresented: $showingEngineeringModeSheet) {
  EngineeringMode()
}
```

### **Custom Views**

To add a custom view to the existing Engineering Mode screen, just pass in `customViews` and `customViewTitles`. Optionally, if you want Custom Views to show before the other views, then add `showCustomViewsFirst`.

```swift
EngineeringMode(
  customViews: [AnyView],
  customViewTitles: [String],
  showCustomViewsFirst: Bool
)
```

⚠️ Important: 
- `customViews` takes in an `AnyView` - please cast it to that.
- `customViews` and `customViewTitles` should have the same number of array elements! Each custom view should have a title, otherwise the app will crash.

**Example**

```swift
EngineeringMode(
  customViews: [AnyView(MyCustomView())],
  customViewTitles: ["Test"],
  showCustomViewsFirst: true
)
```
