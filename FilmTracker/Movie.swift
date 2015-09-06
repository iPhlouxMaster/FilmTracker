//
//  Movie.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Movie {
    
    enum Status {
        case watched
        case watching
        case wantToWatch
        case other
    }
    
    enum URLType {
        case posterW92
        case posterW300
        case movieDetails
        case movieCredits
    }
    
    enum ImageSize {
        case w92
        case w300
    }
    
    var title = ""
    var id = 0
    var releaseDate = ""
    var posterAddress = ""
    var directors = [String]()
    var genres = [String]()
    var productionCountries = [String]()
    var tmdbRating = 0.0 as Float
    var yourRating = 0.0 as Float
    var overview = ""
    var w92Poster: UIImage?
    var w300Poster: UIImage?
    var imdbID = ""
    var lastUpdateDate: NSDate?
    var watchStatus = Status.other
    var watchedDate: NSDate?
    var comments: String?
    
    func convertStringToDate(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if !dateString.isEmpty {
            return dateFormatter.dateFromString(dateString)
        } else {
            return nil
        }
    }
    
    func getURLWithType(type: URLType) -> NSURL {
        var url = ""
        switch type {
        case .posterW92:
            url = String(format: "http://image.tmdb.org/t/p/w92%@&api_key=%@", posterAddress, Constants.kFTAPIKey)
        case .posterW300:
            url = String(format: "http://image.tmdb.org/t/p/w300%@&api_key=%@", posterAddress, Constants.kFTAPIKey)
        case .movieDetails:
            url = String(format: "https://api.themoviedb.org/3/movie/%d?api_key=%@", id, Constants.kFTAPIKey)
        case .movieCredits:
            url = String(format: "https://api.themoviedb.org/3/movie/%d/credits?api_key=%@", id, Constants.kFTAPIKey)
        }
        return NSURL(string: url)!
    }
}
