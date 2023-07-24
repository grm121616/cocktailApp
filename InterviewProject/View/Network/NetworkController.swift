//
//  NetworkController.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/6/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import Foundation
import UIKit
class NetworkController {
    
    let urlPopular = "https://www.thecocktaildb.com/api/json/v2/9973533/popular.php"
    
    let urlRandomDrinks = "https://www.thecocktaildb.com/api/json/v2/9973533/randomselection.php"
    
    let urlLatest = "https://www.thecocktaildb.com/api/json/v2/9973533/latest.php"
    
    let searchUrl = "https:www.thecocktaildb.com/api/json/v1/1/search.php?s="
    
    private func callAPI(url: String, completion: @escaping(Data?, Error?) -> Void) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            completion(data, error)
        }.resume()
    }
    
    func loadJson(fileName: String) ->[StrIngre]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
               do {
                   let data = try Data(contentsOf: url)
                   let decoder = JSONDecoder()
                   let jsonData = try decoder.decode(IngredsModel.self, from: data).drinks
                   return jsonData
               } catch {
                   print("error:\(error)")
               }
           }
        return nil
    }
    
    
    func callPopularDrinks(completion: @escaping(Data?, Error?) -> Void)  {
        callAPI(url: urlPopular, completion: completion)
    }

    func callRandomDrinks(completion: @escaping(Data?, Error?) -> Void)  {
        callAPI(url: urlRandomDrinks, completion: completion)
    }
    
    func callLatestDrinks(completion: @escaping(Data?, Error?) -> Void)  {
        callAPI(url: urlLatest, completion: completion)
    }
    
    func callSearchDrinks(drink: String, completion: @escaping(Data?, Error?) -> Void)  {
        let urlString = searchUrl + drink
        callAPI(url: urlString, completion: completion)
    }
}
