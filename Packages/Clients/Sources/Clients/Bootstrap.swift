import FirebaseCore
import GoogleSignIn

public enum AppBootstrap {
    public static func configure() {
        FirebaseApp.configure()
    }

    public static func handle(url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
