/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 28/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/
import SwiftUI

struct Achievement: View {
    
    // Current Index...
    @State var currentIndex: Int = 0
    
    let myAchimentList = UserSessionManager.shared.AchievementList
    
    
    @Environment(\.presentationMode) var presentationMode: Binding
    @Binding var NameAvatar : String
    
    var body: some View {
        ZStack{
            // background Tab View...
            TabView(selection: $currentIndex) {
                ForEach(myAchimentList.indices, id: \.self){ index in
                    GeometryReader{ proxy in
                        Image(myAchimentList[index].AchievementBackground)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width,height: proxy.size.height)
                            .cornerRadius(1)
                            .opacity(myAchimentList[index].UnlockAchiment ? 1 : 0.3)
                    }
                    .ignoresSafeArea()
                    .offset(y: -100)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentIndex)
            
            
            .overlay(
                LinearGradient(colors: [
                    
                    Color.clear,
                    Color.black.opacity(0.2),
                    Color.white.opacity(0.4),
                    Color.white,
                    Color.white,
                    Color.white,
                    
                ], startPoint: .top, endPoint: .bottom)
                .background(
                    
                    Color.black
                        .opacity(0.15)
                )
            )
            .ignoresSafeArea()
            
            // Posts....
            SnapCarousel(spacing: UIScreen.main.bounds.height < 750 ? 15 : 20,trailingSpace: UIScreen.main.bounds.height < 750 ? 100 : 150,index: $currentIndex, items: myAchimentList) {ach in
                VStack{
                    CardView(ach: ach)
                    
                    if ach.UnlockAchiment {
                        Button("Change this avatar") {
                            NameAvatar = ""
                            NameAvatar = ach.AchievementImage
                        }
                        .buttonStyle(GrowingButton())
                    }
                    
                    
                }

            }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .offset(y:  UIScreen.main.bounds.height / 3.5)
            
            
            
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("BACK")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }.vBottom()
        }

        
    }
    
    
    @ViewBuilder
    func CardView(ach: AchievementTask)->some View{
        
        VStack(spacing: 10){
            
            // Image...
            GeometryReader{proxy in
                
                Image(ach.AchievementBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .cornerRadius(25)
                    .overlay{
                        if !ach.UnlockAchiment {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .overlay{
                                    Text("Play more to unlock")
                                }
                            
                        }
                    }
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(25)
            .frame(height: UIScreen.main.bounds.height / 2.5)
            .padding(.bottom,15)
            
            
            // Movie Data...
            Text(ach.Achievement)
                .font(.title2.bold())
                .foregroundColor(.black)
            
            
            HStack{
                Image(ach.AchievementImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                
                Spacer(minLength: 0)
                
                Text("Unlock Achievement to earn nice Icon for user avatar")
                    .font(.caption)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.top,8)
                    .padding(.horizontal,20)
                    .foregroundColor(.black)
            }
        }
    }
}

extension UserDefaults {
    func getUserMoney(){
        UserDefaults.standard.integer(forKey: "UserMoney")
    }
    
    func setUserMoney(money: Int){
        UserDefaults.standard.integer(forKey: "UserMoney")
    }
    
}

class UserSessionManager{
    // MARK:- Properties
    
    public static var shared = UserSessionManager()
    
    var AchievementList: [AchievementTask]{
        get {
            guard let data = UserDefaults.standard.data(forKey: "ListAchivement") else { return [] }
            return (try? JSONDecoder().decode([AchievementTask].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: "ListAchivement")
        }
    }
    
    // MARK:- Init
    
    private init(){}
}
