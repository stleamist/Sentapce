import UIKit

// MARK: Implementation of CompositionViewController

class CompositionViewController: UITableViewController {
    
    enum CompositionType {
        case suggesting
        case translation
        case full
    }
    
    
    // MARK: Stored Properties
    
    var compositionType: CompositionType!
    
    var question: EBSBookQuestion! {
        didSet {
            question.sentences.clear()
        }
    }
    var sentences: [EBSBookSentence] {
        get {
            return self.question.sentences
        }
        set {
            self.question.sentences = newValue
        }
    }
    var currentSentence: EBSBookSentence?

    
    
    // MARK: UIKeyCommand Property
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "",
                         modifierFlags: .control,
                         action: #selector(toggleHint),
                         discoverabilityTitle: "Toggle Hint")
        ]
    }
    
    
    // MARK: UIView Properties
    @IBOutlet var wordpad: STWordpad!
    @IBOutlet var accessoryBar: UIToolbar!
    
    var designatedInputView: UIView? {
        if self.compositionType == .suggesting {
            return self.wordpad
        } else {
            return nil
        }
    }
    
    // MARK: IBActions
    @IBAction func previousButtonDidTapped(_ sender: UIBarButtonItem) {
        self.moveToPreviousSentence()
    }
    @IBAction func nextButtonDidTapped(_ sender: UIBarButtonItem) {
        self.moveToNextSentence()
    }
    @IBAction func bookmarkButtonDidTapped(_ sender: UIBarButtonItem) {
        self.toggleHint()
    }
    
    
    // MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 내비게이션 막대 제목 설정
        self.navigationItem.title = question?.subject
        
        // 동적 테이블뷰 셀 높이 설정
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        wordpad.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // 자동 텍스트뷰 First Responder 설정
        let indexPath = IndexPath(row: 1, section: 0)
        
        tableView.selectRowByIntent(at: indexPath, animated: false, scrollPosition: .middle)
    }
    
    // MARK: Custom Methods
    
    func moveToPreviousSentence() {
        guard let index = self.tableView.indexPathForSelectedRow?.section else {
            return
        }
        let fromIndexPath = IndexPath(row: 1, section: index)
        let toIndexPath = IndexPath(row: 1, section: index - 1)
        
        if tableView.hasCellForRow(at: toIndexPath) {
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: fromIndexPath)
            tableView.selectRowByIntent(at: toIndexPath, animated: false, scrollPosition: .middle)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func moveToNextSentence() {
        guard let index = self.tableView.indexPathForSelectedRow?.section else {
            return
        }
        let fromIndexPath = IndexPath(row: 1, section: index)
        let toIndexPath = IndexPath(row: 1, section: index + 1)
        
        if tableView.hasCellForRow(at: toIndexPath) {
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: fromIndexPath)
            tableView.selectRowByIntent(at: toIndexPath, animated: false, scrollPosition: .middle)
        } else {
            return
        }
    }
    
    func toggleHint() {
        (self.tableView.cellForSelectedRow as? SentenceCompositionCell)?.toggleHint()
    }
}


// MARK: Conformance of UITableViewDataSource

extension CompositionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return question!.sentences.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(section + 1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sentence = question.sentences[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedSentenceCell")!
            
            cell.textLabel?.text = sentence.koreanText
            
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FullCompositionSentenceCell") as! SentenceCompositionCell
            
            sentence.associatedCell = cell
            sentence.associatedTextView = cell.enteredTextView
            sentence.associatedPlaceholderTextView = cell.placeholderTextView
            
            cell.enteredTextView.delegate = self
            cell.enteredTextView.inputView = self.designatedInputView
            cell.enteredTextView.inputAccessoryView = accessoryBar
            cell.enteredTextView.autocorrectionType = .no
            cell.answerTextView.isHidden = true
            
            cell.placeholderTextView.text = sentence.enteredEnglishPlaceholderText
            cell.enteredTextView.text = sentence.enteredEnglishText
            cell.answerTextView.text = sentence.englishText
            
            self.checkSpelling(sentence: sentence)
            self.updatePlaceholder(sentence: sentence)
            
            if sentence.enteredEnglishText == "" {
                cell.contentView.backgroundColor = nil
            } else {
                cell.contentView.backgroundColor = (sentence.enteredEnglishIsCorrect ? STColors.green : STColors.red)
            }
            
            return cell
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }
}

// MARK: Conformance of UITableViewDelegate

