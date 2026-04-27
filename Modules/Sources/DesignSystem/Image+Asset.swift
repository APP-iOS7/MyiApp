import SwiftUI

extension Image {
    public enum Analysis {
        public static let processing = Image("Processing", bundle: .module)
        public static let bellyPain = Image("BellyPain", bundle: .module)
        public static let burping = Image("Burping", bundle: .module)
        public static let coldHot = Image("ColdHot", bundle: .module)
        public static let hungry = Image("Hungry", bundle: .module)
        public static let lonely = Image("Lonely", bundle: .module)
        public static let scared = Image("Scared", bundle: .module)
        public static let tired = Image("Tired", bundle: .module)
        public static let unknown = Image("Unknown", bundle: .module)
    }

    public enum BabyStages {
        public static let newBorn = Image("NewBorn", bundle: .module)
        public static let infant = Image("Infant", bundle: .module)
        public static let toddler = Image("Toddler", bundle: .module)
        public static let child = Image("Child", bundle: .module)
        public static let discomfort = Image("Discomfort", bundle: .module)
    }

    public enum Records {
        public enum Colored {
            public static let bath = Image("Bath", bundle: .module)
            public static let sleep = Image("Sleep", bundle: .module)
            public static let snack = Image("Snack", bundle: .module)
        }

        public enum Plain {
            public static let babyMeal = Image("BabyMeal", bundle: .module)
            public static let breastFeeding = Image("BreastFeeding", bundle: .module)
            public static let pee = Image("Pee", bundle: .module)
            public static let poop = Image("Poop", bundle: .module)
            public static let powderedMilk = Image("PowderedMilk", bundle: .module)
            public static let pumpedMilk = Image("PumpedMilk", bundle: .module)
        }
    }

    public enum Settings {
        public static let agreement = Image("Agreement", bundle: .module)
        public static let appVersion = Image("AppVersion", bundle: .module)
        public static let babyInfo = Image("BabyInfo", bundle: .module)
        public static let notification = Image("Notification", bundle: .module)
        public static let privacy = Image("Privacy", bundle: .module)
        public static let versionCheck = Image("VersionCheck", bundle: .module)
    }

    public enum Logos {
        public static let google = Image("GoogleLogo", bundle: .module)
    }
}
