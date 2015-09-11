//
//  UIImageView+DownloadImage.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageWithMovieObject(movie: Movie, imageSize: Movie.ImageSize) -> NSURLSessionDownloadTask {
        var url = NSURL()
        switch imageSize {
        case .w92:
            url = movie.getURLWithType(Movie.URLType.posterW92)
        case .w300:
            url = movie.getURLWithType(Movie.URLType.posterW300)
        }
        
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url!) {
                    if let image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // check whether the UIImageView is still existing
                            if let strongSelf = self {
                                strongSelf.image = image
                                switch imageSize {
                                case .w92:
                                    movie.w92Poster = image
                                case .w300:
                                    movie.w300Poster = image
                                    if movie.w92Poster == nil {
                                        movie.w92Poster = movie.w300Poster!.resizedImageWithBounds(CGSizeMake(92, 138))
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
    
}