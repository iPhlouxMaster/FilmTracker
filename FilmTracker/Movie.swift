//
//  Movie.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Movie {
    
    enum Status: Int {
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
    var watchStatus = Status.other
    
    var releaseDate: NSDate?
    var posterAddress: String?
    var directors: [String]?
    var genres: [String]?
    var productionCountries: [String]?
    var tmdbRating: Float?
    var yourRating: Float?
    var overview: String?
    var w92Poster: UIImage?
    var w300Poster: UIImage?
    var imdbID: String?
    var lastUpdateDate: NSDate?
    var watchedDate: NSDate?
    var comments: String?
    
    var film: Film?
    
    func convertStringToDate(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if !dateString.isEmpty {
            return dateFormatter.dateFromString(dateString)
        } else {
            return nil
        }
    }
    
    func convertDateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(date)
    }
    
    func getURLWithType(type: URLType) -> NSURL {
        var url = ""
        switch type {
        case .posterW92:
            url = String(format: "http://image.tmdb.org/t/p/w92%@&api_key=%@", posterAddress!, Constants.kFTAPIKey)
        case .posterW300:
            url = String(format: "http://image.tmdb.org/t/p/w300%@&api_key=%@", posterAddress!, Constants.kFTAPIKey)
        case .movieDetails:
            url = String(format: "https://api.themoviedb.org/3/movie/%d?api_key=%@", id, Constants.kFTAPIKey)
        case .movieCredits:
            url = String(format: "https://api.themoviedb.org/3/movie/%d/credits?api_key=%@", id, Constants.kFTAPIKey)
        }
        return NSURL(string: url)!
    }
    
    func convertToFilmObject(film: Film) {
        film.title = title
        film.id = id
        film.watchStatus = watchStatus.rawValue
        
        if let releaseDate = releaseDate {
            film.releaseDate = releaseDate
        }
        
        if let posterAddress = posterAddress {
            film.posterAddress = posterAddress
        }
        
        if let directors = directors {
            film.directors = directors
        }
        
        if let genres = genres {
            film.genres = genres
        }
        
        if let countries = productionCountries {
            film.productionCountries = countries
        }
        
        if let tmdbRating = tmdbRating {
            film.tmdbRating = tmdbRating
        }
        
        if let yourRating = yourRating {
            film.yourRating = yourRating
        }
        
        if let overview = overview {
            film.overview = overview
        }
        
        if let w92Poster = w92Poster {
            film.w92Poster = UIImageJPEGRepresentation(w92Poster, 1.0)
        }
        
        if let w300Poster = w300Poster {
            film.w300Poster = UIImageJPEGRepresentation(w300Poster, 1.0)
        }
        
        if let imdbID = imdbID {
            film.imdbID = imdbID
        }
        
        if let lastUpdateDate = lastUpdateDate {
            film.lastUpdateDate = lastUpdateDate
        }
        
        if let watchedDate = watchedDate {
            film.watchedDate = watchedDate
        }
        
        if let comments = comments {
            film.comments = comments
        }
    }
}
