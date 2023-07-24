//
//  CollectionViewCell.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/6/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.cornerRadius = image.bounds.size.width / 2.0
        image.clipsToBounds = true
    }
    
    func getNameLabelText(text: String) {
        nameLabel.text = text
    }
    
    func getImage(uiimage: UIImage){
        image.image = uiimage
    }
    
    func loadImage(urlString: String? = nil, imageData: Data? = nil, isFavorite: Bool = false) {
        if urlString == nil && imageData == nil {
            image.image = UIImage(named: "selectImage")
        } else if let urlString = urlString, let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                self.getImage(uiimage: imageFromCache)
            }
        } else if let imageData = imageData, let uiImage = UIImage(data: imageData), isFavorite {
            DispatchQueue.main.async {
                self.getImage(uiimage: uiImage)
            }
        } else {
            guard let urlString = urlString, let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data,
                let image = UIImage(data: data) else { return }
                self.imageCache.setObject(image, forKey: urlString as NSString)
                DispatchQueue.main.async {
                    self.getImage(uiimage: image)
                }
            }.resume()
        }
    }
}

