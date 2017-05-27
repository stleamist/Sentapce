import ObjectMapper
import UIKit
import os.log

class EBSBook: NSObject, NSCoding, Mappable {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("books")
    
    var isbn: Int!
    var title: String!
    var edition: String!
    var year: Int!
    var parts: [EBSBookPart]?
    
    required init?(map: Map) {}
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let jsonString = aDecoder.decodeObject(forKey: "jsonString") as? String else {
            return nil
        }
        self.init(JSONString: jsonString)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.toJSONString(), forKey: "jsonString")
    }
    
    func mapping(map: Map) {
        isbn <- map["isbn"]
        title <- map["title"]
        edition <- map["edition"]
        year <- map["year"]
        parts <- map["parts"]
    }
}

struct EBSBookPart: Mappable {
    var no: String!
    var title: String!
    var lectures: [EBSBookLecture]!
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        no <- map["no"]
        title <- map["title"]
        lectures <- map["lectures"]
    }
}

struct EBSBookLecture: Mappable {
    var no: String!
    var type: String!
    var questions: [EBSBookQuestion]!
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        no <- map["no"]
        type <- map["type"]
        questions <- map["questions"]
    }
}

struct EBSBookQuestion: Mappable {
    var no: String!
    var script: String!
    var from: String?
    var subject: String?
    var body: EBSBookBody!
    var terms: [EBSBookPairedText]?
    var words: [EBSBookPairedText]?
    
    var sentences: [EBSBookSentence] = []
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        no <- map["no"]
        script <- map["script"]
        from <- map["from"]
        subject <- map["subject"]
        body <- map["body"]
        terms <- map["terms"]
        words <- map["words"]
        
        sentences = EBSBookSentence.convert(from: self)
    }
}

struct EBSBookBody: Mappable {
    var english: [[String]]!
    var korean: [[String]]!
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        english <- map["english"]
        korean <- map["korean"]
    }
    
    var allEnglish: [String] {
        var array = [String]()
        for paragraph in english {
            array += paragraph
        }
        return array
    }
    
    var allKorean: [String] {
        var array = [String]()
        for paragraph in korean {
            array += paragraph
        }
        return array
    }
}

struct EBSBookPairedText: Mappable {
    var english: String!
    var korean: String!
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        english <- map["english"]
        korean <- map["korean"]
    }
}

class EBSBookSentence {
    init(englishText: String, koreanText: String) {
        self.englishText = englishText
        self.koreanText = koreanText
    }
    
    func clear() {
        self.enteredEnglishText = ""
        self.enteredKoreanText = ""
        self.enteredEnglishWords = []
    }
    
    static func convert(from question: EBSBookQuestion) -> [EBSBookSentence] {
        var sentences = [EBSBookSentence]()
        for paragraphIndex in 0..<min(question.body.english.count, question.body.korean.count) {
            for sentenceIndex in 0..<min(question.body.english[paragraphIndex].count, question.body.korean[paragraphIndex].count) {
                let sentence = EBSBookSentence(englishText: question.body.english[paragraphIndex][sentenceIndex], koreanText: question.body.korean[paragraphIndex][sentenceIndex])
                sentences.append(sentence)
            }
        }
        return sentences
    }
    
    var englishText: String
    var koreanText: String
    
    var englishPlaceholderText: String! {
        return try! NSRegularExpression(pattern: "[0-9A-Za-z]").stringByReplacingMatches(in: englishText, range: englishText.fullRange, withTemplate: "_")
    }
    var englishWords: [String] {
        return self.englishText.components(separatedBy: " ")
    }
    
    var enteredEnglishText: String = ""
    var enteredKoreanText: String = ""
    var enteredEnglishPlaceholderText: String {
        let replaceRange = (enteredEnglishText.characters.count >= englishPlaceholderText.characters.count) ? englishPlaceholderText.fullRange : enteredEnglishText.fullRange
        return englishPlaceholderText.replacingCharacters(in: replaceRange, with: enteredEnglishText)
    }
    var enteredEnglishWords: [String] = [] {
        didSet {
            self.enteredEnglishText = enteredEnglishWords.joined(separator: " ")
        }
    }
    
    var enteredEnglishIsCorrect: Bool {
        return enteredEnglishText == englishText
    }
    var enteredKoreanIsCorrect: Bool {
        return enteredKoreanText == koreanText // TODO: 유사도 반환
    }
    
    
    var associatedCell: SentenceCompositionCell?
    var associatedTextView: UITextView?
    var associatedPlaceholderTextView: UITextView?
}

extension Array where Element == EBSBookSentence {
    func associatedIndex(of cell: UITableViewCell) -> Int? {
        for (index, sentence) in self.enumerated() {
            if sentence.associatedCell == cell {
                return index
            }
        }
        return nil
    }
    func associatedIndex(of textView: UITextView) -> Int? {
        for (index, sentence) in self.enumerated() {
            if sentence.associatedTextView == textView {
                return index
            }
        }
        return nil
    }
    
    func associatedElement(of cell: UITableViewCell) -> EBSBookSentence? {
        if let index = self.associatedIndex(of: cell) {
            return self[index]
        } else {
            return nil
        }
    }
    func associatedElement(of textView: UITextView) -> EBSBookSentence? {
        if let index = self.associatedIndex(of: textView) {
            return self[index]
        } else {
            return nil
        }
    }
    func clear() {
        for sentence in self {
            sentence.clear()
        }
    }
}
