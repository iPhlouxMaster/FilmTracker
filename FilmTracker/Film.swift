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
