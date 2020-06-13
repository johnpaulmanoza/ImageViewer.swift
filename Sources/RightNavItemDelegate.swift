
public protocol RightNavItemDelegate:class {
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapRightNavItem index:Int)
}

public protocol NavItemDelegate:class {
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapEditNavItem index:Int)
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapShareNavItem index:Int)
    func imageViewer(_ imageViewer: ImageCarouselViewController, didTapMoreNavItem index:Int)
}
