//
//  PickGameViewController.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 12/17/23.
//

import UIKit

protocol pickGameDelegate {
    func gameSelected(game: String)
}

class PickGameViewController: UITableViewController {
    
    var delegate: pickGameDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    return 2
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell",  for: indexPath)
        
        let label = cell.viewWithTag(55) as! UILabel
          
        let imageView = cell.viewWithTag(75) as! UIImageView
        
        if indexPath.row == 0 {
            label.text = "Valorant"
            imageView.image = UIImage(named: "ValorantLogo")
        }else {
            label.text = "League of Legends"
            imageView.image = UIImage(named: "League")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        if indexPath.row == 0 {
            delegate?.gameSelected(game: "valorant")
        }else {
            delegate?.gameSelected(game: "lol")
        }
        
        navigationController?.popViewController(animated: true)
        
    }

    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        
        var message = ""
        var title = ""
        
        if let cell = sender.superview?.superview as? UITableViewCell,
                   let indexPath = tableView.indexPath(for: cell) {
                   
                    let row = indexPath.row
            
            if row == 0 {
                title = "Valorant"
                message = "VALORANT is a free-to-play first-person tactical shooter video game being developed and published by Riot Games."
            }else {
                title = "League Of Legends"
                
                message = "League of Legends (LoL), commonly referred to as League, is a 2009 multiplayer online battle arena video game developed and published by Riot Games."
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            //action creates a button to dismiss the pop up
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            //adding the button to the pop-up
            alert.addAction(action)
            //present the popup
            present(alert, animated: true, completion: nil)
                    
                   
        }
        
        
        
        
        
    }
}
