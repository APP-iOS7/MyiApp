import SwiftUI

public extension Label where Title == Text, Icon == Image {
    init(_ title: String, icon: Image) {
        self.init {
            Text(title)
        } icon: {
            icon.resizable()
        }
    }
}
