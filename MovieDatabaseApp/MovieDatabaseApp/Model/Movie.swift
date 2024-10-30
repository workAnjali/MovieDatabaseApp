import Foundation

struct Movie: Codable {
    let title: String
    let year: String // Keeping as String to match JSON
    let genre: [String]
    let director: String
    let actors: [String]
    let plot: String
    let language: String
    let ratings: [Rating] // Changed to an array of Rating objects
    let poster: String?
    
    // Coding keys to map JSON keys to struct properties
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case genre = "Genre"
        case director = "Director"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case ratings = "Ratings"
        case poster = "Poster"
    }
}

// New struct to represent ratings
struct Rating: Codable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}

// Custom decoder to handle genre and actors splitting
extension Movie {
    enum MovieError: Error {
        case invalidData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        year = try container.decode(String.self, forKey: .year)
        
        // Splitting Genre and Actors into arrays
        let genreString = try container.decode(String.self, forKey: .genre)
        genre = genreString.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let actorsString = try container.decode(String.self, forKey: .actors)
        actors = actorsString.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
        
        director = try container.decode(String.self, forKey: .director)
        plot = try container.decode(String.self, forKey: .plot)
        language = try container.decode(String.self, forKey: .language)
        
        // Decoding Ratings as an array of Rating objects
        ratings = try container.decode([Rating].self, forKey: .ratings)
        poster = try container.decode(String.self, forKey: .poster)
    }
}
