//
//  Search.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 31/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class Search {
    
    
    
    enum Type: Int {
        case Movie = 0
        case Tv = 1
        
        var type: String {
            switch self {
            case .Movie: return "movie"
            case .Tv: return "tv"
            }
        }
    }
    
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
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let url = urlWithSearchText(text, type: type)
            let request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithRequest(request, completionHandler: {
                data, response, error in
                
                var success = false
                self.state = .NotSearchedYet
                
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
        
        if let array: AnyObject = dictionary["results"] {
            for resultDict in array as! [AnyObject] {
                println("\(resultDict)")
                var movie = Movie()
                movie.title = resultDict["title"] as! String
                movie.id = resultDict["id"] as! Int
                movie.type = type
                movie.tmdbRating = resultDict["vote_average"] as! Double
                
                if let releaseDate = resultDict["release_date"] as? String {
                    movie.releaseDate = releaseDate
                }
                
                if let overview = resultDict["overview"] as? String {
                    movie.overview = overview
                }
                
                if let posterAddress = resultDict["poster_path"] as? String {
                    movie.posterAddress = posterAddress
                }
                
                movies.append(movie)
                
            }
        }
        
        return movies
    }
    
    private func urlWithSearchText(searchText: String, type: Int) -> NSURL {
        
        let movieType: String
        switch type {
        case 0:
            movieType = "movie"
        case 1:
            movieType = "tv"
        default:
            movieType = "movie"
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format: "https://api.themoviedb.org/3/search/%@?api_key=%@&query=%@&include_adult=false&language=en", movieType, Constants.kFTAPIKey , escapedSearchText)
        let url = NSURL(string: urlString)
        println(url)
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
