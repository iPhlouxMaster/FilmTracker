//
//  DetailViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var movie: Movie?
    var imageDownloadTask: NSURLSessionDownloadTask?
    var genresDownloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var imdbIDLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    deinit {
        imageDownloadTask?.cancel()
        genresDownloadTask?.cancel()
    }
    
    func configureView() {
        
        if let image = movie!.w300Poster {
            posterImageView.image = image
        } else {
            imageDownloadTask = posterImageView.loadImageWithMovieObject(movie!, imageSize: 1)
        }
        
        genresDownloadTask = imdbIDLabel.loadGenresWithMovieObject(movie!)
    }
}
