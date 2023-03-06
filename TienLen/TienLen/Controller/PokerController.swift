/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 16/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import Foundation

class PokerController : ObservableObject {
    
    @Published private(set) var gameOver = false
    
    @Published var TotalRound : Int = 0
    @Published var MoneyPluss : Int = 0
    
    
    var players : [PlayerPorker] = []
    
    @Published var UserCards : Stack = []
    @Published var DealerCards : Stack = []
    
    //    @Published var AchievementTaskArray: [AchievementTask] = []
    @Published var Messager : String = ""
    
    @Published var WinnerName : String = ""
    @Published var DeckUserWin : Stack = []
    
    
    @Published var MoneyUserNeedAdd : Int = 0
    
    @Published private(set) var activePlayer = PlayerPorker()
    
    @Published var TotalAmount : Int = 0
    var deck = Deck()
    
    init() {
        let opponents = [
            PlayerPorker(playerName: "Andy", playerImage: "AndyImage"), // Style is Random by default
            PlayerPorker(playerName: "Alex", playerImage: "AlexImage"),
            PlayerPorker(playerName: "Black", playerImage: "BlackImage")
        ]
        
        players = opponents
        players.append(PlayerPorker(playerName: "User", playerImage: "AlexImage", UserMoney: UserDefaults.standard.integer(forKey: "UserMoney"), playerIsMe: true))
    }
    
    func startGames() {
        deck.reset()
        deck.createFullDeck()
        deck.shuffle()
        //Add cards for all player
        for i in 0 ... 3 {
            while players[i].cards.count < 2 {
                var card = deck.drawCard()
                if players[i].playerIsMe {
                    self.TotalAmount += 25
                    card.back = false
                }
                players[i].cards.append(card)
                
            }
            if players[i].playerIsMe {
                self.UserCards = players[i].cards
            }
        }
        
        
        while DealerCards.isEmpty {
            while DealerCards.count < 3 {
                var card = deck.drawCard()
                if card.back {
                    card.back = false
                }
                DealerCards.append(card)
            }
        }
        
        
        self.DealerCards = DealerCards
    }
    
    
    func GetCards(HandStack: Stack, DeskCards: Stack) -> Stack {
        let CardsCollection = [HandStack, DeskCards].joined()
        let flattenArray = Array(CardsCollection)
        return flattenArray
    }
    
    func findStartingPlayer() -> PlayerPorker {
        let randomInt = Int.random(in: 0..<4)
        return players[randomInt]
    }
    
    
    func NextRound() {
        var card = deck.drawCard()
        if card.back {
            card.back = false
        }
        DealerCards.append(card)
        self.DealerCards = DealerCards
    }
    
    func getNextPlayerFromCurrent() -> PlayerPorker {
        var nextActivePlayer = PlayerPorker()
        if let activePlayerIndex = players.firstIndex(where: { $0.activePlayer == true }) {
            let nextPlayerIndex = ((activePlayerIndex + 1) % players.count)
            nextActivePlayer = players[nextPlayerIndex]
            // Deactivate Current Active Player
            players[activePlayerIndex].activePlayer = false
            // Return Next Player
        }
        return nextActivePlayer
    }
    
    func activatePlayer(_ player: PlayerPorker) {
        self.TotalRound = TotalRound + 1
        if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {
            players[playerIndex].activePlayer = true
        }
        if let activePlayerIndex = players.firstIndex(where: { $0.activePlayer == true }) {
            self.activePlayer = players[activePlayerIndex]
        }
    }
    
    
    // Hand Score is function for prediction score can't get true value of cards
    func handScore(_ hand: Stack) -> Int {
        var score = 0
        for i in 0 ... hand.count - 1 {
            let suitScore = hand[i].suit.rawValue
            
            if HandTypePorker(hand) == .Pair  {
                score += 1000 + suitScore
            } else if HandTypePorker(hand) == .ThreeOfAKind{
                score += 3000 + suitScore
            } else if HandTypePorker(hand) ==  .Straight {
                score += 4000 + suitScore
            } else if HandTypePorker(hand) == .Flush{
                score += 5000 + suitScore
            } else if HandTypePorker(hand) == .FullHouse{
                score += 6000 + suitScore
            } else if HandTypePorker(hand) == .FourOfAKind{
                score += 7000 + suitScore
            } else if HandTypePorker(hand) == .StraightFlush{
                score += 8000 + suitScore
            } else if HandTypePorker(hand) == .RoyalFlush{
                score += 9000 + suitScore
            } else {
                score += ((hand[i].rank.rawValue + 3) * 100) + suitScore
            }
            score += (10000 * HandTypePorker(hand).rawValue)
        }
        return score
    }
    
