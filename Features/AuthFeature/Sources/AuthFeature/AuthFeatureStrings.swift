import Foundation

private final class BundleToken {}

public enum AuthFeatureStrings {
    private static let bundle = Bundle(for: BundleToken.self)

    public static let title = LocalizedStringResource(
        "My i",
        defaultValue: "My i",
        bundle: .atURL(bundle.bundleURL)
    )
    public static let subtitle = LocalizedStringResource(
        "쉽고 편한 육아 기록 앱",
        defaultValue: "쉽고 편한 육아 기록 앱",
        bundle: .atURL(bundle.bundleURL)
    )
    public static let googleLoginButtonTitle = LocalizedStringResource(
        "Sign in with Google",
        defaultValue: "Sign in with Google",
        bundle: .atURL(bundle.bundleURL)
    )
    public static let appleLoginButtonTitle = LocalizedStringResource(
        "Apple로 시작하기",
        defaultValue: "Apple로 시작하기",
        bundle: .atURL(bundle.bundleURL)
    )
}
