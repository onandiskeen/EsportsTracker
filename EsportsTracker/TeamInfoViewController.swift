//
//  TeamInfoViewController.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 11/19/23.
//

import UIKit
import AVFoundation

protocol favoriteTeamDelegate {
    func addTeam(teamInfo: ResultArray, isSelected: Bool)
}


class TeamInfoViewController: UIViewController {
    
    var player: AVAudioPlayer!
    
    var delegate: favoriteTeamDelegate?
    

    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
    
    @IBOutlet weak var favButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heading: UIView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var teamLogoImage: UIImageView!
    
    var teamInfo: ResultArray = ResultArray()

    var isSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //teamNameLabel.text = teamInfo.name
        
        if isSelected {
            favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let topPadding = window.safeAreaInsets.top  + 38 // Get the top safe area inset
            
            heading.frame = CGRect(x: 0, y: topPadding, width: window.frame.width, height: heading.frame.height)
            // Adjust other properties of heading as needed
        }

        
//        heading.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(heading)
       
        
//        NSLayoutConstraint.activate([
//                    heading.topAnchor.constraint(equalTo: view.topAnchor, constant: 60), // Position below the status bar or navigation bar
//                    heading.leadingAnchor.constraint(equalTo: view.leadingAnchor), // Align with the leading edge
//                    heading.trailingAnchor.constraint(equalTo: view.trailingAnchor), // Align with the trailing edge
//                    heading.heightAnchor.constraint(equalToConstant: 100) // Set the height of the view
//                    // Adjust the height value based on your requirements
//                ])
        
        
        
        tableView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0)
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        tableView.reloadData()
      
        teamNameLabel.text = teamInfo.name
      
        
        
        if let imageUrlString = teamInfo.image_url, let url = URL(string: imageUrlString) {
            let session = URLSession.shared

            let task = session.dataTask(with: url) { data, response, error in


                if let error = error {
                    print("Error loading image data: \(error)")
                    return
                }

                guard let data = data else {
                   // print("No image data received")
                    return
                }

                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.teamLogoImage.image = UIImage(data: data)
                }
            }
            task.resume()
        } else {
            //print("Invalid image URL")
            // Handle the case where the URL is nil or invalid
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func favButtonTapped(_ sender: UIButton) {
        
        delegate?.addTeam(teamInfo: teamInfo, isSelected: isSelected)
        
        
        
        if (isSelected){
            favButton.setImage(UIImage(systemName: "star"), for: .normal)
            isSelected = false
        }else {
            playSound()
            favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            isSelected = true
        }
        
        
    }
    
    func playSound() {
        let url = Bundle.main.url(forResource: "mixkit-achievement-bell-600", withExtension: "wav")
        player = try! AVAudioPlayer(contentsOf: url!)
        player!.play()
    }
}

extension TeamInfoViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if teamInfo.players.count == 0 {
            return 1
        }

        return teamInfo.players.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if teamInfo.players.count == 0 {
            print(indexPath.row)
            
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        let playerInfo = teamInfo.players[indexPath.row]
        
        cell.gameName.text = (playerInfo.first_name?.capitalizeFirstLetter() ?? "") + " " + (playerInfo.last_name?.capitalizeFirstLetter() ?? "")
        cell.teamName.text = playerInfo.name
        
        cell.isUserInteractionEnabled = false
        
        if let imageUrlString = playerInfo.image_url, let url = URL(string: imageUrlString) {
            let session = URLSession.shared

            let task = session.dataTask(with: url) { data, response, error in


                if let error = error {
                    print("Error loading image data: \(error)")
                    return
                }

                guard let data = data else {
                   // print("No image data received")
                    return
                }

                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    cell.teamLogo.image = UIImage(data: data)
                }
            }
            task.resume()
        } else {
            //print("Invalid image URL")
            // Handle the case where the URL is nil or invalid
        }
        
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
        
    
    
}

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

