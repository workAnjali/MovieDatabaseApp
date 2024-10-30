//
//  MovieDetailViewController.swift
//  MovieDatabaseApp
//
//  Created by Anjali on 30/10/24.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingControl: UISegmentedControl!

    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let movie = movie {
            setupMovieDetails(movie)
        }
    }

    func setupMovieDetails(_ movie: Movie) {
        titleLabel.text = movie.title
        plotLabel.text = movie.plot

        // Assuming movie.genre is [String]
        genreLabel.text = movie.genre.joined(separator: ", ") // Combine genres

        // Assuming movie.ratings is [Rating] and Rating has source and value properties
        ratingLabel.text = movie.ratings.map { "\($0.source): \($0.value)" }.joined(separator: ", ") // Combine ratings

        if let url = URL(string: movie.poster ?? "") {
            downloadImage(from: url)
        }
    }


    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    @IBAction func ratingControlChanged(_ sender: UISegmentedControl) {
        let ratingSource = sender.titleForSegment(at: sender.selectedSegmentIndex)
      
    }
}
