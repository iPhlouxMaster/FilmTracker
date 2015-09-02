//
//  SearchResultCell.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    var downloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var floatRatingView: FloatRatingView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        floatRatingView.fullImage = UIImage(named: "StarFull")
        // Optional params
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 10
        floatRatingView.minRating = 1
        floatRatingView.editable = false
        floatRatingView.halfRatings = true
        floatRatingView.floatRatings = true
        
        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(red: 20 / 255, green: 160 / 255, blue: 160 / 255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForSearchResult(movie: Movie) {
        movieTitleLabel.text = movie.title
        typeLabel.text = movie.movieType()
        floatRatingView.rating = Float(movie.tmdbRating)
        if !movie.releaseDate.isEmpty {
            releaseDateLabel.text = movie.releaseDate
        } else {
            releaseDateLabel.text = "Not Available"
        }
        
        if !movie.posterAddress.isEmpty {
            downloadTask = posterImageView.loadImageWithURL(movie.posterURLW92())
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        movieTitleLabel.text = nil
        releaseDateLabel.text = nil
        posterImageView.image = nil
        floatRatingView.delegate = nil
    }
    
}

extension SearchResultCell: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }

}
