//
//  UIImageView+DownloadImage.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageWithMovieObject(movie: Movie, imageSize: Int) -> NSURLSessionDownloadTask {
        var url = NSURL()
        if imageSize == 0 {
            url = movie.getURLWithType(0)
        } else if imageSize == 1 {
            url = movie.getURLWithType(1)
        }
        
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: { [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // check whether the UIImageView is still existing
                            if let strongSelf = self {
                                strongSelf.image = image
                                if imageSize == 0 {
                                    movie.w92Poster = image
                                } else if imageSize == 1 {
                                    movie.w300Poster = image
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