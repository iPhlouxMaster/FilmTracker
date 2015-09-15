//
//  Entity.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 7/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Film: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var id: NSNumber
    @NSManaged var watchStatus: NSNumber
    
    @NSManaged var releaseDate: NSDate?
    @NSManaged var posterAddress: String?
    @NSManaged var directors: AnyObject?
    @NSManaged var genres: AnyObject?
    @NSManaged var productionCountries: AnyObject?
    @NSManaged var tmdbRating: NSNumber?
    @NSManaged var yourRating: NSNumber?
    @NSManaged var overview: String?
    @NSManaged var w92Poster: NSData?
    @NSManaged var w300Poster: NSData?
    @NSManaged var imdbID: String?
    @NSManaged var lastUpdateDate: NSDate?
    @NSManaged var watchedDate: NSDate?
    @NSManaged var comments: String?
    
    // MARK: - Transient Properties
    
    var releaseDateSection: String {
        if releaseDate != nil {
            return String(NSCalendar.currentCalendar().component(.Year, fromDate: releaseDate!))
        } else {
            return "No release date"
        }
    }
    
    var yourRatingSection: String {
        if yourRating != nil {
            let rating = Float(yourRating!)
            switch rating {
            case 1.0..<2.0: return "From 10% - 20%"
            case 2.0..<3.0: return "From 20% - 30%"
            case 3.0..<4.0: return "From 30% - 40%"
            case 4.0..<5.0: return "From 40% - 50%"
            case 5.0..<6.0: return "From 50% - 60%"
            case 6.0..<7.0: return "From 60% - 70%"
            case 7.0..<8.0: return "From 70% - 80%"
            case 8.0..<9.0: return "From 80% - 90%"
            case 9.0...10.0: return "From 90% - 100%"
            default: return "The bug"
            }
        } else {
            return "Unrated"
        }
    }
    
    var titleSection: String {
        let characterSet = "ABCDEFGHIJKLMNOPQUSTUVWXYZ"
        let titleCharacter = (title as NSString).substringToIndex(1).uppercaseString
        
        if characterSet.rangeOfString(titleCharacter) != nil {
            return titleCharacter
        } else {
            return "Others"
        }
    }
    
    var watchStatusSection: String {
        switch watchStatus {
        case 0: return "Want to see"
        case 1: return "Watching"
        case 2: return "Watched"
        case 3: return "None"
        default: return "The bug"
        }
    }
    
    // Search Results are Movie objects, it's necessary to convert the Movie object to Film object for storing in Core Data
    
    func convertToMovieObject(movie: Movie) {
        
        movie.title = title
        movie.id = id as Int
        movie.watchStatus = Movie.Status(rawValue: Int(watchStatus))!
        movie.film = self

        if let posterAddress = posterAddress {
            movie.posterAddress = posterAddress
        }
        
        if let releaseDate = releaseDate {
            movie.releaseDate = releaseDate
        } else {
            movie.releaseDate = nil
        }
        
        if let directors = directors as? [String] {
            movie.directors = directors
        } else {
            movie.directors = nil
        }
        
        if let genres = genres as? [String] {
            movie.genres = genres
        } else {
            movie.genres = nil
        }
        
        if let productionCountries = productionCountries as? [String] {
            movie.productionCountries = productionCountries
        } else {
            movie.productionCountries = nil
        }
        
        if let tmdbRating = tmdbRating as? Float {
            movie.tmdbRating = tmdbRating
        }
        
        if let yourRating = yourRating as? Float {
            movie.yourRating = yourRating
        } else {
            movie.yourRating = nil
        }
        
        if let overview = overview {
            movie.overview = overview
        }
        
        if let w92Poster = w92Poster {
            movie.w92Poster = UIImage(data: w92Poster)
        } else {
            movie.w92Poster = nil
        }
        
        if let w300Poster = w300Poster {
            movie.w300Poster = UIImage(data: w300Poster)
        } else {
            movie.w300Poster = nil
        }
        
        if let imdbID = imdbID {
            movie.imdbID = imdbID
        }
        
        if let watchedDate = watchedDate {
            movie.watchedDate = watchedDate
        } else {
            movie.watchedDate = nil
        }

        if let comments = comments {
            movie.comments = comments
        } else {
            movie.comments = nil
        }
        
        if let lastUpdateDate = lastUpdateDate {
            movie.lastUpdateDate = lastUpdateDate
        } else {
            movie.lastUpdateDate = nil
        }
    }
}
