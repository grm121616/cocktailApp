//
//  IngretsViewController.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 4/18/23.
//  Copyright © 2023 Ruoming Gao. All rights reserved.
//

import UIKit

class IngretsTableViewController: UITableViewController {
    
    var ingrests: [String] = ["1", "2", "3"]
    let arr = ["Light rum", "Lime", "Sugar", "Mint", "Soda water"]
    
    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        ingrests = viewModel.ingres ?? []
//        self.tableView.register(UINib(nibName: "IngretsTableViewCell", bundle: nil), forCellReuseIdentifier: "IngresCell")
//        self.register(UINib(nibName: "TableViewSearchResultsCell", bundle: nil), forCellReuseIdentifier: "resultCell")
    }
    
    func getIngres(ingres: [String]) {
        ingrests = ingres
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngresCell", for: indexPath) as! IngretsTableViewCell
        cell.IngretsLabel?.text = arr[indexPath.row]
        return cell
    }

}


