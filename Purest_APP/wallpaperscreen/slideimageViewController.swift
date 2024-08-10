import UIKit
import SnapKit

class ImageSlideViewController: UIViewController, UIScrollViewDelegate {

    let verticalScrollView = UIScrollView() // New vertical scroll view
    let contentView = UIView() // Container view for vertical content
    let scrollView = UIScrollView() // Horizontal scroll view for images
    let pageControl = UIPageControl()
    var timer: Timer?
    let images = ["wal", "12", "a"] // Replace with your image names
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        title = "ZANDO"
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "backpack.circle"), style: .done, target: self, action: #selector(menuButtonTapped))
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .done, target: self, action: #selector(menuButtonTapped))
        } else {
            // Fallback on earlier versions
        }
        
        // Set up the vertical scroll view
        view.addSubview(verticalScrollView)
        verticalScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide) // Fill the entire view
        }
        
        // Set up the content view inside the vertical scroll view
        verticalScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(verticalScrollView) // Make content view the same width as the vertical scroll view
        }
        
        // Set up the horizontal scroll view
        contentView.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150) // Adjust height as needed
        }
        
        // Set up the page control
        contentView.addSubview(pageControl)
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(5) // Margin below the scroll view
            make.centerX.equalTo(contentView) // Center horizontally in the content view
            make.bottom.equalTo(contentView.snp.bottom).offset(-10) // Margin from the bottom of the content view
        }
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
        // Set up the images in the scroll view
        var previousImageView: UIImageView? = nil
        for (index, imageName) in images.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill // Ensure images fit within the imageView
            imageView.clipsToBounds = true // Clip any excess parts of the image
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(scrollView.snp.width)
                make.height.equalTo(scrollView.snp.height) // Ensure height matches the scroll view's height
                if let previous = previousImageView {
                    make.left.equalTo(previous.snp.right)
                } else {
                    make.left.equalToSuperview()
                }
                // Ensure the last imageView has the correct right constraint
                if index == images.count - 1 {
                    make.right.equalToSuperview()
                }
            }
            previousImageView = imageView
        }
        
        // Ensure the content size of the scroll view is set correctly
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(images.count), height: scrollView.frame.height)
        
        // Ensure the content size of the vertical scroll view is set correctly
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.bottom) // Content view height should be adjusted based on page control's position
        }
        
        // Start the timer for automatic sliding
        startTimer()
    }

    @objc func menuButtonTapped() {
        // Implement your menu button action here
    }
    
    @objc func pageControlTapped(sender: UIPageControl) {
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(autoSlideImages), userInfo: nil, repeats: true)
    }
    
    @objc func autoSlideImages() {
        let currentPage = pageControl.currentPage
        let nextPage = (currentPage + 1) % images.count
        let x = CGFloat(nextPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        pageControl.currentPage = nextPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width
        if !pageIndex.isNaN && pageIndex.isFinite {
            pageControl.currentPage = Int(pageIndex)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
}
