import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    let ratingControl = RatingControl()

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        languageLabel.text = "Language: \(movie.language)"
        yearLabel.text = "Year: \(movie.year)"
        
        if let url = URL(string: movie.poster ?? "") {
            downloadImage(from: url)
        }
    }
    override func prepareForReuse() {
          super.prepareForReuse()
          // Reset the cell’s content to avoid showing data from reused cells
          posterImageView.image = nil
          titleLabel.text = ""
          languageLabel.text = ""
          yearLabel.text = ""
      }
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
