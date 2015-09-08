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
    
    func convertToMovieObject(movie: Movie) {
        
        movie.title = title
        movie.id = id as Int
        movie.watchStatus = Movie.Status(rawValue: Int(watchStatus))!

        if let posterAddress = posterAddress {
            movie.posterAddress = posterAddress
        }
        
        if let releaseDate = releaseDate {
            movie.releaseDate = releaseDate
        }
        
        if let directors = directors as? [String] {
            movie.directors = directors
        }
        
        if let genres = genres as? [String] {
            movie.genres = genres
        }
        
        if let productionCountries = productionCountries as? [String] {
            movie.productionCountries = productionCountries
        }
        
        if let tmdbRating = tmdbRating as? Float {
            movie.tmdbRating = tmdbRating
        }
        
        if let yourRating = yourRating as? Float {
            movie.yourRating = yourRating
        }
        
        if let overview = overview {
            movie.overview = overview
        }
        
        if let w92Poster = w92Poster {
            movie.w92Poster = UIImage(data: w92Poster)
        }
        
        if let w300Poster = w300Poster {
            movie.w300Poster = UIImage(data: w300Poster)
        }
        
        if let imdbID = imdbID {
            movie.imdbID = imdbID
        }
        
        if let watchedDate = watchedDate {
            movie.watchedDate = watchedDate
        }

        if let comments = comments {
            movie.comments = comments
        }
        
        if let lastUpdateDate = lastUpdateDate {
            movie.lastUpdateDate = lastUpdateDate
        }
    }

}
