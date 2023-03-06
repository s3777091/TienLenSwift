/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 26/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

struct MainView: View {
    
    
    @State var avatarName : String = ""
    
    init(){
//        var listArray: [AchievementTask] = []
//
//        let AchievenmentList: [AchievementTask] = [
//            AchievementTask(Achievement: "Four Dragon", AchievementImage: "dragon", AchievementBackground: "than bai", UnlockAchiment: false), //0
//            AchievementTask(Achievement: "Flush king", AchievementImage: "king", AchievementBackground: "king of poker",UnlockAchiment: false), // 1
//            AchievementTask(Achievement: "Poker", AchievementImage: "risk", AchievementBackground: "Joker",UnlockAchiment: true), // 2
//            AchievementTask(Achievement: "Straight lion", AchievementImage: "lion",AchievementBackground: "lion in stage", UnlockAchiment: false), // 3
//            AchievementTask(Achievement: "FullHouse", AchievementImage: "crown", AchievementBackground: "legend never die", UnlockAchiment: false) // 4
//        ]
//
//        listArray.append(contentsOf: AchievenmentList)
//
//        UserSessionManager.shared.AchievementList = listArray
        
    }
    
    // MARK: Sample Colors
    @State var colors: [ColorGrid] = [
        ColorGrid(ColorPurpose: "Play Game", icon: "gamecontroller.fill", color: Color("Color5"), counterScreen : 1),
        ColorGrid(ColorPurpose: "Achievement", icon: "paperplane.fill", color: Color("Color2"), counterScreen  : 2),
        ColorGrid(ColorPurpose: "Add Money", icon: "dollarsign.circle.fill", color: Color("Color3"), counterScreen: 3),
        ColorGrid(ColorPurpose: "Rules",icon: "flag.2.crossed.fill", color: Color("Color4"), counterScreen: 4),
    ]
    
    private var ListMeme : [Meme] = [
        Meme(number: "1"),
        Meme(number: "2"),
        Meme(number: "3"),
        Meme(number: "4"),
        Meme(number: "5"),
    ]
    
    @State private var currentPage = 0
    
    // MARK: Animation Properties
    // Instead of making each boolean for separate animation making it as a array to avoid multiple lines of code.
    @State var animations: [Bool] = Array(repeating: false, count: 10)
    
    // MatchedGeometry Namespace
    @Namespace var animation
    
    // Card Color
    @State var selectedColor: Color = Color("Color2")
    
    let myAchimentList = UserSessionManager.shared.AchievementList
    
