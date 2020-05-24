import UIKit

public enum ImageViewerOption {
    
    case theme(ImageViewerTheme)
    case closeIcon(UIImage)
    case middleNavItemTitle(String, rightIcon: UIImage, middleDelegate: MiddleNavItemDelegate?, rightDelegate: RightNavItemDelegate?)
    case rightNavItemTitle(String, delegate: RightNavItemDelegate?)
    case rightNavItemIcon(UIImage, delegate: RightNavItemDelegate?)
}
