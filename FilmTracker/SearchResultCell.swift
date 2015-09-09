//
//  SearchResultCell.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    var imageDownloadTask: NSURLSessionDownloadTask?
    var directorDownloadTask: NSURLSessionDownloadTask?
    var productionCountriesDownloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var productionCountriesLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var floatRatingView: FloatRatingView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        floatRatingView.fullImage = UIImage(named: "StarFull")

        floatRatingView.delegate = self
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 10
        floatRatingView.minRating = 1
        floatRatingView.editable = false
        floatRatingView.halfRatings = true
        floatRatingView.floatRatings = true
        
//        let selectedView = UIView(frame: CGRect.zeroRect)
//        selectedView.backgroundColor = UIColor(red: 20 / 255, green: 160 / 255, blue: 160 / 255, alpha: 0.5)
//        selectedBackgroundView = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForSearchResult(movie: Movie) {
        movieTitleLabel.text = movie.title
        
        if let tmdbRating = movie.tmdbRating {
            floatRatingView.rating = tmdbRating
        }
        
        if let directors = movie.directors {
            directorLabel.text = ", ".join(directors)
        } else {
            directorDownloadTask = directorLabel.loadCreditsWithMovieObject(movie)
        }
        
        if let countries = movie.productionCountries {
            productionCountriesLabel.text = ", ".join(countries)
        } else {
            productionCountriesDownloadTask = productionCountriesLabel.loadDetailsWithMovieObject(movie)
        }
        
        if let image = movie.w92Poster {
            posterImageView.image = image
        } else {
            if let posterAddress = movie.posterAddress  {
                imageDownloadTask = posterImageView.loadImageWithMovieObject(movie, imageSize: Movie.ImageSize.w92)
            } else {
                posterImageView.image = UIImage(named: "no-poster.jpeg")
            }
        }
        
        if let film = movie.film {
            contentView.backgroundColor = UIColor.lightGrayColor()
        } else {
            contentView.backgroundColor = UIColor.clearColor()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
        directorDownloadTask?.cancel()
        productionCountriesDownloadTask?.cancel()
        movieTitleLabel.text = nil
        productionCountriesLabel.text = nil
        posterImageView.image = nil
        floatRatingView.delegate = nil
    }
    
}

// MARK: - FloatRatingViewDelegate

extension SearchResultCell: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }

}
