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
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var overViewTextView: UITextView!
    
    @IBAction func saveToListButtonPressed(sender: UIButton) {
        
    }
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        floatRatingView.delegate = self
        
        floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        floatRatingView.fullImage = UIImage(named: "StarFull")
        
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 10
        floatRatingView.minRating = 1
        floatRatingView.editable = false
        floatRatingView.halfRatings = true
        floatRatingView.floatRatings = true
        
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
        
        titleLabel.text = movie!.title
        directorLabel.text = ", ".join(movie!.directors)
        releaseDateLabel.text = movie!.releaseDate
        floatRatingView.rating = Float(movie!.tmdbRating)
        
        if !movie!.genres.isEmpty {
            genresLabel.text = ", ".join(movie!.genres)
        } else {
            genresDownloadTask = genresLabel.loadGenresWithMovieObject(movie!)
        }
        
        overViewTextView.text = movie!.overview
        
    }
}

extension DetailViewController: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
}
