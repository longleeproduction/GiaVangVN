# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GiaVangVN is a multi-platform SwiftUI application for tracking gold prices and currency exchange rates in Vietnam. It includes both an iOS app and a companion watchOS app that share common code and ViewModels.

**Bundle Identifier**: `com.orientpro.goldprice`
**Minimum iOS Version**: 16.0
**Minimum watchOS Version**: 9.0

## Build and Development Commands

### Building the iOS App
```bash
# Build for Debug
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN -configuration Debug build

# Build for Release
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN -configuration Release build

# Clean build folder
xcodebuild -project GiaVangVN.xcodeproj -scheme GiaVangVN clean
```

### Building the Watch App
```bash
# Build Watch app for Debug
xcodebuild -project GiaVangVN.xcodeproj -scheme "GiaVang Watch App" -configuration Debug build

# Build Watch app for Release
xcodebuild -project GiaVangVN.xcodeproj -scheme "GiaVang Watch App" -configuration Release build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project GiaVangVN.xcodeproj -scheme GiaVangVN -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -project GiaVangVN.xcodeproj -scheme GiaVangVN -only-testing:GiaVangVNTests/TestClassName/testMethodName
```

### Package Dependencies

The project uses Swift Package Manager with the following dependencies:

- **SwifterSwift 8.0.0**: Utility extensions for Swift (https://github.com/SwifterSwift/SwifterSwift)
- **GoogleMobileAds 12.12.0**: Google AdMob SDK for monetization (https://github.com/googleads/swift-package-manager-google-mobile-ads)
- **GoogleUserMessagingPlatform 3.0.0**: Google's IAB Certified consent management for GDPR compliance (https://github.com/googleads/swift-package-manager-google-user-messaging-platform)

To resolve packages:
```bash
xcodebuild -resolvePackageDependencies -project GiaVangVN.xcodeproj
```

## Architecture

### Multi-Platform Structure

The project uses **code sharing** between iOS and watchOS targets:
- **Shared Code**: API layer (`Api/`), ViewModels, and Response/Request models are shared between both platforms
- **Platform-Specific**: UI views are separate for each platform
- **Watch App**: Located in `GiaVang Watch App/` directory, reuses ViewModels from `GiaVangVN/Modules/` for Dashboard, Gold, and Currency features

### App Entry Point

**iOS App** (`GiaVangVN/`):
- Entry: `GiaVangVNApp.swift` with `UIApplicationDelegateAdaptor` pattern
- AppDelegate: `Application/AppDelegate.swift` (currently minimal, used for future lifecycle hooks)
- AdMob Integration: `GoogleMobileAdsConsentManager` handles GDPR consent flow and ad initialization
- CoreData: `PersistenceController.shared` injected via environment into main view

**Watch App** (`GiaVang Watch App/`):
- Entry: `GiaVangApp.swift`
- Uses shared API services and ViewModels from iOS app

### Navigation Structure

The iOS app uses a **tab-based architecture** implemented in `MainView.swift` with 4 tabs:
1. **Dashboard** (Home) - `DashBoardView` with news, gold highlights, and currency summaries
2. **Gold Price** - `GoldView` with gold tracking and charts
3. **Currency** - `CurrencyView` with exchange rates
4. **Settings** - `SettingView` with app preferences

All feature views use `NavigationStack` for hierarchical navigation within each tab.

### Module Organization

Features are organized by module in `GiaVangVN/Modules/`:

- **Main/** - Tab navigation container (`MainView.swift`)
- **Dashboard/** - Home screen with gold/currency summaries and news
  - `DashBoardView.swift` - Main dashboard view
  - `DashBoardViewModel.swift` - Dashboard data management (shared with Watch)
  - `DashboardNewsView.swift`, `NewsView.swift` - News components
  - `Views/` - Subviews for gold and currency summaries
- **Gold/** - Gold price tracking
  - `GoldView.swift` - Main gold price list
  - `GoldViewModel.swift` - Gold data fetching and state (shared with Watch)
  - `GoldChartView.swift` - Chart visualizations
- **Currency/** - Currency exchange rates
  - `CurrencyView.swift` - Main currency list
  - `CurrencyViewModel.swift` - Currency data management (shared with Watch)
  - `CurrencyChartView.swift` - Chart visualizations
  - `CurrencyListItemView.swift`, `CurrencyItemRow.swift` - List components
- **Calculator/** - Gold calculation utilities (NEW)
  - `GoldCalculatorView.swift` - Gold price calculator UI
  - `GoldCalculatorViewModel.swift` - Calculator logic
  - `WeightConversionView.swift` - Weight unit conversion
  - `Calculator+View.swift`, `eNum+Cal.swift` - Supporting types
- **Setting/** - App settings and preferences

**MVVM Pattern**: All feature modules use the MVVM (Model-View-ViewModel) architecture with `ObservableObject` ViewModels and Combine framework for reactive updates.

### API Layer

Located in `GiaVangVN/Api/`, this layer handles all network communication:

**Base Configuration** (`Api.swift`):
- Base URL: `https://giavang.pro/services/v1`
- Custom URLSession with Vietnamese locale headers
- Error handling via `APIError` enum
- Date range enum `ListRange` for chart data (7d, 30d, 60d, 180d, 365d)

**Service Classes** (singletons):
- `GoldService` - Gold price data (`/gold`, `/dashboard/gold-price`, `/dashboard/gold-chart`, `/dashboard/gold-daily`)
- `CurrencyService` - Exchange rate data (`/currency`, `/dashboard/currency-price`, `/dashboard/currency-list`, `/dashboard/currency-daily`)
- `DashboardService` - Dashboard and news data (`/dashboard`, `/dashboard/news`)

**Data Models**:
- `Request/` - Request DTOs (e.g., `GoldPriceRequest`, `CurrencyDailyRequest`)
- `Response/` - Response DTOs (e.g., `GoldResponse`, `CurrencyResponse`, `DashboardResponse`, `NewsResponse`)

**Encryption** (`ApiDecryptor.swift`):
- Handles AES/CBC/PKCS7 decryption of API responses
- Uses hardcoded key/IV for `giavang.pro` API
- Decrypts base64-encoded encrypted payloads from certain endpoints

### CoreData Setup

- **Model**: `GiaVangVN.xcdatamodeld/GiaVangVN.xcdatamodel`
- **Controller**: `PersistenceController` in `Persistence.swift`
- **Instances**:
  - `shared` - Production instance
  - `preview` - Preview instance with 10 pre-populated `Item` entities for SwiftUI previews

### Shared Components

**Views** (`GiaVangVN/Views/`):
- `WebEmbedView.swift` - Web content embedding (for TradingView charts)
- `SFSafariView.swift` - Safari view controller wrapper
- `RoundedCorner.swift` - Custom corner rounding utility

**Extensions** (`GiaVangVN/Extensions/`):
Custom utility extensions for:
- `Application+Ext.swift` - UIApplication helpers
- `Array+Ext.swift` - Array utilities
- `Color+Ext.swift` - SwiftUI Color helpers
- `Device+Ext.swift` - Device detection
- `MPMedia+Ext.swift` - Media utilities
- `String+Ext.swift` - String manipulation
- `View+Ext.swift` - SwiftUI View modifiers

**AdMob Integration** (`GiaVangVN/Admob/`):
- `GoogleMobileAdsConsentManager.swift` - Handles GDPR consent flow using Google's User Messaging Platform (UMP)

### Network Configuration

`Info.plist` enables `NSAppTransportSecurity` with `NSAllowsArbitraryLoads` to support HTTP connections to Vietnamese APIs that may not use HTTPS.

## API Documentation (from README.md)

The app integrates with the `giavang.pro` API for gold and currency data. Key endpoints:

**Configuration Endpoints**:
- GET `/services/v1/gold` - Gold display configuration
- GET `/services/v1/currency` - Currency display configuration

**Gold Endpoints**:
- POST `/dashboard/gold-price` - Gold price for specific product
- POST `/dashboard/gold-chart` - Chart data (supports range: 7, 30, 60, 180, 365 days)
- POST `/dashboard/gold-daily` - Daily gold prices (branches: sjc, doji, btmc, mihong, btmh, phuquy, ngoctham, pnj)

**Currency Endpoints**:
- POST `/dashboard/currency-price` - Exchange rate for specific currency
- POST `/dashboard/currency-list` - Historical exchange rate list
- POST `/dashboard/currency-daily` - Daily exchange rates (branches: vcb, bidv)

**Dashboard Endpoints**:
- POST `/dashboard` - Dashboard summary data
- POST `/dashboard/news` - News feed

**External Integrations**:
- TradingView widgets embedded for technical analysis and charts
- Custom charts from `giavang.pro/chart.html`, `giavang.pro/box.html`, etc.

## Code Signing

The project uses **manual code signing**:
- Development Team: `XL8Q4B9F55` (for device builds)
- Provisioning Profile: "Wildcard - Dev"
- Bundle ID: `com.orientpro.goldprice`
- Watch Bundle ID: `com.orientpro.goldprice.watchkitapp`
