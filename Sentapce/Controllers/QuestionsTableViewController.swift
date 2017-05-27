import UIKit
import Alamofire
import AlamofireObjectMapper


class QuestionsTableViewController: UITableViewController {
    
    var lecture: EBSBookLecture?
    
    let baseURL = URL(string: "http://sentapce.api.stleam.com/ebsbooks")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = lecture?.type
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let questions = lecture?.questions else {
            return 0
        }
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell")!
        
        if let no = lecture?.questions[indexPath.row].no,
            let subject = lecture?.questions[indexPath.row].subject {
            cell.textLabel?.text = "\(no). \(subject)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
        let actions = [
            UIAlertAction(title: "Words", style: .default),
            UIAlertAction(title: "Listening", style: .default),
            UIAlertAction(title: "Suggesting-composition", style: .default) { sender in
                self.performSegue(withIdentifier: "ShowSuggestingComposition", sender: sender)
            },
            UIAlertAction(title: "Semi-composition", style: .default),
            UIAlertAction(title: "Translation", style: .default),
            UIAlertAction(title: "Full-composition", style: .default) { sender in
                self.performSegue(withIdentifier: "ShowFullComposition", sender: sender)
            },
            UIAlertAction(title: "Cancel", style: .cancel)
        ]
        for action in actions {
            alert.addAction(action)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "ShowSuggestingComposition":
            guard let destVC = segue.destination as? CompositionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedQuestion = lecture?.questions[indexPath.row]
            destVC.question = selectedQuestion
            destVC.compositionType = .suggesting
        case "ShowFullComposition":
            guard let destVC = segue.destination as? CompositionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedQuestion = lecture?.questions[indexPath.row]
            destVC.question = selectedQuestion
            destVC.compositionType = .full
        default:
            ()
        }
    }
}
