//
//  Service.swift
//  pokedexSample
//
//  Created by Javier Porras jr on 10/25/19.
//  Copyright © 2019 Javier Porras jr. All rights reserved.
//

import UIKit

class Service {
    //singleton.
    static let shared = Service() //creates a shared instance of this class, and static to create a single instance.
    
    let baseURL = "https://pokedex-bb36f.firebaseio.com/pokemon.json"
    
    
    func fetchPokemon(completion: @escaping ([Pokemon])->()){
        var pokemonArray = [Pokemon]()
        guard let url = URL(string: baseURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //handle error
            if let error = error{
                print("Failed to fetch data with error: ", error.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            do {
                guard let resultsArray = try JSONSerialization.jsonObject(with: data, options: [])  as? [AnyObject] else {return}
                //print(resultArray)
                for (key, result) in resultsArray.enumerated() {
                    if let dictionary = result as? [String: AnyObject]{
                        let pokemon = Pokemon(id: key, dictionary: dictionary)
                        guard let imageUrl = pokemon.imageUrl else { return }
                        self.fetchImage(withURLString: imageUrl, completion: { (image) in
                            pokemon.image = image
                            pokemonArray.append(pokemon) //print(pokemon.name) //print(pokemon.id)
                            pokemonArray.sort(by: { (p1, p2) -> Bool in
                                return p1.id! < p2.id!
                            })
                            completion(pokemonArray)
                        })
                    }
                }
                
            }catch let error{
                print("Failed to create json with error: ", error.localizedDescription)
            }
            
        }.resume()
    }//end of fetchPokem method.
    
    
    private func fetchImage(withURLString urlString: String, completion: @escaping (UIImage)->()){
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error{
                print("Failed to fetch image with error: ", error.localizedDescription)
                return
            }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else {return}
            completion(image)
        }.resume()
    }// end of fetchImage method
    
}
