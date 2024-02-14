//
//  SearchResult.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 11/18/23.
//

import Foundation


class ResultArray: Codable, Equatable{
    
    static func == (lhs: ResultArray, rhs: ResultArray) -> Bool {
        // Check if all properties are equal
        return lhs.acronym == rhs.acronym &&
               lhs.name == rhs.name &&
               lhs.image_url == rhs.image_url
        // Add other properties here if needed
    }
    
    
    var acronym: String? = ""
    var name : String? = ""
    var image_url: String? = ""
    var players = [PlayerInfo]()
    var current_videogame = GameInfo()
    
    //var results = [SearchResult]()
    
    var description: String {
        return "\nResult - Acronym - \(acronym ?? "none"), Name - \(name ?? "none")"
    }
    
}

class PlayerInfo: Codable, Equatable{
    
    static func == (lhs: PlayerInfo, rhs: PlayerInfo) -> Bool {
        return lhs.age == rhs.age &&
               lhs.first_name == rhs.first_name &&
               lhs.last_name == rhs.last_name &&
               lhs.image_url == rhs.image_url &&
               lhs.name == rhs.name
        // Add other properties here if needed
    }
    
    var age: Int? = 0
    var first_name: String? = ""
    var last_name: String?  = ""
    var image_url: String?  = ""
    var name: String?  = ""
    
    var description: String {
        return "\nResult - First Name - \(first_name ?? "None"), Last Name - \(last_name ?? "None"), Age - \(age ?? 0)"
    }
}

class GameInfo: Codable {
    var name: String? = ""
    var slug: String? = ""
    
    
}


class SearchResult: Codable {
    var teamName: String = ""
    var gameName: String = ""
    
    var acronym: String = ""
    
    var description: String {
        return "\nResult - Acronym: \(acronym)"
    }
}



