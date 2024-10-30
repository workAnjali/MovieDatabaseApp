import UIKit

class RatingControl: UIStackView {
    // Properties
    private var ratingButtons: [UIButton] = []
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    private let starCount = 5

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    private func setupButtons() {
        // Remove any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // Create the buttons
        for _ in 0..<starCount {
            let button = UIButton()
            
            // Configure button image for different states
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.setImage(UIImage(systemName: "star.fill"), for: .highlighted)
            button.setImage(UIImage(systemName: "star.fill"), for: [.highlighted, .selected])
            
            // Set up button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add button to the stack
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        
        // Update the button selection states
        updateButtonSelectionStates()
    }
    
    @objc private func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            return
        }
        
        // Calculate the rating from the button's index
        let selectedRating = index + 1
        
        // If the selected star represents the current rating, reset the rating to 0.
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }

    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // Each button is selected if its index is less than the rating
            button.isSelected = index < rating
        }
    }
}
