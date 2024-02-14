//
//  FavoriteTeamTableViewController.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 12/20/23.
//

import UIKit

class FavoriteTeamTableViewController: UITableViewController, favoriteTeamDelegate{
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
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
        
        
        refreshPage(refreshButton)
        
    }
    
    var favoriteTeams: [ResultArray] = []
    
    var valTeams: [ResultArray] = []
    
    var lolTeams: [ResultArray] = []
    
    @IBOutlet weak var refreshButton: UIButton!
    

    override func viewDidLoad() {
        
        
        
        tableView.reloadData()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadChecklistItems()
        
        
        super.viewDidLoad()
        
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        
        for teams in favoriteTeams {
            if teams.current_videogame.name == "Valorant" {
                valTeams.append(teams)
            }else {
                lolTeams.append(teams)
            }
        }
        
        print(valTeams.count)
        
        
    }
    
    func documentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    
    func dataFilePath() -> URL {
      return documentsDirectory().appendingPathComponent("FavoriteTeams.plist")
    }
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return valTeams.count
        }else {
            return lolTeams.count
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if favoriteTeams.count == 0 {
            
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            var result = ResultArray()
            
            if indexPath.section == 0 {
                result = valTeams[indexPath.row]
            }else {
                result = lolTeams[indexPath.row]
            }
            
            
            cell.gameName.text = result.acronym
            cell.teamName.text = result.name
            
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        loadChecklistItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if favoriteTeams.isEmpty{
            refreshPage(refreshButton)
        }else {
            
            
            
            var result = ResultArray()
            
            if indexPath.section == 0 {
                result = valTeams[indexPath.row]
            }else {
                result = lolTeams[indexPath.row]
            }
            
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let story = UIStoryboard(name: "Main", bundle: nil)
            
            let screen = story.instantiateViewController(identifier: "Team Info") as! TeamInfoViewController
            
            
            screen.teamInfo = result
            
            screen.delegate = self
            
            if let index = favoriteTeams.firstIndex(of: result){
                screen.isSelected = true
                print(index)
            }
            
            
            
            self.navigationController?.pushViewController(screen, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 15, y: 5, width: tableView.frame.width - 30, height: 30)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.black
        
        if section == 0 {
            titleLabel.text = "Valorant Teams"
        }else {
            titleLabel.text = "League of Legends Teams"
        }
        
      
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Set the desired height for your section headers
    }
   
    
    
    @IBAction func refreshPage(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1, animations: {
                    // Scale up the button when pressed
                    sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { (_) in
                    UIView.animate(withDuration: 0.1) {
                        // Scale back to original size
                        sender.transform = CGAffineTransform.identity
                    }
                }
        
        loadChecklistItems()
        
        valTeams.removeAll()
        lolTeams.removeAll()
        
        for teams in favoriteTeams {
            if teams.current_videogame.name == "Valorant" {
                valTeams.append(teams)
            }else {
                lolTeams.append(teams)
            }
        }
        
        tableView.reloadData()
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
    

}
