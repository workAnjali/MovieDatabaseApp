import UIKit

class MovieListViewController: UITableViewController, UISearchResultsUpdating {
    var allMovies: [Movie] = []
    var filteredMovies: [Movie] = []
    var expandedSections: Set<Int> = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        allMovies = loadMovies()
        print("All Movies Loaded: \(allMovies.count)") // Debugging output
        tableView.allowsSelection = true // Ensure selection is enabled

        filteredMovies = allMovies
        setupSearchController()
    }

    // Setup Search Controller
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // Load Movies from JSON
    func loadMovies() -> [Movie] {
        guard let url = Bundle.main.url(forResource: "movies", withExtension: "json") else {
            print("Could not find movies.json file") // Debugging output
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            print("Data read from file: \(data.count) bytes") // Debugging output

            // Print the raw JSON data as a string for inspection
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON data: \(jsonString)") // Print raw JSON
            } else {
                print("Failed to convert data to string")
            }

            // Decode the JSON data into an array of Movie
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            print("Loaded movies: \(movies)") // Debugging output
            return movies
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
            return []
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context)")
            return []
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context)")
            return []
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context)")
            return []
        } catch {
            print("Error loading movies: \(error.localizedDescription)")
            return []
        }
    }




    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMovieDetail" {
            print("Preparing for segue to ShowMovieDetail")
            if let detailVC = segue.destination as? MovieDetailViewController,
               let indexPath = sender as? IndexPath { // Use sender as IndexPath
                
                if indexPath.row < filteredMovies.count {
                    let selectedMovie = filteredMovies[indexPath.row]
                    detailVC.movie = selectedMovie
                    print("Selected movie: \(selectedMovie.title)") // Debugging output
                    detailVC.movie = selectedMovie
                    print("Selected movie: \(selectedMovie.title)")
                } else {
                    print("Index out of range: \(indexPath.row) for filteredMovies.count: \(filteredMovies.count)")
                }

               // Debugging output
            }
        }
    }



    // Update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.lowercased() ?? ""
        
        if query.isEmpty {
            // If the search query is empty, reset to all movies
            filteredMovies = allMovies
        } else {
            // Filter movies based on search query
            filteredMovies = allMovies.filter { movie in
                movie.title.lowercased().contains(query) ||
                movie.year.lowercased().contains(query) ||
                movie.genre.contains(where: { $0.lowercased().contains(query) }) ||
                movie.actors.contains(where: { $0.lowercased().contains(query) }) ||
                movie.director.lowercased().contains(query)
            }
        }
        
        // Reload the table view to show results
        tableView.reloadData()
        print("Filtered movies count: \(filteredMovies.count)") // Debugging output
    }


    // Table View Data Source
   
    
 


    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 { // "All Movies" section
            return 100 // Adjust this value to increase the row height
        }
        return UITableView.automaticDimension // Use automatic height for other sections
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Increase the height of the header
    }

    @objc func headerTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let section = gestureRecognizer.view?.tag else { return }
        print("Header tapped for section \(section)") // Debugging log

        if expandedSections.contains(section) {
            expandedSections.remove(section)
            print("Collapsed section \(section)") // Debugging output
        } else {
            expandedSections.insert(section)
            print("Expanded section \(section)") // Debugging output
        }
        
        // Reload the section to show/hide rows
        tableView.reloadSections([section], with: .automatic)
    }

    // Header for Expand/Collapse
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.isUserInteractionEnabled = true

        header.textLabel?.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        // Add tap gesture to header
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        header.addGestureRecognizer(tapGesture)
        header.tag = section // Set section as tag to identify later
        
        return header
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Show only one section when search is active; otherwise, show all 5 sections
        return searchController.isActive ? 1 : 5
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return "Search Results"
        }
        
        switch section {
        case 0: return "Year"
        case 1: return "Genre"
        case 2: return "Directors"
        case 3: return "Actors"
        case 4: return "All Movies"
        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            // Show only filtered movies when searching
            return filteredMovies.count
        }

        if section == 4 {
            return expandedSections.contains(section) ? filteredMovies.count : 0
        }
        
        let numberOfRows = expandedSections.contains(section) ? getSectionData(section).count : 0
        return numberOfRows
    }
    // Toggle Expand/Collapse
 

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie: Movie

        if searchController.isActive {
            movie = filteredMovies[indexPath.row]
        } else {
            // Determine movie based on section
            if indexPath.section == 4 {
                movie = filteredMovies[indexPath.row]
            } else {
                let data = getSectionData(indexPath.section)[indexPath.row]
                cell.textLabel?.text = data // Customize cell for each non-"All Movies" section
                return cell
            }
        }
        
        // Configure cell with movie details
        cell.titleLabel.text = movie.title
        cell.languageLabel.text = movie.language
        cell.yearLabel.text = String(movie.year)
        
        // Load thumbnail image
        cell.posterImageView.image = nil
        if let thumbnailURL = movie.poster, let url = URL(string: thumbnailURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                            cell.posterImageView.image = image
                        }
                    }
                }
            }
        }
        
        return cell
    }


    func getSectionData(_ section: Int) -> [String] {
        let data: [String]
        switch section {
        case 0:
            data = Array(Set(allMovies.map { String($0.year) }))
        case 1:
            data = Array(Set(allMovies.flatMap { $0.genre }))
        case 2:
            data = Array(Set(allMovies.map { $0.director }))
        case 3:
            data = Array(Set(allMovies.flatMap { $0.actors }))
        case 4:
            data = allMovies.map { $0.title }
        default:
            data = []
        }
        print("Data for section \(section): \(data)") // Debugging output
        return data
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell at \(indexPath) was selected") // Debugging log

        // Deselect the cell
        tableView.deselectRow(at: indexPath, animated: true)

        // Perform the segue to show the movie detail and pass the index path
        performSegue(withIdentifier: "ShowMovieDetail", sender: indexPath)
    }




}

