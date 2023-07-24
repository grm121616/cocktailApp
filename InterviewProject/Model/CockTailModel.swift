//
//  Struct.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/6/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import Foundation

struct CockTailModel: Decodable {
    let drinks: [Drink]
}

struct Drink: Decodable {
    let strDrink: String
    var strDrinkThumb: String
    let strInstructions: String
    let strIngredient1: String
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
}


struct IngredsModel: Decodable {
    let drinks: [StrIngre]
}

struct StrIngre: Decodable {
    let strIngredient1: String?
}
