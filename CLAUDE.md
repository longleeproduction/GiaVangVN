# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GiaVangVN is a SwiftUI-based iOS application for tracking gold prices and currency exchange rates in Vietnam. The app uses a tab-based navigation structure with CoreData for local persistence.

## Build and Development Commands

### Building the Project
```bash
# Build for Debug
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN -configuration Debug build

# Build for Release
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN -configuration Release build

# Clean build folder
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN clean
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project GiaVangVN.xcodeproj -scheme GiaVangVN -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -project GiaVangVN.xcodeproj -scheme GiaVangVN -only-testing:GiaVangVNTests/TestClassName/testMethodName
```

### Package Dependencies
The project uses Swift Package Manager with the following dependency:
- **SwifterSwift 8.0.0**: Utility extensions for Swift (https://github.com/SwifterSwift/SwifterSwift)

To resolve packages:
```bash
xcodebuild -resolvePackageDependencies -project GiaVangVN.xcodeproj
```

## Architecture

### App Entry Point
- `GiaVangVNApp.swift`: Main app entry with CoreData persistence setup
- CoreData managed object context is injected via environment from `PersistenceController.shared`

### Navigation Structure
The app uses a **tab-based architecture** implemented in `MainView.swift` with 4 main tabs:
1. **Dashboard** (Home) - DashBoardView
2. **Gold Price** - GoldView
3. **Currency** - CurrencyView
4. **Settings** - SettingView

All feature views use `NavigationStack` for hierarchical navigation within each tab.

### Module Organization
Features are organized by module in `GiaVangVN/Modules/`:
- `Dashboard/` - Home screen (currently empty placeholder)
- `Gold/` - Gold price tracking (has dedicated ViewModel: GoldViewModel)
- `Currency/` - Currency exchange rates
- `Setting/` - App settings

Each module follows MVVM pattern where applicable (e.g., GoldViewModel for GoldView).

### CoreData Setup
- Model: `GiaVangVN.xcdatamodeld`
- Controller: `PersistenceController` in `Persistence.swift`
- Provides both production (`shared`) and preview (`preview`) instances
- Preview controller pre-populates 10 `Item` entities for SwiftUI previews

### Shared Components
- `Views/WebEmbedView.swift`: Reusable web content embedding (currently placeholder)
- `Extensions/`: Custom extensions for common types:
  - `Application+Ext.swift`
  - `Array+Ext.swift`
  - `Color+Ext.swift`
  - `Device+Ext.swift`
  - `MPMedia+Ext.swift`
  - `String+Ext.swift`
  - `View+Ext.swift`

### Network Configuration
`Info.plist` enables arbitrary loads via `NSAppTransportSecurity` to allow HTTP connections (useful for Vietnamese APIs that may not use HTTPS).

## Development Notes

- The project is in early stages with placeholder views for most features
- SwiftUI previews are available for all views via `#Preview` macro
- ViewModels use `ObservableObject` and Combine framework for reactive updates
- Extension files contain utility functions used across the app
