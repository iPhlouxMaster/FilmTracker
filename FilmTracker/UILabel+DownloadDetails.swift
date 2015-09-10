//
//  UILabel+DownloadContent.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

extension UILabel {
    func loadDetailsWithMovieObject(movie: Movie) -> NSURLSessionDownloadTask {
        let url = movie.getURLWithType(Movie.URLType.movieDetails)
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url!) {
                    let search = Search()
                    if let dictionary = search.parseJSON(data) {
                        if let imdb_id = dictionary["imdb_id"] as? String {
                            movie.imdbID = imdb_id
                        }
                        
                        if let productionCountries = dictionary["production_countries"] as? [AnyObject] {
                            var countries = [String]()
                            for country in productionCountries {
                                if let countryName = country["iso_3166_1"] as? String {
                                    countries.append(countryName)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if let strongSelf = self {
                                    if countries.isEmpty {
                                        strongSelf.text = "Not Available"
                                        // movie.productionCountries.append("Not Available")
                                    } else {
                                        strongSelf.text = countries.joinWithSeparator(", ")
                                        movie.productionCountries = countries
                                    }
                                }
                            })
                        }
                        
                        if let genres = dictionary["genres"] as? [AnyObject] {
                            var genresArray = [String]()
                            for genre in genres {
                                if let genreName = genre["name"] as? String {
                                    genresArray.append(genreName)
                                }
                            }
                            if genresArray.isEmpty {
                                // movie.genres.append("Not Available")
                            } else {
                                movie.genres = genresArray
                            }
                        }
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
    
    func loadCreditsWithMovieObject(movie: Movie) -> NSURLSessionDownloadTask {
        let url = movie.getURLWithType(Movie.URLType.movieCredits)
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url!) {
                    let search = Search()
                    if let dictionary = search.parseJSON(data) {
                        if let crews = dictionary["crew"] as? [AnyObject] {
                            var directors = [String]()
                            for crew in crews {
                                if crew["job"] as! String == "Director" {
                                    if let director = crew["name"] as? String {
                                        directors.append(director)
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if let strongSelf = self {
                                    if directors.isEmpty {
                                        strongSelf.text = "Not Available"
                                        // movie.directors.append("Not Available")
                                    } else {
                                        strongSelf.text = directors.joinWithSeparator(", ")
                                        movie.directors = directors
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
}