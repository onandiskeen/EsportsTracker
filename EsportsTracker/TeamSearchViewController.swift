//
//  ViewController.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 11/11/23.
//

import UIKit




class TeamSearchViewController: UIViewController, pickGameDelegate, favoriteTeamDelegate{
    
    var favoriteTeams: [ResultArray] = []
    
    var pageNum = 1
    
    func addTeam(teamInfo: ResultArray, isSelected: Bool) {
        
        loadChecklistItems()
        
        if(!isSelected){
            favoriteTeams.append(teamInfo)
        } else {
            if let index = favoriteTeams.firstIndex(of: teamInfo){
                favoriteTeams.remove(at: index)
            }
        }
        
        saveChecklistItems()
        
    }
    
    
    var gameSelected = "valorant"
    

    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var hasSearched = false
    
    var searchResults : [ResultArray] = [ResultArray()]
    
    func gameSelected(game: String) {
        
        gameSelected = game
        
        searchBar.text = ""
        
        
        if gameSelected == "valorant" {
            searchBar.placeholder = "Search Valorant Teams"

            
        }else {
            searchBar.placeholder = "Search League of Legends Teams"
        }
        
        
        searchBarSearchButtonClicked(searchBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("Documents folder is \(documentsDirectory())")
          print("Data file path is \(dataFilePath())")
        
        loadChecklistItems()
        
        
        
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.text = ""
        
        searchBarSearchButtonClicked(searchBar)
 
    }
    
    func PandaScoreURL(searchText: String, pageNum: String) -> URL {
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let token = "R3StE305GYgFucbq0ukvTeqY3a2EJfMh6FqVo3N8A6aeG3ap4fY"
        
        let urlString = String(format: "https://api.pandascore.co/%@/teams?filter[name]=%@&page=%@&per_page=100&token=%@" ,gameSelected,encodedText, pageNum,token)
        
        let url = URL(string: urlString)
        
        return url!
    }
    
    func performPandaScoreRequest(with url: URL, completion: @escaping (Data?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Download Error: \(error.localizedDescription)")
                // Handle the error and show network error if needed
                DispatchQueue.main.async {
                    // Assuming `showNetworkError()` displays a network error to the user
                    self.showNetworkError()
                    completion(nil)
                }
                return
            }
            
            // Data received successfully
            completion(data)
        }
        task.resume()
    }
    
    func performPandaScoreRequests(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    
    func parseData(data: Data) -> [ResultArray] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode([ResultArray].self, from: data)
            return result
        } catch {
            print("JSON Error: '\(error)'")
            return []
        }
    }
    

    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the eSports Data. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnTapped(_ sender: Any) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        
        let screen = story.instantiateViewController(identifier: "Games") as! PickGameViewController
        
        screen.delegate = self
    
        
        self.navigationController?.pushViewController(screen, animated: true)
        
    }
    


}

extension TeamSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    //determines when you scroll to the bottom on the table
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            print("bottom")
            
            pageNum = pageNum + 1
            
            let url = PandaScoreURL(searchText: searchBar.text!, pageNum: String(pageNum))
            
            performPandaScoreRequest(with: url) { [self] data in
                if let data = data {
                    let results = parseData(data: data)
                    
                
                    //print(results)
                    DispatchQueue.main.async {
                        self.searchResults += results
                        
                        
                        self.tableView.reloadData()
                    }
                } else {
                    // Handle the case where data is nil
                }
            }
        }
    }
    
    func loadMore(){
        // write code to load more cells on the page
    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasSearched == false {
            return 50
        } else if searchResults.count == 0 {
            return 1
        }
            
        return searchResults.count
    }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if searchResults.count == 0 {
                
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
                let result = searchResults[indexPath.row]
                cell.gameName.text = result.acronym
                cell.teamName.text = result.name
                
                cell.backgroundColor = UIColor.clear
                
                // Cancel any ongoing image download task for the cell (if exists)
                cell.task?.cancel()
                
                if let imageUrlString = result.image_url, let url = URL(string: imageUrlString) {
                    let session = URLSession.shared
                    let task = session.dataTask(with: url) { data, response, error in
                        if let error = error {
                            // Handle error
                            print("Error loading image data: \(error)")
                            DispatchQueue.main.async {
                                // If there's an error, set the placeholder image
                                cell.teamLogo.image = UIImage(systemName: "photo") // Change "photo" to the desired system symbol
                            }
                            return
                        }
                        
                        guard let data = data else {
                            // Handle no data received
                            print("No image data received")
                            DispatchQueue.main.async {
                                // If there's no data, set the placeholder image
                                cell.teamLogo.image = UIImage(systemName: "photo")
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            // Create Image and Update Image View
                            cell.teamLogo.image = UIImage(data: data)
                        }
                    }
                    
                    // Store the task in the cell to manage it
                    cell.task = task
                    
                    task.resume()
                } else {
                    // Handle invalid image URL
                    print("Invalid image URL")
                    // If the URL is invalid, set the placeholder image
                    cell.teamLogo.image = UIImage(systemName: "photo")
                }

                return cell
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            loadChecklistItems()
            
            let result = searchResults[indexPath.row]
            
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let story = UIStoryboard(name: "Main", bundle: nil)
            
            let screen = story.instantiateViewController(identifier: "Team Info") as! TeamInfoViewController
             
            screen.teamInfo = result
            
            if let index = favoriteTeams.firstIndex(of: result){
                screen.isSelected = true
            }
            
            screen.delegate = self

            
            self.navigationController?.pushViewController(screen, animated: true)
            
            
        }
        
        func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            if searchResults.count == 0 {
                return nil
            }
            
            return indexPath
        }
        
        
}

    
extension TeamSearchViewController: UISearchBarDelegate{
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        searchBar.resignFirstResponder()
        
        //searchResults = [ResultArray()]
        
        hasSearched = true
        

        
        let url = PandaScoreURL(searchText: searchBar.text!, pageNum: "")
        
        performPandaScoreRequest(with: url) { [self] data in
            if let data = data {
                let results = parseData(data: data)
                
            
                //print(results)
                DispatchQueue.main.async {
                    self.searchResults = results
                    
                    
                    self.tableView.reloadData()
                }
            } else {
                // Handle the case where data is nil
            }
        }
        
        
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension TeamSearchViewController {
    func documentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    
    func dataFilePath() -> URL {
      return
    documentsDirectory().appendingPathComponent("FavoriteTeams.plist")
    }
    
    func saveChecklistItems() {
      // 1
      let encoder = PropertyListEncoder()
      // 2
      do {
    // 3
        let data = try encoder.encode(favoriteTeams)
        // 4
        try data.write(
          to: dataFilePath(),
          options: Data.WritingOptions.atomic)
        // 5
    } catch { // 6
        print("Error encoding item array: \(error.localizedDescription)")
    } }
    
    func loadChecklistItems() {
      // 1
      let path = dataFilePath()
      // 2
      if let data = try? Data(contentsOf: path) {
    // 3
        let decoder = PropertyListDecoder()
        do {
    // 4
          favoriteTeams = try decoder.decode(
            [ResultArray].self,
            from: data)
        } catch {
          print("Error decoding item array: \(error.localizedDescription)")
    } }
    }
}
    