    func FindWhoWin() {
        
        for i in 0 ... 3 {
            players[i].checkingScore += showHand(of: players[i])
        }
        
        WinnerName = ""
        DeckUserWin.removeAll()
        let player = players.sorted(by: { $0.checkingScore > $1.checkingScore }).first!
        if player.playerIsMe {
            UserDefaults.standard.set(TotalAmount + players[3].UserMoney, forKey: "UserMoney")
        } else {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "UserMoney") - TotalAmount, forKey: "UserMoney")
        }
        self.gameOver = true
        for i in 0 ... player.cards.count - 1  {
            var cards = player.cards[i]
            cards.back = false
            DeckUserWin.append(cards)
        }
        WinnerName = player.playerName
        
    }
    
    //Checking again
    func replayGame(){
        //Restart All Setup
        DispatchQueue.main.async {
            self.MoneyUserNeedAdd = 0
            self.TotalAmount = 0
            self.TotalRound = 0
            self.gameOver = false
        }
        
        UserCards.removeAll()
        DealerCards.removeAll()
        startGames()
    }
    
    func showHand(of player: PlayerPorker) -> Int{
        var score = 0
        
        
        let cardsDesk = GetCards(HandStack: player.cards, DeskCards: DealerCards)
        
        var pairExist = false,
            threeExist = false,
            fourExist = false,
            fullHouseExist = false,
            straightExist = false,
            flushExist = false
        
        var rankCount = [Rank : Int]()
        var suitCount = [Suit : Int]()
        
        for card in cardsDesk {
            if rankCount[card.rank] != nil {
                rankCount[card.rank]! += 1
            } else {
                rankCount[card.rank] = 1
            }
            if suitCount[card.suit] != nil {
                suitCount[card.suit]! += 1
            } else {
                suitCount[card.suit] = 1
            }
        }
        
        var cardsRankCount1 = 1
        var cardsRankCount2 = 1
        
        for rank in Rank.allCases {
            var thisRankCount = 0
            
            if rankCount[rank] != nil {
                thisRankCount = rankCount[rank]!
            } else {
                continue
            }
            
            // Check if there are ranks > 1. This is to detect pair, three, four, fullhouse
            if thisRankCount > cardsRankCount1 {
                if cardsRankCount1 != 1 {
                    cardsRankCount2 = cardsRankCount1
                }
                cardsRankCount1 = thisRankCount
            } else if thisRankCount > cardsRankCount2 {
                cardsRankCount2 = thisRankCount
            }
            
            pairExist = cardsRankCount1 > 1
            threeExist = cardsRankCount1 > 2
            fourExist = cardsRankCount1 > 3
            fullHouseExist = cardsRankCount1 > 2 && cardsRankCount2 > 1
            
            if straightExist {
                continue
            } else {
                straightExist = true // start off with true then check below
            }
            
            for i in 0 ... 4 {
                var rankRawValue = 1
                
                if rank <= Rank.Ten {
                    rankRawValue = rank.rawValue + i
                } else if rank >= Rank.Ace {
                    rankRawValue = (rank.rawValue + i) % 13
                    if rankRawValue == 0 {
                        rankRawValue = 13
                    }
                }
                
                if rankCount[Rank(rawValue: rankRawValue)!] != nil {
                    // if all 5 consecutive rank exist
                    straightExist = straightExist && rankCount[Rank(rawValue: rankRawValue)!]! > 0
                } else {
                    straightExist = false // if one of consecutive rank does not exist
                }
            }
        }
        
        // Check Flush
        for suit in Suit.allCases {
            var thisSuitCount = 0
            if suitCount[suit] != nil {
                thisSuitCount = suitCount[suit]!
            }
            flushExist = thisSuitCount > 5
        }
        
        
        // Caculate score
        for i in 0 ... cardsDesk.count - 1 {
            
            let suitScore = cardsDesk[i].suit.rawValue
            
            if pairExist {
                score += (1000 + suitScore)
            }
            
            if threeExist {
                score += (2000 + suitScore)
            }
            
            if fourExist || flushExist || straightExist || fullHouseExist {
                var mySavedPlaces = UserSessionManager.shared.AchievementList
                for card in  cardsDesk {
                    if (fullHouseExist && rankCount[card.rank]! > 1) {
                        
                        if player.playerIsMe && !mySavedPlaces[0].UnlockAchiment {
                            mySavedPlaces[0].UnlockAchiment = true
                            UserSessionManager.shared.AchievementList = mySavedPlaces
                        }
                        score += (3000 + suitScore)
                    } else if fourExist && rankCount[card.rank]! > 3 {
                        if player.playerIsMe && !mySavedPlaces[1].UnlockAchiment {
                            mySavedPlaces[1].UnlockAchiment = true
                            UserSessionManager.shared.AchievementList = mySavedPlaces
                        }
                        score += (4000 + suitScore)
                    } else if flushExist && suitCount[card.suit]! > 4 {
                        if player.playerIsMe && !mySavedPlaces[3].UnlockAchiment {
                            mySavedPlaces[3].UnlockAchiment = true
                            UserSessionManager.shared.AchievementList = mySavedPlaces
                        }
                        score += (5000 + suitScore)
                    } else if straightExist{
                        if player.playerIsMe && !mySavedPlaces[4].UnlockAchiment{
                            var mySavedPlaces = UserSessionManager.shared.AchievementList
                            mySavedPlaces[4].UnlockAchiment = true
                            UserSessionManager.shared.AchievementList = mySavedPlaces
                        }
                        score += (2500 + suitScore)
                    }
                }
            }
            
            score += suitScore
        }
        
        return score
        
    }
    
    
    // Need Animation
    func HumandBot(of playerCpu: PlayerPorker){
        Messager = ""
        if handScore(GetCards(HandStack: playerCpu.cards, DeskCards: DealerCards)) < handScore(GetCards(HandStack: UserCards, DeskCards: DealerCards)) {
            Messager = "\(playerCpu.playerName) Add \((200 + MoneyPluss))$"
            self.MoneyUserNeedAdd += (200 + MoneyPluss)
            self.TotalAmount += (200 + MoneyPluss)
        } else if MoneyPluss == 0 && handScore(GetCards(HandStack: playerCpu.cards, DeskCards: DealerCards)) > handScore(GetCards(HandStack: UserCards, DeskCards: DealerCards)) {
            Messager = "\(playerCpu.playerName) Add \((200 + MoneyPluss))$"
            self.MoneyUserNeedAdd += (200 + MoneyPluss)
            self.TotalAmount += (200 + MoneyPluss)
        } else if MoneyPluss > 0 && handScore(GetCards(HandStack: playerCpu.cards, DeskCards: DealerCards)) > handScore(GetCards(HandStack: UserCards, DeskCards: DealerCards)) {
            Messager = "\(playerCpu.playerName) Add \((200 + MoneyPluss))$"
            self.MoneyUserNeedAdd += (200 + MoneyPluss)
            self.TotalAmount += (200 + MoneyPluss)
        } else if let playerIndex = players.firstIndex(where: { $0.id == playerCpu.id }) {
            if handScore(GetCards(HandStack: playerCpu.cards, DeskCards: DealerCards)) < handScore(GetCards(HandStack: UserCards, DeskCards: DealerCards)) {
                Messager = "\(playerCpu.playerName) Fold cards"
                players[playerIndex].cards = []
            }
        } else {
            Messager = "\(playerCpu.playerName) Check cards"
        }
    }
    
    
    
    func CheckingCpuHand(of player: PlayerPorker) {
        Messager = ""
        var pairExist = false,
            threeExist = false,
            fourExist = false,
            fullHouseExist = false,
            straightExist = false,
            flushExist = false
        
        var rankCount = [Rank : Int]()
        var suitCount = [Suit : Int]()
        
        var playerCardsByRank : [Card] = []
        
        if DealerCards.count == 3 {
            //Start add Money in first Start And Check for first Cards
            //Only Check Cards In hand
            //Start Money
            self.TotalAmount = TotalAmount + 50
            playerCardsByRank = player.cards
        } else {
            playerCardsByRank = GetCards(HandStack: player.cards, DeskCards: DealerCards)
        }
        
        for card in playerCardsByRank {
            if rankCount[card.rank] != nil {
                rankCount[card.rank]! += 1
            } else {
                rankCount[card.rank] = 1
            }
            if suitCount[card.suit] != nil {
                suitCount[card.suit]! += 1
            } else {
                suitCount[card.suit] = 1
            }
        }
        
        var cardsRankCount1 = 1
        var cardsRankCount2 = 1
        
        for rank in Rank.allCases {
            var thisRankCount = 0
            
            if rankCount[rank] != nil {
                thisRankCount = rankCount[rank]!
            } else {
                continue
            }
            
            // Check if there are ranks > 1. This is to detect pair, three, four, fullhouse
            if thisRankCount > cardsRankCount1 {
                if cardsRankCount1 != 1 {
                    cardsRankCount2 = cardsRankCount1
                }
                cardsRankCount1 = thisRankCount
            } else if thisRankCount > cardsRankCount2 {
                cardsRankCount2 = thisRankCount
            }
            
            pairExist = cardsRankCount1 > 1
            threeExist = cardsRankCount1 > 2
            fourExist = cardsRankCount1 > 3
            fullHouseExist = cardsRankCount1 > 2 && cardsRankCount2 > 1
            
            if straightExist {
                continue
            } else {
                straightExist = true // start off with true then check below
            }
            
            for i in 0 ... 4 {
                var rankRawValue = 1
                
                if rank <= Rank.Ten {
                    rankRawValue = rank.rawValue + i
                } else if rank >= Rank.Ace {
                    rankRawValue = (rank.rawValue + i) % 13
                    if rankRawValue == 0 {
                        rankRawValue = 13
                    }
                }
                
                if rankCount[Rank(rawValue: rankRawValue)!] != nil { // if all 5 consecutive rank exist
                    straightExist = straightExist && rankCount[Rank(rawValue: rankRawValue)!]! > 0
                } else {
                    straightExist = false // if one of consecutive rank does not exist
                }
            }
        }
        
        // Check Flush
        for suit in Suit.allCases {
            var thisSuitCount = 0
            if suitCount[suit] != nil {
                thisSuitCount = suitCount[suit]!
            }
            flushExist = thisSuitCount > 5
        }
        
        
        HumandBot(of: player)
        Messager = ""
        
        
        if pairExist {
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 1 {
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                        self.TotalAmount += MoneyPluss
                    } else {
                        if MoneyUserNeedAdd == 100 || players[3].cards.isEmpty {
                            continue
                        } else {
                            Messager = "\(player.playerName) add 50$"
                            self.MoneyUserNeedAdd += 50 // Add 100 dola for each cards in here
                        }
                    }
                }
            }
        }
        
        if threeExist {
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 2 {
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                        self.TotalAmount += MoneyPluss // User Want Add Money
                    } else {
                        Messager = "\(player.playerName) add 66$"
                        self.TotalAmount += 200 / 3
                    }
                }
            }
        }
        
        if fourExist || flushExist || straightExist || fullHouseExist {
            for card in playerCardsByRank {
                if (fullHouseExist && rankCount[card.rank]! > 1) {
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                    } else {
                        Messager = "\(player.playerName) add 400$"
                        self.TotalAmount += 2000 / 5
                    }
                } else if fourExist && rankCount[card.rank]! > 3 {
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                        self.TotalAmount += MoneyPluss
                    } else {
                        Messager = "\(player.playerName) add 300$"
                        self.TotalAmount += 1500 / 5
                    }
                } else if flushExist && suitCount[card.suit]! > 4 {
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                        self.TotalAmount += MoneyPluss
                    }else {
                        Messager = "\(player.playerName) add 600$"
                        self.TotalAmount += 3000 / 5
                    }
                } else if straightExist{
                    if MoneyPluss > 0 {
                        Messager = "\(player.playerName) aggree with \(MoneyPluss)$"
                        self.TotalAmount += MoneyPluss
                    }else {
                        Messager = "\(player.playerName) add 200$"
                        self.TotalAmount += 1000 / 5
                    }
                }
            }
        }
        
    }
}
