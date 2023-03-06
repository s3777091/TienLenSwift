/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 21/08/2022
  Last modified: 29/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

struct Poker: View {
    @ObservedObject var Games = PokerController()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.presentationMode) var presentationMode: Binding
    
    @State var bill : Float = 0
    @State private var counter = 0
    @State var NowIsYourTurn : Bool = false
    @State var expandCard: Bool = false
    @State var showContent: Bool = false
    
    @State var showLottieAnimation: Bool = false
    
    @State var AddCoin : Bool = false
    
    @State var startAnimation = false
    
    
    private func WinGamePoker(){
        withAnimation(.easeInOut) {
            Games.FindWhoWin()
            expandCard = true

            Games.TotalRound = 0
            Games.TotalAmount = 0
        }
        
        //Reset Here
        for i in 0 ... Games.players.count - 1 {
            Games.players[i].checkingScore = 0
        }
    }
    
    private func CheckWinGame(){
        if Games.DealerCards.count == 5 {
            WinGamePoker()
        } else {
            //Draw Cards
            Games.NextRound()
        }
    }
    
    private func addMoney(MoreMoney: Int) {
        if (Games.players[3].UserMoney -  MoreMoney) < 0 {
            counter = -100 // print not enought money
        } else {
            if Games.MoneyUserNeedAdd > MoreMoney {
                print("BLUFF ONLY WORK FOR LARGER MONEY")
                counter = -100
            } else{
                AddCoin = true
                UserDefaults.standard.set(Games.players[3].UserMoney - MoreMoney, forKey: "UserMoney")
                Games.MoneyPluss += MoreMoney // User Block CPU
                Games.TotalAmount += MoreMoney
            }
        }
    }
    
    var body: some View {
        VStack{
            Spacer(minLength: 0)
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("Dealer")
                    .resizable()
                    .frame(width: 120, height: 150)
            }
            
            
            
            Text("\(Games.Messager)")
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                .background(Color("Color2"))
                .cornerRadius(36)
            
            Spacer(minLength: 0)
            
            ZStack{
                LinearGradient(gradient: .init(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom)
                    .frame(width: UIScreen.main.bounds.width - 90, height: 210)
            }.cornerRadius(25)
                .overlay{
                    DealerTable
                        .onChange(of: Games.gameOver) { _ in
                            timer.upstream.connect().cancel()
                            
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                expandCard = true
                                playSound(sound: "vitory", type: "mp3")
                            }
                        }
                }.overlay{
                    if AddCoin{
                        ResizableLottieView(fileName: "87117-coin") { view in
                            AddCoin = false
                        }
                        .scaleEffect(1.4)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                }
                .rotation3DEffect(.init(degrees: 30), axis: (x: 1.0, y: 0.0, z: 0.0))
            
            HStack{
                
                Text("You need to add: ")
                Text("\(Games.MoneyUserNeedAdd)").foregroundColor(.green).bold()
                
                Spacer()
                
                Text("Total Money: ")
                Text("\(Games.TotalAmount)").foregroundColor(.red).bold()
            }
            
            UserCards
            
            
            HStack{
                //Button Fold Cards
                //
                Button("FOLD") {
                    counter = 0 // reset couter
                    Games.MoneyUserNeedAdd = 0
                    Games.players[3].cards = []
                    
                    if Games.DealerCards.count == 5 {
                        WinGamePoker()
                    } else  {
                        Games.NextRound() //Draw Cards
                    }
                }
                .buttonStyle(GrowingButton())
                
                Spacer(minLength: 0)
                
                
                if Int(bill) == UserDefaults.standard.integer(forKey: "UserMoney") {
                    Button("All IN") {
                        counter = 0
                        addMoney(MoreMoney: Int(Games.players[3].UserMoney))
                        CheckWinGame()
                    }
                    .buttonStyle(GrowingButton())
                } else{
                    Button("CALL \(Int(bill))") {
                        counter = 0
                        addMoney(MoreMoney: Int(bill))
                        
                        Games.MoneyPluss = 0 // reset Money pluss
                        Games.MoneyUserNeedAdd = 0
                        CheckWinGame()
                    }
                    .buttonStyle(GrowingButton())
                }
                
                Spacer(minLength: 0)
                
                Button("CALL ANY") {
                    counter = 0
                    addMoney(MoreMoney: Int(Games.MoneyUserNeedAdd))
                    
                    Games.MoneyPluss = 0
                    Games.MoneyUserNeedAdd = 0
                    CheckWinGame()
                }
                .buttonStyle(GrowingButton())
            }.opacity(NowIsYourTurn ? 1 : 0)
            
            
            Spacer(minLength: 0)
            
        }.onChange(of: Games.activePlayer) { players in
            if !players.playerIsMe {
                Games.CheckingCpuHand(of: players)
            }
        }
        .onReceive(timer) { time in
            var nextPlayer = PlayerPorker()
            counter += 1
            if counter >= 2 {
                if Games.TotalRound == 1 {
                    // First Player with Random
                    nextPlayer = Games.findStartingPlayer()
                } else {
                    nextPlayer = Games.getNextPlayerFromCurrent()
                }
                
                Games.activatePlayer(nextPlayer)
                if nextPlayer.playerIsMe && !Games.players[3].cards.isEmpty {
                    counter = -100
                    NowIsYourTurn = true
                } else {
                    counter = 0
                    NowIsYourTurn = false
                    if Games.players[3].cards.isEmpty {
                        WinGamePoker()
                    }
                }
            }
        }
        .onAppear{
            Games.startGames()
            counter = -3
        }.overlay(content: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(showContent ? 1 : 0)
                .ignoresSafeArea()
        })
        .overlay(content: {
            GeometryReader{proxy in
                let size = proxy.size
                
                if expandCard{
                    // MARK: Since Size Varies
                    // By Padding 15 + 15 = 30
                    VitoryView(size: size)
                        .overlay(content: {
                            // MARK: Lottie Animation
                            if showLottieAnimation{
                                ResizableLottieView(fileName: "Party") { view in
                                    withAnimation(.easeInOut){
                                        showLottieAnimation = false
                                    }
                                }
                                .scaleEffect(1.4)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            }
                        })
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.35)){
                                showContent = true
                                showLottieAnimation = true
                            }
                        }
                }
            }
            .padding(30)
        })
        .overlay(alignment: .topTrailing, content: {
            // MARK: Close Button
            Button {
                withAnimation(.easeInOut(duration: 0.35)){
                    showContent = false
                    showLottieAnimation = false
                }
                
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)){
                    expandCard = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(15)
            }
            .opacity(showContent ? 1 : 0)
        })
        .preferredColorScheme(.dark)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color("BG"))
        
    }
    
    
    @ViewBuilder
    func VitoryView(size: CGSize)->some View{
        VStack(spacing: 18){
            Image("Trophy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Text("\(Games.WinnerName) win with cards")
                .font(.title)
                .foregroundColor(.red)
            
            
            HStack{
                ForEach(Games.DeckUserWin) { cars in
                    CardView(card: cars)
                }
            }
            
            Text("This is game demo for assignment 2")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(20)
        .frame(width: size.width * 0.9, height: size.width * 0.9)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
    }
    
}


struct Poker_Previews: PreviewProvider {
    static var previews: some View {
        Poker()
    }
}

extension Poker {
    var DealerTable : some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -50)]) {
            ForEach(Games.DealerCards) { cars in
                CardView(card: cars)
            }
        }
    }
    
    
    var UserCards: some View {
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -70)], alignment: .center) {
                ForEach(Games.UserCards.indices.reversed(),id: \.self) { cars in
                    CardView(card: Games.UserCards[cars])
                        .rotationEffect(.init(degrees: cars == 1 ? -20 : 10))
                    
                }
            }
            .padding(.horizontal, 120)
            .scaleEffect(0.9)
            
            Spacer(minLength: 0)
            
            MoneyView(player: $Games.players[3], totalAmount: $bill, CurrentTottal: Float(UserDefaults.standard.integer(forKey: "UserMoney")))
                .accentColor(.red)
                .frame(width: UIScreen.main.bounds.width - 80, height: 120)
            
        }.VCenter()
    }
}
