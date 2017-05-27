import Foundation
import UIKit
import GameplayKit

extension UITableView {
    func hasCellForRow(at indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        let numberOfSections = self.numberOfSections
        if (0..<numberOfSections).contains(section) {
            let numberOfRows = self.numberOfRows(inSection: section)
            
            if (0..<numberOfRows).contains(row) {
                return true
            }
        }
        
        return false
    }
    var cellForSelectedRow: UITableViewCell? {
        if let indexPath = self.indexPathForSelectedRow {
            return self.cellForRow(at: indexPath)
        }
        return nil
    }
    
    func selectRowByIntent(at index: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        if !self.allowsMultipleSelection, let indexPathsForSelectedRows = self.indexPathsForSelectedRows {
            for indexPath in indexPathsForSelectedRows {
                self.deselectRowByIntent(at: indexPath, animated: animated)
            }
        }
        guard let validIndex = index else {
            self.selectRow(at: index, animated: animated, scrollPosition: scrollPosition)
            return
        }
        if self.delegate?.tableView(_:willSelectRowAt:) != nil {
            self.delegate?.tableView!(self, willSelectRowAt: validIndex)
        }
        self.selectRow(at: index, animated: animated, scrollPosition: scrollPosition)
        if self.delegate?.tableView(_:didSelectRowAt:) != nil {
            self.delegate?.tableView!(self, didSelectRowAt: validIndex)
        }
    }
    
    func deselectRowByIntent(at index: IndexPath?, animated: Bool) {
        guard let validIndex = index else {
            return
        }
        if self.delegate?.tableView(_:willDeselectRowAt:) != nil {
            self.delegate?.tableView!(self, willDeselectRowAt: validIndex)
        }
        self.deselectRow(at: validIndex, animated: animated)
        if self.delegate?.tableView(_:didDeselectRowAt:) != nil {
            self.delegate?.tableView!(self, didDeselectRowAt: validIndex)
        }
    }
}

extension String.CharacterView {
    var array: [Character] {
        return Array(self)
    }
}
func common<T: Equatable>(_ array1: Array<T>, _ array2: Array<T>) -> [Int] {
    return zip(array1, array2).enumerated().filter() { $1.0 == $1.1 }.map{$0.0}
}
func common(_ string1: String, _ string2: String) -> [Int] {
    return common(string1.characters.array, string2.characters.array)
}

extension String {
    var fullRange: Range<String.Index> {
        return Range(uncheckedBounds: (lower: self.startIndex, upper: self.endIndex))
    }
}

extension NSString {
    var fullRange: NSRange {
        return NSMakeRange(0, self.length)
    }
}

extension Array {
    func shuffled() -> [Element] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self) as! [Element]
    }
    mutating func shuffle() {
        self = self.shuffled()
    }
    func sampled(size: Int) -> [Element] {
        return Array(self.shuffled()[0..<size])
    }
    mutating func sample(size: Int) {
        self = self.sampled(size: size)
    }
    func removed(at index: Int) -> [Element] {
        var array = self
        array.remove(at: index)
        return array
    }
}
extension Array where Element: Hashable {
    func randomized(withElementAt index: Int, count: Int) -> [Element] {
        var set = Set(self) // Remove duplicates
        set.remove(self[index]) // Remove index element
        var array = Array(Array(set).shuffled()[0..<count-1])
        array.append(self[index])
        return array.shuffled()
    }
}
