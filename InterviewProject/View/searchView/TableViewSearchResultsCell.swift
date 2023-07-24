//
//  TableViewSearchResultsCell.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 8/26/22.
//  Copyright © 2022 Ruoming Gao. All rights reserved.
//

import UIKit

class TableViewSearchResultsCell: UITableViewCell {

    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getImage(uiimage: UIImage){
        drinkImage.image = uiimage
    }
    
    func loadIngredsImage(ingredsString: String) {
        let urlString = "https://www.thecocktaildb.com/images/ingredients/\(ingredsString)-Small.png"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                self.getImage(uiimage: image)
            }
        }.resume()
    }
    
    func loadImage(urlString: String? = nil, isFavorite: Bool = false, imageData: Data? = nil) {
        if urlString == nil && imageData == nil {
            drinkImage.image = UIImage(named: "selectImage")
        } else if let urlString = urlString, let imageFromCache = imageCache.object(forKey: urlString as NSString), isFavorite == false {
            DispatchQueue.main.async {
                self.getImage(uiimage: imageFromCache)
            }
        } else if let imageData = imageData, isFavorite, let uiImage = UIImage(data: imageData){
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
