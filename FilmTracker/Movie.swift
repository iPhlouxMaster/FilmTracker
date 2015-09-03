//
//  Movie.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Movie {
    
    var title = ""
    var id = -1
    // var type = -1
    var releaseDate = ""
    var posterAddress = ""
    var directors = [String]()
    var genres = [String]()
    var tmdbRating = -0.0
    var overview = ""
    var w92Poster: UIImage?
    var w300Poster: UIImage?
    var imdbID = ""
    
    func convertStringToDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(dateString)!
    }
    
    func getURLWithType(type: Int) -> NSURL {
        var url = ""
        switch type {
        case 0:
            url = String(format: "http://image.tmdb.org/t/p/w92%@&api_key=%@", posterAddress, Constants.kFTAPIKey)
        case 1:
            url = String(format: "http://image.tmdb.org/t/p/w300%@&api_key=%@", posterAddress, Constants.kFTAPIKey)
        case 2:
            url = String(format: "https://api.themoviedb.org/3/movie/%d?api_key=%@", id, Constants.kFTAPIKey)
        case 3:
            url = String(format: "https://api.themoviedb.org/3/movie/%d/credits?api_key=%@", id, Constants.kFTAPIKey)
        default:
            break
        }
        return NSURL(string: url)!
    }

}
