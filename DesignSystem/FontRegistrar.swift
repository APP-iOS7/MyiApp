import CoreText
import Foundation

public enum FontRegistrar {
    public static func register() {
        registerFont(name: "BMJUA", extension: "otf")
    }

    private static func registerFont(name: String, extension ext: String) {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
            assertionFailure("DesignSystem: font \(name).\(ext) not found")
            return
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        guard !success, let cfError = error?.takeRetainedValue() else { return }

        let nsError = cfError as Error as NSError
        if nsError.code == CTFontManagerError.alreadyRegistered.rawValue { return }
        print("DesignSystem: failed to register font \(name).\(ext): \(nsError)")
    }
}