    var body: some View {
        NavigationView{
            VStack{
                
                HStack{
                    Image(avatarName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    
                        .hLeading()
                    
                    
                    Image("expensive")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    
                    Text("\(UserDefaults.standard.integer(forKey: "UserMoney"))$")
                }
                .padding([.horizontal,.top])
                .padding(.bottom,5)
                
                
                // MARK: Using Geometry Reader for Setting Offset
                GeometryReader{proxy in
                    
                    let maxY = proxy.frame(in: .global).maxY
                    
                    PaperViewTab()
                    
                    // MARK: 3D Rotation
                        .rotation3DEffect(.init(degrees: animations[0] ? 0 : -270), axis: (x: 1, y: 0, z: 0), anchor: .center)
                        .offset(y: animations[0] ? 0 : -maxY)
                    
                }
                .frame(height: 250)
                
                GeometryReader{proxy in
                    
                    ZStack{
                        
                        Color.black
                            .clipShape(CustomCorner(corners: [.topLeft,.topRight], radius: 40))
                            .frame(height: animations[2] ? nil : 0)
                            .vBottom()
                        
                        ZStack{
                            // MARK: Intial Grid View
                            ForEach(colors){colorGrid in
                                
                                // Hiding the source Onces
                                if !colorGrid.removeFromView{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorGrid.color)
                                        .matchedGeometryEffect(id: colorGrid.id, in: animation)
                                        .frame(width: 150, height: animations[3] ? 60 : 150)
                                    // MARK: Rotating Cards
                                        .rotationEffect(.init(degrees: colorGrid.rotateCards ? 180 : 0))
                                }
                            }
                        }
                        // MARK: Applying Opacity with Scale Animation
                        // To Avoid this Creating a BG OVerlay and hiding it
                        // So that it will look like the whole stack is Applying Opacity Animation
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("BG"))
                                .frame(width: 150, height: animations[3] ? 60 : 150)
                                .opacity(animations[3] ? 0 : 1)
                        )
                        // Scale Effect
                        .scaleEffect(animations[3] ? 1 : 2.3)
                    }
                    .hCenter()
                    .VCenter()
                    .clipped()
                    
                    // MARK: ScrollView with Color Grids
                    ScrollView(.vertical, showsIndicators: false) {
                        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(colors){colorGrid in
                                
                                GridCardView(colorGrid: colorGrid)
                            }
                        }
                        .padding(.top,40)
                    }
                    .cornerRadius(40)
                }
                .padding(.top)
                
            }
            
        }
        .vTop()
        .hCenter()
        .ignoresSafeArea(.all)
        .onAppear(perform: animateScreen)
        .onAppear{
            avatarName = "kichodien"
        }
    }
    
    
    // MARK: Grid Card View
    @ViewBuilder
    func GridCardView(colorGrid: ColorGrid)->some View{
        VStack{
            if colorGrid.addToGrid{
                // Displaying With Matched Geometry Effect
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorGrid.color)
                    .frame(width: 150, height: 60)
                    .matchedGeometryEffect(id: colorGrid.id, in: animation)
                // When Animated Grid Card is Displayed Displaying the Color Text
                    .onAppear {
                        if let index = colors.firstIndex(where: { color in
                            return color.id == colorGrid.id
                        }){
                            withAnimation{
                                colors[index].showText = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                withAnimation{
                                    colors[index].removeFromView = true
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation{
                            selectedColor = colorGrid.color
                        }
                    }
            }
            else{
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 150, height: 60)
            }
            
            
        }.overlay {
            HStack{
                NavigationLink {
                    
                    switch colorGrid.counterScreen {
                    case 1:
                        Poker()
                    case 2:
                        Achievement(NameAvatar: $avatarName)
                    case 3:
                        AddMoney()
                    case 4:
                        Rules()
                    default:
                        EmptyView()
                    }
                } label: {
                    Image(systemName: colorGrid.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .hLeading()
                        .padding([.horizontal,.top])
                        .opacity(colorGrid.showText ? 1 : 0)
                    
                    Text(colorGrid.ColorPurpose)
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .hLeading()
                        .padding([.horizontal,.top])
                        .opacity(colorGrid.showText ? 1 : 0)
                }.buttonStyle(PlainButtonStyle())
            }.VCenter()
        }
    }
    
    func animateScreen(){
        
        // MARK: Animating Screen
        // First Animation of Credit Card
        // Delaying First Animation after the second Animation
        withAnimation(.interactiveSpring(response: 1.3, dampingFraction: 0.7, blendDuration: 0.7).delay(0.2)){
            animations[0] = true
        }
        
        // Second Animating the Hstack with View All Button
        withAnimation(.easeInOut(duration: 0.7)){
            animations[1] = true
        }
        
        // Third Animation Making The Bottom to Slide up eventually
        withAnimation(.interactiveSpring(response: 1.3, dampingFraction: 0.7, blendDuration: 0.7).delay(0.2)){
            animations[2] = true
        }
        
        // Third Animation Applying Opacity with scale animation for Stack Grid Colors
        withAnimation(.easeInOut(duration: 0.8)){
            animations[3] = true
        }
        
        // Final Grid Forming Animation
        for index in colors.indices{
            
            // Animating after the opacity animation has Finished its job
            // Rotating One card another with a time delay of 0.1sec
            let delay: Double = (0.9 + (Double(index) * 0.1))
            
            // Last card is rotating first since we're putting in ZStack
            // To avoid this recalulate index from back
            let backIndex = ((colors.count - 1) - index)
            
            withAnimation(.easeInOut.delay(delay)){
                colors[backIndex].rotateCards = true
            }
            
            // After rotation adding it to grid view one after anothre
            // Since .delay() will not work on if...else
            // So using DispathcQueue delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation{
                    colors[backIndex].addToGrid = true
                }
            }
        }
    }
    
    
    // MARK: Animated PagerView
    @ViewBuilder
    func PaperViewTab()->some View{
        
        PagerView(pageCount: 5, currentIndex: $currentPage) {
            ForEach(ListMeme) { im in
                Image(im.fileMeme).resizable()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
