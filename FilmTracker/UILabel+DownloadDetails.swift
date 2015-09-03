//
//  UILabel+DownloadContent.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

extension UILabel {
    func loadGenresWithMovieObject(movie: Movie) -> NSURLSessionDownloadTask {
        let url = movie.getURLWithType(2)
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url) {
                    let search = Search()
                    if let dictionary = search.parseJSON(data) {
                        if let genres = dictionary["genres"] as? [AnyObject] {
                            var genresArray = [String]()
                            for genre in genres {
                                if let genreName = genre["name"] as? String {
                                    genresArray.append(genreName)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // check whether the UIImageView is still existing
                                if let strongSelf = self {
                                    if genresArray.isEmpty {
                                        strongSelf.text = "Not Available"
                                    } else {
                                        strongSelf.text = ", ".join(genresArray)
                                        movie.genres = genresArray
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
    
    func loadCastsWithMovieObject(movie: Movie) -> NSURLSessionDownloadTask {
        let url = movie.getURLWithType(3)
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url) {
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
                                // check whether the UIImageView is still existing
                                if let strongSelf = self {
                                    if directors.isEmpty {
                                        strongSelf.text = "Not Available"
                                    } else {
                                        strongSelf.text = ", ".join(directors)
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