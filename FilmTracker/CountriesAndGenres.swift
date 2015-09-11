//
//  CountriesAndGenres.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 6/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import Foundation

class CountriesAndGenres {
    
    // The class is for the genreList and countryList in PickerViewController, the content will update automatically.
    
    let genres = ["Adventure", "Foreign", "Romance", "Documentary", "Comedy", "Horror", "Action", "TV Movie", "Science Fiction", "Animation", "Thriller", "Fantasy", "Drama", "Family"]
    let countries = ["US", "GB", "NZ"]
    
    init() {
        registerDefaults()
        handleFirstRunning()
    }

    func registerDefaults() {
        let dictionary = ["FirstRunning": true]
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
    
    func handleFirstRunning() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let firstRunning = userDefaults.boolForKey("FirstRunning")
        if firstRunning {
            userDefaults.setObject(genres, forKey: "GenreList")
            userDefaults.setObject(countries, forKey: "CountryList")
            userDefaults.setBool(false, forKey: "FirstRunning")
            userDefaults.synchronize()
        }
    }
    
}