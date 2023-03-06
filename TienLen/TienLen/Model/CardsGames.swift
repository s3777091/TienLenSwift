/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 10/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import Foundation
import SwiftUI


struct Card: Identifiable {
    var rank: Rank
    var suit: Suit
    var selected = false
    var back: Bool = true
    var filename: String {
        if !back {
            return "\(suit) \(rank)"
        } else {
            return "Back"
        }
    }
    var id = UUID()
}

struct Meme: Identifiable {
    var number: String
    var id = UUID()
    
    var fileMeme : String {
        return "MEME\(number)"
    }
}

typealias Stack = [Card]

extension Stack where Element == Card {
    func sortByRank() -> Self {
        var sortedHand = Stack()
        var remainingCards = self
        
        for _ in 1 ... remainingCards.count {
            var highestCardIndex = 0
            for (i, _) in remainingCards.enumerated() {
                if i + 1 < remainingCards.count {
                    if remainingCards[i + 1].rank >
                        remainingCards[highestCardIndex].rank ||
                        (remainingCards[i + 1].rank == remainingCards[highestCardIndex].rank &&
                         remainingCards[i + 1].suit > remainingCards[highestCardIndex].suit) {
                        highestCardIndex = i + 1
                    }
                }
            }
            
            let highestCard = remainingCards.remove(at: highestCardIndex)
            sortedHand.append(highestCard)
        }
        
        return sortedHand
    }
}


struct AchievementTask: Identifiable, Decodable, Encodable {
    var Achievement : String
    var AchievementImage : String
    var AchievementBackground: String
    var UnlockAchiment : Bool = false

    var id = UUID().uuidString
    
    
    
}

struct PlayerPorker: Identifiable, Equatable {
    var cards = Stack()
    var playerName = ""
    var playerImage = ""
    var checkingScore = 0
    var UserMoney = 0
    var playerIsMe = false
    var activePlayer = false
//    var playStyple : Int = 1
    var id = UUID().uuidString
    
    var offset: CGFloat = 0
    
    static func == (lhs: PlayerPorker, rhs: PlayerPorker) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Deck {
    private var cards = Stack()
    
    mutating func createFullDeck() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
    
    mutating func reset(){
        cards.removeAll()
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func drawCard() -> Card {
        return cards.removeLast()
    }
    
    func cardsRemaining() -> Int {
        return cards.count
    }
}


// MARK: ColorGrid Model
struct ColorGrid: Identifiable{
    var id = UUID().uuidString
    var ColorPurpose: String
    var icon : String
    var color: Color
    var counterScreen : Int
    // MARK: Animation Properties for Each Card
    var rotateCards: Bool = false
    var addToGrid: Bool = false
    var showText: Bool = false
    var removeFromView: Bool = false
}
