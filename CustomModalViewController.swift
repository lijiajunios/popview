//
//  CustomModalViewController.swift
//  ChatBot
//
//  Created by mc on 2024/9/5.
//

import UIKit

class CustomModalViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [spacer])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)

        view.clipsToBounds = true
        return view
    }()
    
    var maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    var defaultHeight: CGFloat = 300
    var isNavation: Bool = false
    var duration: Double = 0.3
    var showDuration: Double = 0.4
    let dismissibleHeight: CGFloat = 200
    var maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentContainerHeight: CGFloat = 300
    var panGesture :UIPanGestureRecognizer =  UIPanGestureRecognizer()
    var tapGesture :UITapGestureRecognizer =  UITapGestureRecognizer()
    // constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        if showDuration == 0 {
            self.containerViewBottomConstraint?.constant = 0
            
            self.view.layoutIfNeeded()

        }

        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(self.tapGesture)
        
//        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
//        containerView.addGestureRecognizer(self.tapGesture)
        
        
        setupPanGesture()
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
//        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
   
        NSLayoutConstraint.activate([
            
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -0),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -0),
        ])
        
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
      
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func setupPanGesture() {
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        self.panGesture.delaysTouchesBegan = false
        
        self.panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(self.panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        print("Pan gesture y offset: \(translation.y)")
        
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
           
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    func animateBottomContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewBottomConstraint?.constant = -height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
//        currentContainerHeight = height
    }
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: showDuration) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
//        UIView.animate(withDuration: showDuration) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
//        }
    }
    
    func animateShowDimmedView() {
//        dimmedView.alpha = 0
        UIView.animate(withDuration: showDuration) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: duration) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            if self.isNavation {
                    self.containerViewBottomConstraint?.constant = self.defaultHeight
                    self.view.layoutIfNeeded()
                
                self.dismiss(animated: false)
            }else{
                self.containerViewBottomConstraint?.constant = self.defaultHeight
                self.view.layoutIfNeeded()

                self.dismiss(animated: false)

            }
        }
       
    }
}
