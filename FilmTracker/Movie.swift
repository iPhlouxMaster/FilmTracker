//
//  Movie.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import Foundation

class Movie {
    
    var title = ""
    var id = 0
    var type = 0
    var releaseDate = ""
    var posterAddress = ""
    var directors = ""
    var genres = ""
    var tmdbRating = 0.0
    var overview = ""
    
    func convertStringToDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(dateString)!
    }
    
}
