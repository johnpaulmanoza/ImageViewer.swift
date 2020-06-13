import UIKit

public enum ImageViewerOption {
    
    case theme(ImageViewerTheme)
    case closeIcon(UIImage)
    case actionNavItemTitle(String, closeIcon: UIImage, moreIcon: UIImage, delegate: NavItemDelegate)
    case rightNavItemTitle(String, delegate: RightNavItemDelegate?)
    case rightNavItemIcon(UIImage, delegate: RightNavItemDelegate?)
}