extension CompositionViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentSentence = question.sentences[indexPath.section]
        guard let sentence = self.currentSentence else {
            return
        }
        if indexPath.row == 1 {
            guard let cell = tableView.cellForRow(at: indexPath) as? SentenceCompositionCell else {
                return
            }
            if let wordpad = cell.enteredTextView.inputView as? STWordpad {
                let answer = sentence.englishWords[sentence.enteredEnglishWords.count]
                let choices = sentence.englishWords.removed(at: sentence.enteredEnglishWords.count).sampled(size: 2)
                wordpad.setup(answer: answer, choices: choices)
            }
            cell.contentView.backgroundColor = STColors.blue
            cell.enteredTextView.isUserInteractionEnabled = true
            cell.enteredTextView.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let sentence = question.sentences[indexPath.section]
        guard let cell = tableView.cellForRow(at: indexPath) as? SentenceCompositionCell else {
            return
        }
        cell.enteredTextView.resignFirstResponder()
        cell.enteredTextView.isUserInteractionEnabled = false
        cell.contentView.backgroundColor = sentence.enteredEnglishIsCorrect ? STColors.green : STColors.red
        self.currentSentence = nil
    }
}

// MARK: Conformance of UITextViewDelegate

extension CompositionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let sentence = self.question.sentences.associatedElement(of: textView) else {
            return
        }
        sentence.associatedCell?.contentView.backgroundColor = STColors.blue
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let sentence = self.question.sentences.associatedElement(of: textView) else {
            return
        }
        sentence.enteredEnglishText = textView.text
        sentence.associatedCell?.contentView.backgroundColor = sentence.enteredEnglishIsCorrect ? STColors.green: STColors.red
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let index = self.sentences.associatedIndex(of: textView) else {
            return true
        }
        let sentence = self.sentences[index]
        
        switch text {
        case "\t":
            moveToNextSentence()
            return false
        case "\n":
            if sentence.enteredEnglishIsCorrect {
                moveToNextSentence()
            } else {
                sentence.associatedCell?.contentView.backgroundColor = STColors.red
            }
            return false
        default:
            ()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustDynamicCellHeight()
        
        guard let sentence = self.sentences.associatedElement(of: textView) else {
            return
        }
        sentence.enteredEnglishText = textView.text
        
        checkSpelling(sentence: sentence)
        updatePlaceholder(sentence: sentence)
        sentence.associatedCell?.hideHint()
        sentence.associatedCell?.contentView.backgroundColor = STColors.blue
    }
    
    internal func adjustDynamicCellHeight() {
        let contentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    internal func checkSpelling(sentence: EBSBookSentence) {
        guard let textView = sentence.associatedTextView else {
            return
        }
        
        let selectedRange = textView.selectedRange
        
        var attributes = textView.typingAttributes
        attributes[NSForegroundColorAttributeName] = UIColor.red
        let attributedText = NSMutableAttributedString(string: textView.text, attributes: attributes)
        
        for index in common(sentence.englishText, textView.text) {
            let newAttributes = [NSForegroundColorAttributeName: UIColor.black]
            let range = NSMakeRange(index, 1)
            attributedText.addAttributes(newAttributes, range: range)
        }
        
        textView.attributedText = attributedText
        
        textView.selectedRange = selectedRange
    }
    
    internal func updatePlaceholder(sentence: EBSBookSentence) {
        guard let textView = sentence.associatedPlaceholderTextView else {
            return
        }
        
        var attributes = textView.typingAttributes
        attributes[NSForegroundColorAttributeName] = UIColor.black
        let attributedText = NSMutableAttributedString(string: sentence.enteredEnglishPlaceholderText, attributes: attributes)
        
        let newAttributes = [NSForegroundColorAttributeName: UIColor.clear]
        attributedText.addAttributes(newAttributes, range: (sentence.enteredEnglishText as NSString).fullRange)
        
        textView.attributedText = attributedText
        /*
        guard let cell = sentence.associatedCell else {
            return
        }
        
        var attributes = cell.placeholderTextView.typingAttributes
        attributes[NSForegroundColorAttributeName] = UIColor.black
        let attributedText = NSMutableAttributedString(string: sentence.enteredEnglishPlaceholderText, attributes: attributes)
        
        let newAttributes = [NSForegroundColorAttributeName: UIColor.clear]
        attributedText.addAttributes(newAttributes, range: (cell.enteredTextView.text as NSString).fullRange)
        
        cell.placeholderTextView.attributedText = attributedText*/
    }
}

extension CompositionViewController: STWordpadDelegate {
    
    func wordpad(_ wordpad: STWordpad, didSelectWord word: String, isCorrect: Bool) {
        guard let cell = self.tableView.cellForSelectedRow,
            let sentence = self.question.sentences.associatedElement(of: cell) else {
                return
        }
        if isCorrect {
            sentence.enteredEnglishWords.append(word)
            sentence.associatedTextView?.text = sentence.enteredEnglishText
            sentence.associatedTextView?.delegate?.textViewDidChange!(sentence.associatedTextView!) // FIXME: 강제 옵셔널 언래핑하지 않기
            if sentence.enteredEnglishWords.count == sentence.englishWords.count {
                self.moveToNextSentence()
            } else {
                let answer = sentence.englishWords[sentence.enteredEnglishWords.count]
                let choices = sentence.englishWords.removed(at: sentence.enteredEnglishWords.count).sampled(size: 2)
                wordpad.setup(answer: answer, choices: choices)
            }
        }
    }
}
