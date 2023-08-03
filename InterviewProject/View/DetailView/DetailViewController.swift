//
//  detailViewController.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/7/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var isDeleted: Bool?
    
    var imageData: Data?
    
    @IBOutlet weak var verticalIngretsStack: UIStackView!
    
    @IBOutlet weak var favoriteButtonOutlet: UIButton!
    
    @IBOutlet weak var image: UIImageView?
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var typesLabel: UILabel!
    
    @IBAction func favoriteButton(_ sender: Any) {
        let coreDataObject = try! CoreDataManager.instance.fetchAll(entity: Image.self)
        var isFavorite = false
        for coreObj in coreDataObject {
            if nameLabelText == coreObj.name {
                isFavorite = true
                CoreDataManager.instance.delete(entity: coreObj)
                isDeleted = true
            }
        }
        if isFavorite == false {
            guard let object = try? CoreDataManager.instance.createObject(entity: Image.self)
                else { return }
            object.favorite = true
            if let nameLabelString = nameLabelText, let instr = instrText, let imageData = imageData {
                object.imageurl = imageData as NSData
                object.name = nameLabelString
                object.ingret = ingretsArray.joined(separator: " ,")
                object.measurements = measurementArray.joined(separator: " ,")
                object.instruction = instr
                isDeleted = false
            }
        }
        delegateFavorite?.addFavorite()
        try? CoreDataManager.instance.save()
        self.viewWillAppear(true)
    }

    var imageString: String?
    var delegateFavorite: SaveFavoriteProtocol?
    var nameLabelText: String?
    var instrText: String?
    var ingresText: String?
    var buttonText: String?
    var viewModel = ViewModel()
    let ingrestsStackViewH = UIStackView()
    var ingretsArray:[String] = []
    var measurementArray: [String] = []
    var switchUIArr: [UISwitch] = []
    var switchArrCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeLabel.text = nameLabelText ?? ""
        likeLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        typesLabel.text = instrText ?? ""
        favoriteButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28.0)
        for i in 0..<ingretsArray.count {
            let ingreLabel = UILabel()
            let measureLabel = UILabel()
            ingreLabel.text = ingretsArray[i]
            if measurementArray.count > i {
                measureLabel.text =  measurementArray[i]
            }
            let checkMark = UISwitch()
            checkMark.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
            switchUIArr.append(checkMark)
            switchArrCount += 1
            let hzStackView = UIStackView()
            let ingretsMeasureStack = UIStackView()
            ingretsMeasureStack.addArrangedSubview(ingreLabel)
            ingretsMeasureStack.addArrangedSubview(measureLabel)
            ingretsMeasureStack.alignment = .center
            ingretsMeasureStack.spacing = 16
            hzStackView.spacing = 20
            hzStackView.addArrangedSubview(ingretsMeasureStack)
            hzStackView.addArrangedSubview(checkMark)
            verticalIngretsStack.spacing = 8
            verticalIngretsStack.addArrangedSubview(hzStackView)
        }
        if let imageData = imageData {
            image?.image = UIImage(data: imageData)
        }
    }
    
    @objc func switchDidChange(_ sender: UISwitch) {
        if !sender.isOn {
            switchArrCount += 1
        } else if switchArrCount > 0, sender.isOn {
            switchArrCount -= 1
        }
        if switchArrCount == 0 {
            showCompletionAlert()
        }
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: "Congrats", message: "let's go~", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self) {
            for coreObj in favorite {
                if let nameText = nameLabelText, coreObj.name == nameText {
                    DispatchQueue.main.async {
                        self.favoriteButtonOutlet?.setImage(UIImage(named: "favorited"), for: .normal)
                    }
                }
            }
        }
        if let isDeleted = isDeleted, isDeleted {
            DispatchQueue.main.async {
                self.favoriteButtonOutlet?.setImage(UIImage(named: "favorite"), for: .normal)
            }
        }
    }
    
    func getButtonText(text: String) {
        buttonText = text
        favoriteButtonOutlet.setTitle(buttonText, for: .normal)
    }
    
    func getDrinkStr(number: String) {
        let textString = String(number)
        nameLabelText = textString
    }
    
    func getIngres(ingres: String) {
        let textString = ingres
        ingresText = textString
    }
    
    func getImage(uiimage: UIImage?) {
        guard let uiimage = uiimage else {
            return
        }
        imageData = uiimage.pngData()
        image?.image = uiimage
        viewWillAppear(true)
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(urlString: String? = nil, isFavorite: Bool = false, imageData: Data? = nil) {
        if let urlString = urlString, let imageFromCache = imageCache.object(forKey: urlString as NSString), isFavorite == false {
            DispatchQueue.main.async {
                self.getImage(uiimage: imageFromCache)
            }
        } else if let imageData = imageData, isFavorite{
            DispatchQueue.main.async {
                let savedImage = UIImage(data: imageData)
                self.getImage(uiimage: savedImage)
            }
        } else {
            guard let urlString = urlString, let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = data,
                    let image = UIImage(data: data) else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.getImage(uiimage: image)
                }
            }.resume()
        }
    }
}

protocol SaveFavoriteProtocol {
    func addFavorite()
}

