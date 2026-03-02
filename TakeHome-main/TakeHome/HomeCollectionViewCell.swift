//
//  BirdCell 2.swift
//  TakeHome
//
//  Created by Sebastian Cain on 3/1/26.
//


import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0.6)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var imageLoadTask: Task<Void, Never>? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(titleLabel)
        
        contentView.addConstraints([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            activityIndicator.topAnchor.constraint(equalTo: imageView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBird(_ bird: LocalBird) {
        titleLabel.text = bird.latinName
        
        if let thumbnailUrl = URL(string: bird.thumbUrl) {
            activityIndicator.startAnimating()
            imageLoadTask = Task {
                do {
                    let image = try await ImageLoader.shared.load(url: thumbnailUrl)
                    
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.imageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                    
                } catch is CancellationError {
                    // skip image set
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        imageLoadTask?.cancel()
        imageView.image = nil
    }
}
