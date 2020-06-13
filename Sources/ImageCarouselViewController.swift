import UIKit

public protocol ImageDataSource:class {
    func numberOfImages() -> Int
    func imageItem(at index:Int) -> ImageItem
}

public class ImageCarouselViewController:UIPageViewController {
    
    weak var imageDatasource:ImageDataSource?
    var initialIndex = 0
    var sourceView:UIImageView!
    var theme:ImageViewerTheme = .light {
        didSet {
            navItem.leftBarButtonItem?.tintColor = theme.tintColor
            navItem.rightBarButtonItem?.tintColor = theme.tintColor
            backgroundView.backgroundColor = theme.color
        }
    }
    
    var options:[ImageViewerOption] = []
    
    weak var rightNavItemDelegate:RightNavItemDelegate?
    weak var actionNavItemDelegate:NavItemDelegate?
    
    private(set) lazy var navBar:UINavigationBar = {
        let _navBar = UINavigationBar(frame: .zero)
        _navBar.isTranslucent = true
        _navBar.setBackgroundImage(UIImage(), for: .default)
        _navBar.shadowImage = UIImage()
        _navBar.tintColor = theme.color
        return _navBar
    }()
    
    private(set) lazy var backgroundView:UIView = {
        let _v = UIView()
        _v.backgroundColor = theme.color
        _v.alpha = 0.0
        return _v
    }()
    
    private(set) lazy var navItem = UINavigationItem()
    
    public static func create(
        sourceView:UIImageView,
        imageDataSource: ImageDataSource?,
        options:[ImageViewerOption] = [],
        initialIndex:Int = 0) -> ImageCarouselViewController {
        
        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        
        let imageCarousel = ImageCarouselViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions)
        
        imageCarousel.modalPresentationStyle = .overFullScreen
        imageCarousel.modalPresentationCapturesStatusBarAppearance = true
        
        imageCarousel.sourceView = sourceView
        imageCarousel.imageDatasource = imageDataSource
        imageCarousel.options = options
        imageCarousel.initialIndex = initialIndex
       
        return imageCarousel
    }
    
    private func addNavBar() {
        // Add Navigation Bar
        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismiss(_:)))
        
        navItem.leftBarButtonItem = closeBarButton
        navItem.leftBarButtonItem?.tintColor = theme.tintColor
        navItem.rightBarButtonItems = []
        navBar.alpha = 0.0
        navBar.items = [navItem]
        navBar.insert(to: view)
    }
    
    private func addBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.bindFrameToSuperview()
        view.sendSubviewToBack(backgroundView)
    }
    
    private func applyOptions() {
        
        options.forEach {
            switch $0 {
            case .theme(let theme):
                self.theme = theme
            case .closeIcon(let icon):
                navItem.leftBarButtonItem?.image = icon
            case .actionNavItemTitle(let title, let closeIcon, let moreIcon, let delegate):
                navItem.leftBarButtonItem?.image = closeIcon
                navItem.rightBarButtonItems = [
                    UIBarButtonItem(
                        image: moreIcon,
                        style: .plain,
                        target: self,
                        action: #selector(didTapMoreNavBarItem(_:))
                    ),
                    UIBarButtonItem(
                        title: "Share",
                        style: .plain,
                        target: self,
                        action: #selector(didTapShareNavBarItem(_:))
                    ),
                    UIBarButtonItem(
                        title: "Edit",
                        style: .plain,
                        target: self,
                        action: #selector(didTapEditNavBarItem(_:))
                    )
                ]
                actionNavItemDelegate = delegate
            case .rightNavItemTitle(let title, let delegate):
                navItem.rightBarButtonItems!.append(UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(diTapRightNavBarItem(_:))))
                rightNavItemDelegate = delegate
            case .rightNavItemIcon(let icon, let delegate):
                navItem.rightBarButtonItems!.append(UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(diTapRightNavBarItem(_:))))
                rightNavItemDelegate = delegate
            default:
                break
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addBackgroundView()
        addNavBar()
        applyOptions()
        
        view.backgroundColor = .clear
        dataSource = self

        let initialVC = ImageViewerController(sourceView: sourceView)
        initialVC.index = initialIndex
        if let imageDatasource = imageDatasource {
            initialVC.imageItem = imageDatasource.imageItem(at: initialIndex)
        } else {
            // Use the image from source
            initialVC.imageItem = .image(sourceView.image)
        }
        initialVC.animateOnDidAppear = true
        initialVC.delegate = self
        setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.235) {
            self.navBar.alpha = 1.0
        }
    }
    
    @objc
    private func dismiss(_ sender:UIBarButtonItem) {
        dismissMe(completion: nil)
    }
    
    public func dismissMe(completion: (() -> Void)? = nil) {
        sourceView.alpha = 1.0
        UIView.animate(withDuration: 0.235, animations: {
            self.view.alpha = 0.0
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    @objc
    func diTapRightNavBarItem(_ sender:UIBarButtonItem) {
        guard let _delegate = rightNavItemDelegate,
            let _firstVC = viewControllers?.first as? ImageViewerController
            else { return }
        _delegate.imageViewer(self, didTapRightNavItem: _firstVC.index)
    }
    
    @objc
    func didTapEditNavBarItem(_ sender:UIBarButtonItem) {
        guard let _delegate = actionNavItemDelegate,
            let _firstVC = viewControllers?.first as? ImageViewerController
            else { return }
        _delegate.imageViewer(self, didTapEditNavItem: _firstVC.index)
    }
    
    @objc
    func didTapMoreNavBarItem(_ sender:UIBarButtonItem) {
        guard let _delegate = actionNavItemDelegate,
            let _firstVC = viewControllers?.first as? ImageViewerController
            else { return }
        _delegate.imageViewer(self, didTapMoreNavItem: _firstVC.index)
    }
    
    @objc
    func didTapShareNavBarItem(_ sender:UIBarButtonItem) {
        guard let _delegate = actionNavItemDelegate,
            let _firstVC = viewControllers?.first as? ImageViewerController
            else { return }
        _delegate.imageViewer(self, didTapShareNavItem: _firstVC.index)
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if theme == .dark {
            return .lightContent
        }
        return .default
    }
}

extension ImageCarouselViewController:UIPageViewControllerDataSource {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDatasource else { return nil }
        guard vc.index > 0 else { return nil }
 
        let newIndex = vc.index - 1
        let sourceView = newIndex == initialIndex ? self.sourceView : nil
        return ImageViewerController.create(
            index: newIndex,
            imageItem:  imageDatasource.imageItem(at: newIndex),
            sourceView: sourceView,
            delegate: self)
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDatasource else { return nil }
        guard vc.index <= (imageDatasource.numberOfImages() - 2) else { return nil }
        
        let newIndex = vc.index + 1
        let sourceView = newIndex == initialIndex ? self.sourceView : nil
        return ImageViewerController.create(
            index: newIndex,
            imageItem:  imageDatasource.imageItem(at: newIndex),
            sourceView: sourceView,
            delegate: self)
    }
}

extension ImageCarouselViewController:ImageViewerControllerDelegate {
    func imageViewerDidClose(_ imageViewer: ImageViewerController) {
        sourceView.alpha = 1.0
    }
}
