import UIKit
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON


class LecturesTableViewController: UITableViewController {
    
    var book: EBSBook?
    
    let baseURL = URL(string: "http://sentapce.api.stleam.com/ebsbooks")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        /*
        
        if let validBook = book {
            self.navigationItem.title = validBook.edition
            
            let url = baseURL.appendingPathComponent(String(validBook.isbn))
            Alamofire.request(url).responseObject { (response: DataResponse<EBSBook>) in
                self.book = response.result.value
                self.tableView.reloadData()
            }
        }*/
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let parts = book?.parts else {
            return 0
        }
        return parts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return book?.parts?[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let part = book?.parts?[section] else {
            return 0
        }
        return part.lectures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LectureCell")!
        
        if let no = book?.parts?[indexPath.section].lectures[indexPath.row].no,
            let type = book?.parts?[indexPath.section].lectures[indexPath.row].type {
            cell.textLabel?.text = "\(no). \(type)"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "ShowQuestions":
            guard let questionsTableViewController = segue.destination as? QuestionsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedLectureCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedLectureCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedLecture = book?.parts?[indexPath.section].lectures[indexPath.row]
            questionsTableViewController.lecture = selectedLecture
        default:
            ()
        }
    }
}
