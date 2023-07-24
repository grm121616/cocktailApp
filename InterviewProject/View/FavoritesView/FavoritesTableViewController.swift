//
//  FavoritesTableViewController.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 7/5/23.
//  Copyright © 2023 Ruoming Gao. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UIViewController {
    
    var delegateFavorite: SaveFavoriteProtocol?
    var favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
    var isFavoriteEnable: Bool?
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.register(UINib(nibName: "TableViewSearchResultsCell", bundle: nil), forCellReuseIdentifier: "resultCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let favorite = favorite, !favorite.isEmpty {
            isFavoriteEnable = true
        }
        favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
        DispatchQueue.main.async {
            self.favoritesTableView.reloadData()
        }
    }
}

extension FavoritesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var favorite = favorite else { return }
            CoreDataManager.instance.delete(entity: favorite[indexPath.row])
            favorite = try! CoreDataManager.instance.fetchAll(entity: Image.self)
            self.favoritesTableView.reloadData()
        }
    }
}

extension FavoritesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorite = try! CoreDataManager.instance.fetchAll(entity: Image.self)
        return favorite?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? TableViewSearchResultsCell else { return UITableViewCell() }
        let imageURLIndex = favorite?[indexPath.row].imageurl
        cell.nameLabel.text = favorite?[indexPath.row].name ?? ""
        cell.loadImage(isFavorite: true, imageData: imageURLIndex as? Data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
        guard let customVc = storyboard.instantiateViewController(withIdentifier: "customVC") as? CustomDetailViewController else { return }
        if let favorite = favorite, favorite[indexPath.row].isCustom {
            var ingresArr = [String]()
            if let ingres = favorite[indexPath.row].ingret {
                ingresArr = ingres.components(separatedBy: " ,")
            }
            customVc.selectedIngreds = ingresArr
            customVc.setNameText(name: favorite[indexPath.row].name ?? "")
            customVc.setInstructionText(instr: favorite[indexPath.row].instruction ?? "")
            customVc.savedImage = favorite[indexPath.row].imageurl as? Data
            customVc.isInstruTextBlack = true
            customVc.delegateFavorite = ViewController()
            self.navigationController?.pushViewController(customVc, animated: true)
        } else {
            guard let favorite = favorite else { return }
            vc.getDrinkStr(number: favorite[indexPath.row].name ?? "")
            vc.instrText = favorite[indexPath.row].instruction ?? ""
            var ingresArr = [String]()
            if let ingres = favorite[indexPath.row].ingret {
                ingresArr = ingres.components(separatedBy: " ,")
            }
            var measurementArr = [String]()
            if let measurements = favorite[indexPath.row].measurements {
                measurementArr = measurements.components(separatedBy: " ,")
             }
            vc.ingretsArray = ingresArr
            vc.measurementArray = measurementArr
            vc.getIngres(ingres: favorite[indexPath.row].ingret ?? "")
            vc.imageData = favorite[indexPath.row].imageurl as? Data
            vc.loadImage(isFavorite: true, imageData: favorite[indexPath.row].imageurl as? Data)
            vc.delegateFavorite = ViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
