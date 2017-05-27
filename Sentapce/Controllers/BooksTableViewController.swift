import UIKit
import Alamofire
import AlamofireObjectMapper
import SystemConfiguration
import os.log


class BooksTableViewController: UITableViewController {
    
    var books = [EBSBook]()
    
    let baseURL = URL(string: "http://sentapce.api.stleam.com/ebsbooks")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInternetAvailable() {
            Alamofire.request(baseURL).responseArray { (response: DataResponse<[EBSBook]>) in
                if let array = response.result.value {
                    self.books = array
                    self.saveBooks()
                    self.tableView.reloadData()
                }
            }
        } else {
            if let savedBooks = loadBooks() {
                books += savedBooks
            }
        }
    }
    
    private func saveBooks() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(books, toFile: EBSBook.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadBooks() -> [EBSBook]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: EBSBook.ArchiveURL.path) as? [EBSBook]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell")!
        
        cell.textLabel?.text = books[indexPath.row].edition
        cell.detailTextLabel?.text = String(books[indexPath.row].year)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "ShowLectures":
            guard let lecturesTableViewController = segue.destination as? LecturesTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBook = books[indexPath.row]
            lecturesTableViewController.book = selectedBook
        default:
            ()
        }
    }
}

func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}
