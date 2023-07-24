//
//  ViewSearchResultController.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 8/26/22.
//  Copyright © 2022 Ruoming Gao. All rights reserved.
//

import UIKit

class ViewSearchResultController: UIViewController {
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    let viewModel = ViewModel()
    
    var searchDrinks: [Drink] = []
    
    var selectedIndex = IndexPath(row: -1, section: 0)
    
    var ingredNames: [StrIngre] = [] {
        didSet {
            for ingred in ingredNames {
                if let ingredString = ingred.strIngredient1?.replacingOccurrences(of: " ", with: "%20") {
                    ingredURLs.append(ingredString)
                }
            }
        }
    }
    
    var filterIngred: [StrIngre] = []
    
    var filterIngredURLs: [String] = []
    
    var ingredURLs: [String] = []
    
    var isFromCustomView = false
    
    var favorite = try? CoreDataManager.instance.fetchAll(entity: Image.self)
    
    var addIngredsDelegate: AddIngredDelegate?
    
    var selectedIngreds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.register(UINib(nibName: "TableViewSearchResultsCell", bundle: nil), forCellReuseIdentifier: "resultCell")
        searchBar.delegate = self
        filterIngred = ingredNames
        filterIngredURLs = ingredURLs
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addIngredsDelegate?.addIngred(ingreds: selectedIngreds)
    }
}

extension ViewSearchResultController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromCustomView {
            return filterIngred.count
        }
        return searchDrinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? TableViewSearchResultsCell else { return UITableViewCell() }
        if isFromCustomView {
            cell.nameLabel.text = filterIngred[indexPath.row].strIngredient1
            cell.loadIngredsImage(ingredsString: filterIngredURLs[indexPath.row])
        } else {
            cell.nameLabel.text = searchDrinks[indexPath.row].strDrink
            cell.loadImage(urlString: searchDrinks[indexPath.row].strDrinkThumb)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromCustomView {
            if let selectedIngred = filterIngred[indexPath.row].strIngredient1 {
                selectedIngreds.append(selectedIngred)
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }            
            vc.getDrinkStr(number: searchDrinks[indexPath.row].strDrink)
            vc.instrText = searchDrinks[indexPath.row].strInstructions
            vc.getIngres(ingres: viewModel.getstrIngredient(drink: searchDrinks, indexPath: indexPath.row))
            vc.loadImage(urlString: searchDrinks[indexPath.row].strDrinkThumb)
            vc.imageString = searchDrinks[indexPath.row].strDrinkThumb
            vc.measurementArray = viewModel.getMeasurement(drink: searchDrinks, indexPath: indexPath.row)
            vc.ingretsArray = viewModel.getIngretsArray(drink: searchDrinks, indexPath: indexPath.row)
            vc.delegateFavorite = ViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewSearchResultController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension ViewSearchResultController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false {
            filterIngred = filterIngred.filter({ strinIngred in
                if let str1 = strinIngred.strIngredient1?.lowercased() {
                    let searchText = searchText.lowercased()
                    return str1.contains(searchText)
                } else {
                    return false
                }
            })
            filterIngredURLs = filterIngredURLs.filter({ urlString in
                let str1 = urlString.lowercased()
                return str1.contains(searchText.lowercased())
            })
        } else {
            filterIngred = ingredNames
            filterIngredURLs = ingredURLs
        }
        searchResultTableView.reloadData()
    }
}

protocol AddIngredDelegate {
    func addIngred(ingreds: [String])
}
