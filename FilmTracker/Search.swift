//
//  Search.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Search {
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([Movie])
    }
    
    private(set) var state: State = .NotSearchedYet
    typealias SearchComplete = (Bool) -> Void
    private var dataTask: NSURLSessionDataTask?
    
    func performSearchForText(text: String, type: Int, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            state = .Loading
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let url = urlWithSearchText(text, type: type)
            let request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithRequest(request, completionHandler: {
                data, response, error in
                
                var success = false
                self.state = .Loading
                
                if let error = error {
                    println("Failure! \(error)")
                    if error.code == -999 { return }
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data) {
                            var searchResults = self.parseDictionary(dictionary, type: type)
                            if searchResults.isEmpty {
                                self.state = .NoResults
                            } else {
                                self.state = .Results(searchResults)
                            }
                            success = true
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(success)
                })
            })
            dataTask?.resume()
        }
    }
    
    private func parseDictionary(dictionary: [String: AnyObject], type: Int) -> [Movie] {
        var movies = [Movie]()
        
        if type == 0 || type == 1 {
            if let array: AnyObject = dictionary["results"] {
                for resultDict in array as! [AnyObject] {
                    var movie: Movie?
                    if type == 0 {
                        movie = parseMovie(resultDict as! [String: AnyObject])
                    } else if type == 1 {
                        movie = parseTV(resultDict as! [String: AnyObject])
                    }
                    
                    if let searchedMovie = movie {
                        movies.append(searchedMovie)
                    }
                }
            }
        } else if type == 2 {
            if let searchResult: AnyObject = dictionary["results"] {
                for results in searchResult as! [AnyObject] {
                    if let array: AnyObject = results["known_for"] {
                        for resultDict in array as! [AnyObject] {
                            var movie: Movie?
                            if let movieType = resultDict["media_type"] as? String {
                                if movieType == "movie" {
                                    movie = parseMovie(resultDict as! [String: AnyObject])
                                } else if movieType == "tv" {
                                    movie = parseTV(resultDict as! [String: AnyObject])
                                }
                            }
                            if let searchedMovie = movie {
                                movies.append(searchedMovie)
                            }
                        }
                    }
                }
            }
        }
        return movies
    }
    
    private func parseMovie(dictionary: [String : AnyObject]) -> Movie {
        var movie = Movie()
        movie.title = dictionary["title"] as! String
        movie.id = dictionary["id"] as! Int
        movie.type = 0
        movie.tmdbRating = dictionary["vote_average"] as! Double
        if let releaseDate = dictionary["release_date"] as? String {
            movie.releaseDate = releaseDate
        }
        
        if let overview = dictionary["overview"] as? String {
            movie.overview = overview
        }
        
        if let posterAddress = dictionary["poster_path"] as? String {
            movie.posterAddress = posterAddress
        }
        
        return movie
    }
    
    private func parseTV(dictionary: [String : AnyObject]) -> Movie {
        var tv = Movie()
        tv.title = dictionary["name"] as! String
        tv.id = dictionary["id"] as! Int
        tv.type = 1
        tv.tmdbRating = dictionary["vote_average"] as! Double
        if let releaseDate = dictionary["first_air_date"] as? String {
            tv.releaseDate = releaseDate
        }
        
        if let overview = dictionary["overview"] as? String {
            tv.overview = overview
        }
        
        if let posterAddress = dictionary["poster_path"] as? String {
            tv.posterAddress = posterAddress
        }
        
        return tv
    }

    private func urlWithSearchText(searchText: String, type: Int) -> NSURL {
        var movieType: String
        
        switch type {
        case 0:
            movieType = "movie"
        case 1:
            movieType = "tv"
        case 2:
            movieType = "person"
        default:
            fatalError("*** A bug here!")
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format: "https://api.themoviedb.org/3/search/%@?api_key=%@&query=%@", movieType, Constants.kFTAPIKey , escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    private func parseJSON(data: NSData) ->[String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("*** Parsing JSON Error \(error)")
        } else {
            println("*** Unknown Parsing JSON Error")
        }
        return nil
    }
}
