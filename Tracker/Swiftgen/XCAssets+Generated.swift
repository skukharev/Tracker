// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let appLogo = ImageAsset(name: "AppLogo")
  internal enum Colors {
    internal static let appBackground = ColorAsset(name: "App Background")
    internal static let appBlackUniversal = ColorAsset(name: "App Black Universal")
    internal static let appBlack = ColorAsset(name: "App Black")
    internal static let appBlue = ColorAsset(name: "App Blue")
    internal static let appDatePickerBackground = ColorAsset(name: "App Date Picker Background")
    internal static let appDatePickerTextColor = ColorAsset(name: "App Date Picker Text Color")
    internal static let appEnabledCreateButtonBackground = ColorAsset(name: "App Enabled Create Button Background")
    internal static let appEnabledCreateButtonText = ColorAsset(name: "App Enabled Create Button Text")
    internal static let appGray = ColorAsset(name: "App Gray")
    internal static let appLightGray = ColorAsset(name: "App Light Gray")
    internal static let appRed = ColorAsset(name: "App Red")
    internal static let appTabBarTopBorder = ColorAsset(name: "App TabBar Top Border")
    internal static let appWhite = ColorAsset(name: "App White")
    internal enum ColorSections {
      internal static let appColorSection1 = ColorAsset(name: "App Color Section 1")
      internal static let appColorSection10 = ColorAsset(name: "App Color Section 10")
      internal static let appColorSection11 = ColorAsset(name: "App Color Section 11")
      internal static let appColorSection12 = ColorAsset(name: "App Color Section 12")
      internal static let appColorSection13 = ColorAsset(name: "App Color Section 13")
      internal static let appColorSection14 = ColorAsset(name: "App Color Section 14")
      internal static let appColorSection15 = ColorAsset(name: "App Color Section 15")
      internal static let appColorSection16 = ColorAsset(name: "App Color Section 16")
      internal static let appColorSection17 = ColorAsset(name: "App Color Section 17")
      internal static let appColorSection18 = ColorAsset(name: "App Color Section 18")
      internal static let appColorSection2 = ColorAsset(name: "App Color Section 2")
      internal static let appColorSection3 = ColorAsset(name: "App Color Section 3")
      internal static let appColorSection4 = ColorAsset(name: "App Color Section 4")
      internal static let appColorSection5 = ColorAsset(name: "App Color Section 5")
      internal static let appColorSection6 = ColorAsset(name: "App Color Section 6")
      internal static let appColorSection7 = ColorAsset(name: "App Color Section 7")
      internal static let appColorSection8 = ColorAsset(name: "App Color Section 8")
      internal static let appColorSection9 = ColorAsset(name: "App Color Section 9")
    }
    internal enum TrackersCell {
      internal static let appTrackersCellButtonSplash = ColorAsset(name: "App Trackers Cell Button Splash")
    }
  }
  internal static let doneButton = ImageAsset(name: "DoneButton")
  internal enum Images {
    internal static let addTrackerImage = ImageAsset(name: "AddTrackerImage")
    internal static let onboardingPage1 = ImageAsset(name: "OnboardingPage1")
    internal static let onboardingPage2 = ImageAsset(name: "OnboardingPage2")
    internal static let statisticsStub = ImageAsset(name: "StatisticsStub")
    internal static let statisticsTabBarImage = ImageAsset(name: "StatisticsTabBarImage")
    internal static let trackersStub = ImageAsset(name: "TrackersStub")
    internal static let trackersTabBarImage = ImageAsset(name: "TrackersTabBarImage")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
