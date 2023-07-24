//
//  ViewModel.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 4/19/23.
//  Copyright © 2023 Ruoming Gao. All rights reserved.
//

import Foundation

class ViewModel {
    
    var ingres: [String]?
    
    var name: String?
    
    var instruction: String?
    
    let category = ["Saved Drinks", "Highest Rated", "Latest Drinks", "Popular Drinks"]
    
    func getMeasurement(drink: [Drink], indexPath: Int) -> [String] {
        let drinkMeasure = [drink[indexPath].strMeasure1, drink[indexPath].strMeasure2, drink[indexPath].strMeasure3, drink[indexPath].strMeasure4, drink[indexPath].strMeasure5, drink[indexPath].strMeasure6, drink[indexPath].strMeasure7]
        var drinkMeasureArr = [String]()
        for measure in drinkMeasure {
            if let drinkMeasure = measure {
                drinkMeasureArr.append(drinkMeasure)
            }
        }
        return drinkMeasureArr
    }

    func getIngretsArray(drink: [Drink], indexPath: Int) -> [String] {
        let drinkIngres = [drink[indexPath].strIngredient1, drink[indexPath].strIngredient2, drink[indexPath].strIngredient3, drink[indexPath].strIngredient4, drink[indexPath].strIngredient5, drink[indexPath].strIngredient6, drink[indexPath].strIngredient7]
        var drinkArr = [String]()
        for drink in drinkIngres {
            if let drinkIngre = drink, drinkIngre != "" {
                drinkArr.append(drinkIngre)
            }
        }
        return drinkArr
    }
    
    func getstrIngredient(drink: [Drink], indexPath: Int) -> String {
        let drinkIngres = [drink[indexPath].strIngredient1, drink[indexPath].strIngredient2, drink[indexPath].strIngredient3, drink[indexPath].strIngredient4, drink[indexPath].strIngredient5, drink[indexPath].strIngredient6, drink[indexPath].strIngredient7]
        var drinkIngres1: [String] = []
        for ingres in drinkIngres {
            if let drinkIngre = ingres {
                drinkIngres1.append(drinkIngre)
            }
        }
        return drinkIngres1.joined(separator: " ,")
    }
    
}
