//
//  ViewController.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/6/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var popular: [Drink] = []
    
    var randomDrinks: [Drink] = []
    
    var latestDrinks: [Drink] = []
    
    var searchDrinks: [Drink] = []
    
    var favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
    
    let netWorkController = NetworkController()
    
    let viewModel = ViewModel()
    
    var selectedIndex = IndexPath(row: -1, section: 0)
    
    var isFavoriteEnable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        title = "CocktailGenius"
        self.tableView.keyboardDismissMode = .onDrag
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        if let favorite = favorite, !favorite.isEmpty {
            isFavoriteEnable = true
        }
        netWorkController.callPopularDrinks { (data, _) in
            guard let data = data else { return }
            let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
            DispatchQueue.main.async {
                self.popular = jsonObject?.drinks ?? []
                self.tableView.reloadData()
            }
        }
        netWorkController.callRandomDrinks { (data, _) in
            guard let data = data else { return }
            let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
            DispatchQueue.main.async {
                self.randomDrinks = jsonObject?.drinks ?? []
                self.tableView.reloadData()
            }
        }
        netWorkController.callLatestDrinks { (data, _) in
            guard let data = data else { return }
            let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
            DispatchQueue.main.async {
                self.latestDrinks = jsonObject?.drinks ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "customVC") as? CustomDetailViewController else { return }
        vc.delegateFavorite = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let favorite = favorite, !favorite.isEmpty {
            isFavoriteEnable = true
        }
        favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let favorite = favorite, favorite.isEmpty {
            if indexPath.row == 0 {
                return  0
            }
        }
        return 250
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.category.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.categoryLabel.text = viewModel.category[indexPath.row]
        cell.collectionView.tag = indexPath.row
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "searchResultDC") as? ViewSearchResultController else { return }
        vc.isHideSearBar = true
        if indexPath.row == 0 {
            guard let favVC = storyboard?.instantiateViewController(withIdentifier: "FavoritesVC") as? FavoritesTableViewController else { return }
            self.navigationController?.pushViewController(favVC, animated: true)
        } else if indexPath.row == 1 {
            netWorkController.callRandomDrinks( completion: {(data, _) in
                guard let data = data else { return }
                let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.searchDrinks = jsonObject?.drinks ?? []
                    vc.searchDrinks = self.searchDrinks
                    vc.searchResultTableView.reloadData()
                })
            })
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            netWorkController.callLatestDrinks( completion: {(data, _) in
                guard let data = data else { return }
                let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.searchDrinks = jsonObject?.drinks ?? []
                    vc.searchDrinks = self.searchDrinks
                    vc.searchResultTableView.reloadData()
                })
            })
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 3 {
            netWorkController.callPopularDrinks( completion: {(data, _) in
                guard let data = data else { return }
                let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.searchDrinks = jsonObject?.drinks ?? []
                    vc.searchDrinks = self.searchDrinks
                    vc.searchResultTableView.reloadData()
                })
            })
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 3 {
            return popular.count
        } else if collectionView.tag == 1 {
            return randomDrinks.count
        } else if collectionView.tag == 2 {
            return latestDrinks.count
        } else if collectionView.tag == 0 {
            return favorite?.count ?? 0
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        if collectionView.tag == 3 {
            let imageURLIndex = popular[indexPath.row].strDrinkThumb
            cell.getNameLabelText(text: popular[indexPath.row].strDrink)
            cell.loadImage(urlString: imageURLIndex)
        } else if collectionView.tag == 1 {
            let imageURLIndex = randomDrinks[indexPath.row].strDrinkThumb
            cell.loadImage(urlString: imageURLIndex)
            cell.getNameLabelText(text: randomDrinks[indexPath.row].strDrink)
        } else if collectionView.tag == 2 {
            let imageURLIndex = latestDrinks[indexPath.row].strDrinkThumb
            cell.loadImage(urlString: imageURLIndex)
            cell.getNameLabelText(text: latestDrinks[indexPath.row].strDrink)
        } else if collectionView.tag == 0 {
            let imageURLIndex = favorite?[indexPath.row].imageurl as? Data
            cell.getNameLabelText(text: favorite?[indexPath.row].name ?? "")
            cell.loadImage(imageData: imageURLIndex, isFavorite: true)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let customVc = storyboard.instantiateViewController(withIdentifier: "customVC") as? CustomDetailViewController else { return }
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
        if collectionView.tag == 3 {
            vc.getDrinkStr(number: popular[indexPath.row].strDrink)
            vc.instrText = popular[indexPath.row].strInstructions
            vc.getIngres(ingres: viewModel.getstrIngredient(drink: popular, indexPath: indexPath.row))
            vc.ingretsArray = viewModel.getIngretsArray(drink: popular, indexPath: indexPath.row)
            vc.measurementArray = viewModel.getMeasurement(drink: popular, indexPath: indexPath.row)
            vc.loadImage(urlString: popular[indexPath.row].strDrinkThumb)
            vc.imageString = popular[indexPath.row].strDrinkThumb
            vc.delegateFavorite = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else if collectionView.tag == 1 {
            vc.getDrinkStr(number: randomDrinks[indexPath.row].strDrink)
            vc.instrText = randomDrinks[indexPath.row].strInstructions
            vc.getIngres(ingres: viewModel.getstrIngredient(drink: randomDrinks, indexPath: indexPath.row))
            vc.ingretsArray = viewModel.getIngretsArray(drink: randomDrinks, indexPath: indexPath.row)
            vc.measurementArray = viewModel.getMeasurement(drink: randomDrinks, indexPath: indexPath.row)
            vc.loadImage(urlString: randomDrinks[indexPath.row].strDrinkThumb)
            vc.imageString = randomDrinks[indexPath.row].strDrinkThumb
            vc.delegateFavorite = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView.tag == 2 {
            vc.getDrinkStr(number: latestDrinks[indexPath.row].strDrink)
            vc.instrText = latestDrinks[indexPath.row].strInstructions
            vc.getIngres(ingres: viewModel.getstrIngredient(drink: latestDrinks, indexPath: indexPath.row))
            vc.ingretsArray = viewModel.getIngretsArray(drink: latestDrinks, indexPath: indexPath.row)
            vc.measurementArray = viewModel.getMeasurement(drink: latestDrinks, indexPath: indexPath.row)
            vc.loadImage(urlString: latestDrinks[indexPath.row].strDrinkThumb)
            vc.imageString = latestDrinks[indexPath.row].strDrinkThumb
            vc.delegateFavorite = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let favorite = favorite, collectionView.tag == 0, !favorite[indexPath.row].isCustom {
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
            vc.delegateFavorite = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let favorite = favorite, collectionView.tag == 0 {
            var ingresArr = [String]()
            if let ingres = favorite[indexPath.row].ingret {
                ingresArr = ingres.components(separatedBy: " ,")
            }
            customVc.selectedIngreds = ingresArr
            customVc.setNameText(name: favorite[indexPath.row].name ?? "")
            customVc.setInstructionText(instr: favorite[indexPath.row].instruction ?? "")
            customVc.savedImage = favorite[indexPath.row].imageurl as? Data
            customVc.isInstruTextBlack = true
            customVc.delegateFavorite = self
            self.navigationController?.pushViewController(customVc, animated: true)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "searchResultDC") as? ViewSearchResultController else { return }
        guard let searchText = searchBar.text else { return }
        var newSearchText = ""
        for char in searchText {
            if char == " " {
                newSearchText += "%20"
            } else {
                newSearchText += String(char)
            }
        }
        netWorkController.callSearchDrinks(drink: newSearchText, completion: {(data, _) in
            guard let data = data else { return }
            let jsonObject = try? JSONDecoder().decode(CockTailModel.self, from: data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.searchDrinks = jsonObject?.drinks ?? []
                vc.searchDrinks = self.searchDrinks
                vc.searchResultTableView.reloadData()
            })
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: SaveFavoriteProtocol {
    func addFavorite() {
        favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
}


