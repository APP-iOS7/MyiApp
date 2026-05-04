import SwiftUI

extension Label where Title == Text, Icon == Image {
    public init(_ title: String, icon: Image) {
        self.init {
            Text(title)
        } icon: {
            icon.resizable()
        }
    }
}
