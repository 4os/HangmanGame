import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var lettersRow1: UIView!
    @IBOutlet var lettersRow2: UIView!
    @IBOutlet var lettersRow3: UIView!
    @IBOutlet var lettersRow4: UIView!
    
    
    let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var letterButtons = [UIButton]()
    
    var words = [String]()
    var currentWord: String = "silkworm"
    var numberOfErrors = 0
    var correctLetters = [String]()
    var score = 0
    
    let supportedLanguages = ["English", "Turkish"]
    
    let activeButtonColor = UIColor.black
    let inactiveButtonColor = UIColor(red: 198/255, green: 216/255, blue: 0, alpha: 1)
    
    override func loadView() {
        super.loadView()
        
        addButtonsRow(startingPosition: 0, maxCol: 6, view: lettersRow1)
        addButtonsRow(startingPosition: 6, maxCol: 7, view: lettersRow2)
        addButtonsRow(startingPosition: 13, maxCol: 6, view: lettersRow3)
        addButtonsRow(startingPosition: 19, maxCol: 7, view: lettersRow4)
    }
    
    func addButtonsRow(startingPosition: Int, maxCol: Int, view: UIView) {
        for col in 0..<maxCol {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.init(name: "Noteworthy", size: 30)
            button.setTitleColor(activeButtonColor, for: .normal)
            button.setTitle(letters[startingPosition + col], for: .normal)
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .center
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            
            view.addSubview(button)
            
            button.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/CGFloat(maxCol)).isActive = true
            
            switch col {
            case 0:
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            case maxCol - 1:
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                fallthrough
            default:
                button.leadingAnchor.constraint(greaterThanOrEqualTo: letterButtons[startingPosition + (col - 1)].trailingAnchor).isActive = true
            }
            
            letterButtons.append(button)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh Game", style: .plain, target: self, action: #selector(newGameTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))

        performSelector(inBackground: #selector(loadWords), with: supportedLanguages[0].lowercased())
    }

    @objc func newGameTapped() {
        let ac = UIAlertController(title: "Refresh Game", message: nil, preferredStyle: .actionSheet)
        
        for language in supportedLanguages {
            ac.addAction(UIAlertAction(title: language, style: .default, handler: newGameWithLanguageTapped))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(ac, animated: true)
    }
    
    @objc func newGameWithLanguageTapped(action: UIAlertAction) {
        guard let actionTitle = action.title else {
            return
        }
        
        performSelector(inBackground: #selector(loadWords), with: actionTitle.lowercased())
    }
    
    @objc func loadWords(language: String) {
        if let wordsUrl = Bundle.main.url(forResource: language, withExtension: "txt") {
            if let wordsString = try? String(contentsOf: wordsUrl) {
                words = wordsString.components(separatedBy: "\n")
            }
        }
        
        if words.isEmpty {
            words.append("silkworm")
        }
        
        performSelector(onMainThread: #selector(startGame), with: nil, waitUntilDone: false)
    }
    
    @objc func startGame() {
        currentWord = words.randomElement()!.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        for button in letterButtons {
            button.isUserInteractionEnabled = true
            button.setTitleColor(activeButtonColor, for: .normal)
        }
        
        wordLabel.text = String(repeating: "_ ", count: currentWord.count).trimmingCharacters(in: .whitespaces)
        
        numberOfErrors = 0
        correctLetters = [String]()
        imageView.image = UIImage(named: "Adam\(numberOfErrors)")
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Score", message: "\(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    @objc func letterTapped(_ sender: UIButton) {
        let letter = sender.titleLabel?.text
        
        if currentWord.folding(options: .diacriticInsensitive, locale: .current).contains(letter!) {
            correctLetters.append(letter!)
            
            manageCorrectGuess()
        }
        else {
            manageIncorrectGuess()
        }
        
        sender.isUserInteractionEnabled = false
        sender.setTitleColor(inactiveButtonColor, for: .normal)
    }
    
    func manageCorrectGuess() {
        var wordText = ""
        var wordComplete = true
        
        for l in currentWord {
            let strLetter = String(l)
            
            if correctLetters.contains(strLetter.folding(options: .diacriticInsensitive, locale: .current)) {
                wordText += "\(strLetter) "
            } else {
                wordText += "_ "
                wordComplete = false
            }
        }
        
        wordLabel.text = wordText.trimmingCharacters(in: .whitespaces)
        
        if wordComplete {
            for button in letterButtons {
                button.isUserInteractionEnabled = false
            }
            
            score += 2
            
            let ac = UIAlertController(title: "Congratulations!", message: "Word found:\n\(currentWord)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    func manageIncorrectGuess() {
        numberOfErrors += 1
        imageView.image = UIImage(named: "Adam\(numberOfErrors)")
        
        if numberOfErrors == 7 {
            for button in letterButtons {
                button.isUserInteractionEnabled = false
            }
            
            score -= 1
            
            let ac = UIAlertController(title: "Wrong!", message: "Word is\n\(currentWord)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

