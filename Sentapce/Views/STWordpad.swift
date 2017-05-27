import UIKit

protocol STWordpadDelegate {
    func wordpad(_ wordpad: STWordpad, didSelectWord word: String, isCorrect: Bool)
}

@IBDesignable class STWordpad: UIView {
    //MARK: Properties
    
    var delegate: STWordpadDelegate?
    internal var backgroundView = UIInputView(frame: .zero, inputViewStyle: .keyboard)
    internal var stackView = UIStackView()
    internal var wordButtons = [UIButton]()
    
    var words = ["First", "Second", "Third"] {
        didSet {
            setupButtons()
        }
    }
    
    var answerIndex: Int = 0
    
    var axis: UILayoutConstraintAxis = .vertical
    @IBInspectable var unselectedTitleColor: UIColor = .gray
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: Methods
    
    func setup(answer: String, choices: [String]) {
        self.words = choices
        self.answerIndex = Int(arc4random_uniform(UInt32(choices.count + 1)))
        self.words.insert(answer, at: answerIndex)
    }
    
    //MARK: Button Action
    
    func wordButtonTapped(button: UIButton) {
        guard let index = wordButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the segmentButtons array: \(wordButtons)")
        }
        
        for (offset, button) in wordButtons.enumerated() {
            button.isSelected = (offset == index)
        }
        
        self.delegate?.wordpad(self, didSelectWord: words[index], isCorrect: (index == answerIndex))
    }
    
    
    //MARK: Private Methods
    
    private func setupView() {
        self.backgroundColor = nil
        
        setupBackgroundView()
        setupStackView()
        setupButtons()
    }
    
    private func setupBackgroundView() {
        self.insertSubview(backgroundView, at: 0)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func setupStackView() {
        self.insertSubview(stackView, at: 1)
        
        stackView.axis = self.axis
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func setupButtons() {
        
        // Clear any existing buttons
        for button in wordButtons {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        wordButtons.removeAll()
        
        for (index, word) in words.enumerated() {
            // Create the button
            let button = UIButton()
            
            var refinedWord = word
            refinedWord = refinedWord.lowercased()
            refinedWord = try! NSRegularExpression(pattern: "[^A-Za-z0-9]").stringByReplacingMatches(in: refinedWord, range: refinedWord.fullRange, withTemplate: "")
            
            // Set the title label text
            button.setTitle(refinedWord, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.black, for: .highlighted)
            button.setBackgroundColor(UIColor(hex: 0xABB5BD), for: .normal)
            button.setBackgroundColor(UIColor(hex: 0xEBEDEF), for: .highlighted)
            
            if index == answerIndex {
                button.setTitleColor(.black, for: .selected)
                button.setBackgroundColor(.green, for: .selected)
            } else {
                button.setTitleColor(.white, for: .selected)
                button.setBackgroundColor(.red, for: .selected)
            }
            
            // Setup the button action
            button.addTarget(self, action: #selector(self.wordButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            stackView.addArrangedSubview(button)
            
            // Add the new button to the rating button array
            wordButtons.append(button)
        }
        
        //updateSegmentSelectionStates()
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: state)
    }
}

extension UIColor {
    convenience init(hex: UInt) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 08) & 0xFF) / 255
        let blue = CGFloat((hex >> 00) & 0xFF) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
