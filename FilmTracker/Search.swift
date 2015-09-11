//
//  Search.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Search {
    
    var films: [Film]?
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([Movie])
    }
    
    private(set) var state: State = .NotSearchedYet
    typealias SearchComplete = (Bool) -> Void
    private var dataTask: NSURLSessionDataTask?
    
    func performSearchForText(text: String, type: Int, films: [Film]?, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            if let films = films {
                self.films = films
            }
            
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
                    print("*** Failure! \(error)")
                    // if error.code == -999 { return }
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data!) {
                            let searchResults = self.parseDictionary(dictionary, type: type)
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
    
    func parseJSON(data: NSData) ->[String: AnyObject]? {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
            return json
        } catch let error as NSError {
            print("*** Parsing JSON Error \(error)")
        }
        return nil
    }
    
    private func parseDictionary(dictionary: [String: AnyObject], type: Int) -> [Movie] {
        var movies = [Movie]()
        
        if type == 0 {
            if let array: AnyObject = dictionary["results"] {
                for resultDict in array as! [AnyObject] {
                    var movie: Movie?
                    movie = parseMovie(resultDict as! [String: AnyObject])
                    if let searchedMovie = movie {
                        movies.append(searchedMovie)
                    }
                }
            }
        } else if type == 1 {
            if let searchResult: AnyObject = dictionary["results"] {
                for results in searchResult as! [AnyObject] {
                    if let array: AnyObject = results["known_for"] {
                        for resultDict in array as! [AnyObject] {
                            var movie: Movie?
                            if let movieType = resultDict["media_type"] as? String {
                                if movieType == "movie" {
                                    movie = parseMovie(resultDict as! [String: AnyObject])
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
        let movie = Movie()
        
        movie.id = dictionary["id"] as! Int
        
        if films != nil && films!.count > 0 {
            for film in films! {
                if film.id == movie.id {
                    film.convertToMovieObject(movie)
                } else {
                    movie.title = dictionary["title"] as! String
                    
                    if let tmdbRating = dictionary["vote_average"] as? Float {
                        movie.tmdbRating = tmdbRating
                    }
                    
                    if let releaseDate = dictionary["release_date"] as? String {
                        movie.releaseDate = movie.convertStringToDate(releaseDate)
                    }
                    
                    if let overview = dictionary["overview"] as? String {
                        movie.overview = overview
                    }
                    
                    if let posterAddress = dictionary["poster_path"] as? String {
                        movie.posterAddress = posterAddress
                    }
                }
            }
        } else {
            movie.title = dictionary["title"] as! String
            
            if let tmdbRating = dictionary["vote_average"] as? Float {
                movie.tmdbRating = tmdbRating
            }
            
            if let releaseDate = dictionary["release_date"] as? String {
                movie.releaseDate = movie.convertStringToDate(releaseDate)
            }
            
            if let overview = dictionary["overview"] as? String {
                movie.overview = overview
            }
            
            if let posterAddress = dictionary["poster_path"] as? String {
                movie.posterAddress = posterAddress
            }
        }
    
        return movie
    }

    private func urlWithSearchText(searchText: String, type: Int) -> NSURL {
        var movieType: String
        
        switch type {
        case 0:
            movieType = "movie"
        case 1:
            movieType = "person"
        default:
            fatalError("*** A bug here!")
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let urlString = String(format: "https://api.themoviedb.org/3/search/%@?api_key=%@&search_type=ngram&query=%@", movieType, Constants.kFTAPIKey , escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
}
