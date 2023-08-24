//
//  BangManager.swift
//  bangViewLibrary
//
//  Created by Aleksandr Sabri on 21/8/23.
//

import Foundation
import UIKit

/// Manages the display of "Bang" views on the application window.
public class BangsManager {
    
    private var viewModel: BangViewModel
    
    /// Initializes a new BangsManager with the specified properties.
    /// - Parameters:
    ///   - image: The image to be shown in the bang view. Default is `UIImage()`.
    ///   - text: The text to be displayed. Defaults to the app's bundle name.
    ///   - textColor: The color of the text. Default is `.white`.
    ///   - backgroundColor: The background color for the bang. Default is `.black`.
    ///   - font: The font for the text. If nil, a default font will be used.
    init(image: UIImage? = UIImage(),
         text: String? = nil,
         textColor: UIColor = .white,
         backgroundColor: UIColor = .black,
         font: UIFont? = nil) {
        
        let defaultText = text ?? (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "App")
        viewModel = BangViewModel(image: image, text: defaultText, textColor: textColor, backgroundColor: backgroundColor, font: font)
    }
    
    /// Adds a 'Bang' view to the current key window if conditions allow.
    func addBang() {
        guard let window = UIWindow.currentKeyWindow(), shouldShowBang(window: window) else { return }
        
        let bangView = BangViewFactory.createView(with: viewModel)
        bangView.addTo(window)
    }
    
    private func getWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    /// Determines if the 'Bang' view should be shown based on the window's safe area insets.
        /// - Parameter window: The window to be checked.
        /// - Returns: True if the view should be shown, false otherwise.
    internal func shouldShowBang(window: UIWindow) -> Bool {
        if #available(iOS 13.0, *), window.safeAreaInsets.bottom > 0 {
            return true
        }
        return false
    }
}

/// Represents a UI view for the 'Bang' visual element.
class BangView: UIView {
    
    let viewModel: BangViewModel
    private let imageView = UIImageView()
    private let label = UILabel()
    
    /// Initializes the view with a specific model.
    /// - Parameter viewModel: The model containing data to populate the view.
    init(viewModel: BangViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = viewModel.backgroundColor
        addSubview(label)
        addSubview(imageView)
        setupImageView()
        setupLabel()
        self.layer.cornerRadius = 11
        
        let calculatedWidth = viewModel.requiredWidth()
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: calculatedWidth)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        guard let image = viewModel.image else { return }
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    private func setupLabel() {
        label.text = viewModel.text
        label.font = viewModel.font ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = viewModel.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),
            label.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 4),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5)
        ])
    }
    
    /// Adds the 'Bang' view to a specified window.
    /// - Parameter window: The window where the view should be added.
    func addTo(_ window: UIWindow) {
        if #available(iOS 15.0, *) {
            if window.windowScene?.windows.contains(where: {
                $0.subviews.contains(where: {
                    $0 is BangView && ($0 as! BangView).viewModel == viewModel
                })
            }) == true {
                return
            }
        } else {
            if window.subviews.contains(where: {
                $0 is BangView && ($0 as! BangView).viewModel == viewModel
            }) {
                return
            }
        }
        
        window.addSubview(self)
        let constraints = [
            self.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            self.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: -viewModel.bottomInset),
            self.heightAnchor.constraint(equalToConstant: 22)   // Or whatever height you desire
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

/// Represents the model used to configure the `BangView`.
struct BangViewModel: Equatable {
    let image: UIImage?
    let text: String
    let textColor: UIColor
    let backgroundColor: UIColor
    let font: UIFont?
    let bottomInset: CGFloat = 17
}

/// Factory class for creating `BangView` instances.
class BangViewFactory {
    
    /// Creates a `BangView` with a specified model.
    /// - Parameter model: The model containing data for the view.
    /// - Returns: A configured `BangView`.
    static func createView(with model: BangViewModel) -> BangView {
        return BangView(viewModel: model)
    }
}

extension BangViewModel {
    
    /// Calculates the required width for the `BangView` based on its content.
    /// - Returns: The width required to display the `BangView` content.
    func requiredWidth() -> CGFloat {
        // Calculate width for the text
        let currentFont = font ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        let textAttributes = [NSAttributedString.Key.font: currentFont]
        let textSize = text.size(withAttributes: textAttributes)
        
        // Calculate width for the image
        let imageWidth = CGFloat(14)
        
        // Add some padding/margins
        let totalWidth = textSize.width + imageWidth + 20 // add extra padding if required
        
        return totalWidth
    }
}

extension UIWindow {
    
    /// Retrieves the current key window.
    /// - Returns: The current key window, if available.
    static func currentKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
