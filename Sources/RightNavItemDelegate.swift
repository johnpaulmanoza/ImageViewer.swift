
public protocol RightNavItemDelegate:class {
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapRightNavItem index:Int)
}

public protocol MiddleNavItemDelegate:class {
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapMiddleNavItem index:Int)
}
