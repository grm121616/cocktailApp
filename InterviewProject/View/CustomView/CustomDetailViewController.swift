//
//  CustomDetailViewController.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 7/6/23.
//  Copyright © 2023 Ruoming Gao. All rights reserved.
//

import UIKit

class CustomDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var instruTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ingredStackView: UIStackView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var AddingIngredButton: UIButton!
    
    var nameText: String?
    
    var ingretsArray: [String] = []
    
    var measurementArray: [String] = []
    
    var isInstruTextBlack: Bool?
    
    var instruText: String?
    
    var delegateFavorite: SaveFavoriteProtocol?
    
    var delegateAddIngred: AddIngredDelegate?
    
    var savedImage: Data?
    
    var isDeleted: Bool?
    
    var currentNameText: String?
    
    var switchArrCount = 0
    
    var switchUIArr: [UISwitch] = []
    
    let netWorkController = NetworkController()
    
    var ingred: [StrIngre] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        title = "Create your own"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        instruTextView.delegate = self
        nameTextField.delegate = self
        if let isBlackText = isInstruTextBlack, isBlackText {
            instruTextView.textColor = .black
        } else {
            instruTextView.textColor = UIColor.lightGray
        }
        instruTextView.layer.borderColor = UIColor.gray.cgColor
        instruTextView.layer.borderWidth = 0.5
        instruTextView.layer.cornerRadius = 5
        if let savedImage = savedImage {
            imageView.image = UIImage(data: savedImage)
        }
        if let nameText = nameText, let instruText = instruText {
            nameTextField.text = nameText
            instruTextView.text = instruText
            currentNameText = nameTextField.text
        }
        ingred = netWorkController.loadJson(fileName: "Ingred") ?? []
        AddingIngredButton.addTarget(self, action: #selector(ingredButtonTapped), for: .touchUpInside)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: nil, action: nil)
        let toolbar = UIToolbar()
                
        let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                                target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
                toolbar.sizeToFit()
        
        nameTextField.inputAccessoryView = toolbar
        instruTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
           view.endEditing(true)
    }
    
    @objc func ingredButtonTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "searchResultDC") as? ViewSearchResultController else { return }
        vc.isFromCustomView = true
        vc.ingredNames = ingred
        vc.addIngredsDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func backAction(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Do you want to save?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (result : UIAlertAction) -> Void in
            self.saveToCoreData()
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "No", style: .default) { result in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: "Congrats", message: "let's go~", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveToCoreData() {
        let coreDataObject = try! CoreDataManager.instance.fetchAll(entity: Image.self)
        var isSaved = false
        for coreObj in coreDataObject {
            if currentNameText == coreObj.name {
                isSaved = true
                coreObj.imageurl = savedImage as? NSData
                coreObj.name = nameText
                coreObj.isCustom = true
                coreObj.ingret = selectedIngreds.joined(separator: " ,")
                coreObj.instruction = instruText
                isDeleted = false
            }
        }
        if isSaved == false {
            guard let object = try? CoreDataManager.instance.createObject(entity: Image.self)
            else { return }
            if nameText == "" || nameText == nil {
                nameText = "Unknown"
            }
            object.favorite = true
            object.imageurl = savedImage as? NSData
            object.name = nameText
            object.isCustom = true
            object.ingret = selectedIngreds.joined(separator: " ,")
            object.instruction = instruText
            isDeleted = false
        }
        delegateFavorite?.addFavorite()
        try? CoreDataManager.instance.save()
    }
    
    var selectedIngreds: [String] = []
    
    var isDuplicatedIngreds: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for i in 0..<selectedIngreds.count {
            if !ingretsArray.contains(selectedIngreds[i]), !selectedIngreds[i].isEmpty{
                let ingreLabel = UILabel()
                let measureLabel = UILabel()
                ingreLabel.text = selectedIngreds[i]
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
                ingredStackView.spacing = 8
                ingredStackView.addArrangedSubview(hzStackView)
            }
        }
        ingretsArray = selectedIngreds
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let vc = UIImagePickerController()
        vc.delegate = self
        let actionSheet = UIAlertController(title: "Photo", message: "Choose photo", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                vc.sourceType = .camera
                self.present(vc, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "Camera is not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            vc.allowsEditing = true
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view
        if UIDevice.current.userInterfaceIdiom == .pad {
            let xOrigin = self.view.bounds.width / 2 // Replace this with one of the lines at the end
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
        }
        self.present(actionSheet, animated: true)
    }
    
    func setNameText(name: String) {
        nameText = name
    }
    
    func setInstructionText(instr: String) {
        instruText = instr
    }

}

extension CustomDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (
            info[UIImagePickerController.InfoKey.editedImage] as? UIImage ??
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        )
        imageView.image = image
        savedImage = image?.pngData()
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension CustomDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
        }
        instruText = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        instruText = textView.text
    }
}

extension CustomDetailViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        nameText = textField.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameText = textField.text
    }
}

extension CustomDetailViewController: AddIngredDelegate {
    func addIngred(ingreds: [String]) {
        self.selectedIngreds = ingreds
        self.viewWillAppear(true)
    }
}
