//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import Kingfisher
import SafariServices
import WebKit
import PopupView

struct UserProfileView: View {
    @ObservedObject private var screen1VM = screen1ViewModel()
    @State private var showWebpage = false
    @Binding var tab: Tab
    @State var timeFrame = "daily"
    @StateObject private var prizesVM = prizesViewModel()

    var body: some View {
        VStack(spacing: 12) {

            ProfileHeaderView(screen1VM: screen1VM, timeFrame: $timeFrame)
                .padding(.top, 10)
                .padding(.horizontal)
           
            countDown(prizesVM: prizesVM, timeFrame: $timeFrame)

            VStack {
             yourGroups(screen1VM: screen1VM, tab: $tab)
                    .padding(.top, 20)

                weeklyGlobalLeaders(screen1VM: screen1VM, timeFrame: $timeFrame)
                    .padding(.horizontal)
                
                Spacer()
            }.padding(.bottom,45)

        }
        .sheet(isPresented: $showWebpage) {
            if screen1VM.updateURL != "" {
                SafariView(url: URL(string: screen1VM.updateURL)!)
            }
        }
        .background(K.finalColor.backgroundBlue)
        .onAppear() {
            screen1VM.forceUpdate () {
                if screen1VM.updateURL != ""{
                    AppUtility.shared.showCustomAlert(alertType: .none, message: "There is a new, necessary update. Sorry we know this is annoying...", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: nil) { action in
                        if action == AlertButtonAction.okButton{
                            showWebpage.toggle()
                        }
                        
                    }
                }
            }
            if StaticUserData.shared.currentUser.id! != "" && StaticUserData.shared.currentUser.id! != nil {
                screen1VM.setUserFCM(userID: StaticUserData.shared.currentUser.id!) {}
            }

        }.padding(.top, 35)
    }
}



struct ScreenA: View {
    var body: some View {
        Text("helloA")
    }
}

struct ScreenB: View {
    var body: some View {
        Text("helloB")
    }
}

struct testView: View {
    @State private var currentScreen: Int = 0 // 0 for Screen A, 1 for Screen B
    @State private var dragTranslation: CGFloat = 0


    var body: some View {
        VStack {
            // Title and Button views
            HStack {
                Button("Screen A") {
                    withAnimation {
                        currentScreen = 0
                    }
                }
                Button("Screen B") {
                    withAnimation {
                        currentScreen = 1
                    }
                }
            }.overlay(
                Rectangle()
                    .frame(width: 50, height: 10)
                    .offset(x: (currentScreen == 0 ? 0 : 50) + dragTranslation / 2, y: 0)
                    .animation(.linear, value: dragTranslation)
                    .animation(.linear, value: currentScreen)
            , alignment: .bottom)

            // Screen sliding view
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ScreenA()
                        .frame(width: geometry.size.width)
                    ScreenB()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(currentScreen) * geometry.size.width, y: 0)
                .animation(.easeInOut, value: currentScreen)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            dragTranslation = gesture.translation.width
                        }
                        .onEnded { gesture in
                            dragTranslation = 0
                            if gesture.translation.width > 50 {
                                // Swiped to the right
                                withAnimation {
                                    currentScreen = max(0, currentScreen - 1)
                                }
                            } else if gesture.translation.width < -50 {
                                // Swiped to the left
                                withAnimation {
                                    currentScreen = min(1, currentScreen + 1)
                                }
                            }
                        }
                )

            }
        }
    }
}





struct weeklyGlobalLeaders: View {
    @StateObject var screen1VM: screen1ViewModel
    @Binding var timeFrame: String
    
    var body: some View {
        ZStack() {
            VStack(alignment: .center) {
            
                Text("Daily Leaders")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24).weight(.medium))
                    .foregroundColor(.white)
                if timeFrame == "daily" {
                    if screen1VM.canFetchDailyRankedTickets {
                        ForEach(0..<min(3, StaticUserData.shared.dailyRankedTickets.count), id: \.self) { index in
                            let ticket = StaticUserData.shared.dailyRankedTickets[index]
                            
                            BetCard(
                                ticket: ticket,
                                rank: ticket.rank,
                                ownCard: false,
                                currentWeek: true,
                                homePage: true
                            ).padding(EdgeInsets(top: 0, leading: 8, bottom: 5, trailing: 8))
                        }
                    }
                }
//                } else if timeFrame == "weekly" {
//                    if screen1VM.canFetchWeeklyRankedTickets {
//                        
//                        ForEach(0..<min(3, StaticUserData.shared.weeklyRankedTickets.count), id: \.self) { index in
//                            let ticket = StaticUserData.shared.weeklyRankedTickets[index]
//                            
//                            BetCard(
//                                ticket: ticket,
//                                rank: ticket.rank,
//                                ownCard: false,
//                                currentWeek: true,
//                                homePage: true
//                            ).padding(EdgeInsets(top: 0, leading: 8, bottom: 5, trailing: 8))
//                        }
//                    }
//                }
                
            }.frame(height: 210)
        }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 230, maxHeight: 230)
    .background(.clear)
    .cornerRadius(10)
    .padding(.top,15)

    }
}


struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // Update the view controller if needed
    }
}

struct ProfileHeaderView: View {
    @State private var showWebpage = false
    @State private var poolBucks = StaticUserData.shared.currentUser.poolBucks
    
    @ObservedObject var screen1VM: screen1ViewModel
    @Binding var timeFrame: String
    

    var body: some View {
        HStack() {
            
            NavigationLink(destination: settingsView()) {
                
                
                if screen1VM.currentUser?.profileImageUrl != "" {
                    KFImage(URL(string: StaticUserData.shared.currentUser.profileImageUrl))
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 30)
                } else {
                    Image("sampleImage")
                        .resizable()
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                }
                Text("\(screen1VM.currentUser?.username ?? "")")
                    .font(.custom(K.customFonts.lexendDecaSB, size: 18))
                    .foregroundColor(.white)
            }
            Spacer()
            currencyView(poolCoins: StaticUserData.shared.currentUser.poolCoins, poolBucks: $poolBucks)
            
        }
        .padding(.top,15)
        .onAppear() {
            screen1VM.fetchUserCoinsAndBucks(userID: Auth.auth().currentUser?.uid ?? "") {
                poolBucks = StaticUserData.shared.currentUser.poolBucks
            }
        }
    }
}

struct announcementView: View {
    
    @ObservedObject var viewModel: screen1ViewModel
    @State var status = "unSeen"
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])
            
            VStack(spacing: 4) {
                popUpPill()
                
                HStack (spacing: 0) {
                    Button(action: {
                        status = "unSeen"
                    }) {
                        Text("New")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 35, alignment: .center)
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        status = "seen"
                    }) {
                        Text("Old")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 35, alignment: .center)
                            .cornerRadius(5)
                    }
                }
                Rectangle()
                    .fill(Color.white) // Sets the rectangle's fill color to white
                    .frame(width: 75, height: 3)
                    .cornerRadius(1) // Apply rounded corners
                    .offset(x: status == "unSeen" ? -50 : 50, y: 0)
                    .animation(.easeInOut(duration: 0.35))
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.userAnnouncements.indices, id: \.self) { index in
                            let announcement = viewModel.userAnnouncements[index]
                            if announcement.status == status {
                                
                                HStack {
                                    ZStack {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text("\(toHHMMSS(from: announcement.timestamp.dateValue()))")
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 10))
                                                    .foregroundColor(.white)
                                                    .padding(.top,3)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                        Text("\(announcement.description)")
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                            .foregroundColor(.white)
                                            .padding(.top, 17.5)
                                            .padding(.horizontal)
                                            .padding(.bottom)
                                        
                                    }
                                    
                                }.frame(width: 300)
                                    .background(K.finalColor.cardBlue)
                                    .cornerRadius(7.5)
                                    .padding(.top)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
        }.onDisappear() {
            viewModel.setAllAnnouncementsToSeen(userID: Auth.auth().currentUser!.uid) {
                viewModel.fetchUserAnnouncements(userID: Auth.auth().currentUser!.uid) {}
            }
        }
    }
}

struct explanationView: View {
    @State var pageSelected: Int
    
    init(pageSelected: Int) {
            _pageSelected = State(initialValue: pageSelected)
        }
    
    var body: some View {
        ZStack (){
            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])
            
            VStack {
                popUpPill()

                HStack (spacing: 0){
                    Button(action: { pageSelected = 0 }) {
                        Text("Global")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 20, alignment: .center)
                        
                    }
                    
                    Button(action: { pageSelected = 1 }) {
                        Text("Challenges")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 20, alignment: .center)
                            .cornerRadius(5)
                    }
                    
                    Button(action: { pageSelected = 2 }) {
                        Text("PoolBucks")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 20, alignment: .center)
                            .cornerRadius(5)
                    }
                }.padding(.top, 2)
                
                Rectangle()
                    .fill(Color.white) // Sets the rectangle's fill color to white
                    .frame(width: 75, height: 3)
                    .cornerRadius(1) // Apply rounded corners
                    .offset(x: CGFloat(-100 + 100*pageSelected), y: 0)
                    .animation(.easeInOut(duration: 0.5))
                
                if pageSelected == 0 {
                    rulesView()
                } else if pageSelected == 1 {
                    challengeDescription()
                } else if pageSelected == 2 {
                    currencyDescription()
                }
            }
        }
    }
}

struct rulesView: View {
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    K.finalColor.backgroundBlue
                    VStack (spacing: 5) {
                        Text("How To Play WagerPool?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("     WagerPool is a FREE TO PLAY social sportsbook where players can place risk free bets in an attempt to win real prizes.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Text("To start, go to the Bets page.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Image("howTo1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Then, pick a spread, moneyline or total from available games.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Your bet will be placed using denominations of 100 points. It is completely free to place. In order to compete in the challenge the game must begin before midnight.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
//                        
//                        Text("Choose the daily or weekly challenge + the corresponding bet you would like to fill.")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
//                            .foregroundColor(K.finalColor.textWhite)
//                            .padding()
                        
//                        Image("howTo4")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 320)
//                            .cornerRadius(5)
//                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
//                        
                        Text("Your bet will appear on the ticket page. You can change it anytime before the game starts.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
//                        Text("You will then ")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
//                            .foregroundColor(K.finalColor.textWhite)
//                            .padding()
//                        
//                        Image("howTo6")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 320)
//                            .cornerRadius(5)
//                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("You are ranked against other players for how well your bets perform over the course of the day. Orange = Pending, Green = Won.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo7")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("When the day ends, winning players will automatically receive their prizes! They will receive PoolBucks that they can redeem 1:1 for $.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo8")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding(.bottom, 20)
                        
                    }.padding(.horizontal)
                }
            }
        }
    }
}


struct countDown: View {
    @StateObject var countdownTimer = CountdownTimer()
    @ObservedObject var prizesVM: prizesViewModel
    @Binding var timeFrame: String
    
    init(prizesVM: prizesViewModel, timeFrame: Binding<String>) {
        self.prizesVM = prizesVM
        self._timeFrame = timeFrame
    }
    var body: some View {
        ZStack() {
            VStack(alignment: .center, spacing: 12) {
                    VStack(spacing: 0) {
                        if timeFrame == "daily" {
                            Text(countdownTimer.dayTimeRemaining)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 28))
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                    }
                    .frame(height: 20).padding(.top,3)
                    
                    HStack{
                        
                        ForEach(0..<3, id: \.self) { index in
                            HStack {
                                Spacer()
                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                if prizesVM.canViewDailyPrizes == true {
                                    Text("\(prizesVM.dailyPrizes[index])  ")
                                        .foregroundColor(.white)
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                                }
                                Spacer()
                            }.frame(width: 100, height: 40)
                                .padding(3)
                                .background(index == 0 ? CommodityColor.gold.linearGradient : (index == 1 ? CommodityColor.silver.linearGradient : CommodityColor.bronze.linearGradient))
                                .cornerRadius(5)
                        }
                    }
                    .padding(.top,5)
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 130, maxHeight: 130)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 16)
        }
    }


struct yourGroups: View {
    @StateObject var screen1VM: screen1ViewModel
    @Binding var tab: Tab
    @State private var showRulesPage = false
    @State private var showAnnouncementsPage = false
    @State private var showPopUp = false
    

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack (spacing: 15) {
                
                Button {
                    showPopUp = true
                } label: {
                    HStack {
                        Spacer()
                        VStack {
                            Image("howTo")
                                .resizable()
                                .cornerRadius(7.5)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(height: 40)
                            Text("How To Play?")
                                .font(.custom(K.customFonts.poppinsMedium, size: 20))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }.frame(height: 100)
                        .background(K.finalColor.cardBlue)
                        .cornerRadius(7.5)
                }
                
                NavigationLink {
                    purchaseCurrencyView()
                        .background(K.finalColor.backgroundBlue)
                } label: {
                    HStack {
                        Spacer()
                        VStack {
                            Image("poolBuck")
                                .resizable()
                                .cornerRadius(7.5)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(height: 50)
                            Text("Deposit/Withdraw")
                                .font(.custom(K.customFonts.poppinsMedium, size: 16))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }.frame(height: 100)
                        .background(K.finalColor.cardBlue)
                        .cornerRadius(7.5)
                }
              
            }.padding(.horizontal, 16)

            
            HStack (spacing: 15) {
                Button {
                    showAnnouncementsPage = true
                    
                } label: {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Image("announcements")
                                    .resizable()
                                    .cornerRadius(7.5)
                                    .foregroundColor(.white)
                                    .scaledToFit()
                                    .frame(height: 40)
                                Text("Announcements")
                                    .font(.custom(K.customFonts.poppinsMedium, size: 15))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        if screen1VM.userAnnouncements.contains(where: {$0.status == "unSeen"}) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .cornerRadius(7.5)
                                        .padding(.trailing, -15)
                                        .padding(.top, -15)
                                }
                                Spacer()
                            }
                        }

                    }.frame(height: 100)
                        .background(K.finalColor.cardBlue)
                        .cornerRadius(7.5)
                }
                 
                Link(destination: URL(string: "https://www.instagram.com/wagerpool/")!) {
                    HStack {
                        Spacer()
                        VStack {
                            Image("instagram")
                                .resizable()
                                .cornerRadius(7.5)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(height: 40)
                            Text("Instagram")
                                .font(.custom(K.customFonts.poppinsMedium, size: 15))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }.frame(height: 100)
                        .background(K.finalColor.cardBlue)
                        .cornerRadius(7.5)
                }
            }.padding(.horizontal, 16)
        }.onAppear() {
            screen1VM.fetchUserAnnouncements(userID: Auth.auth().currentUser!.uid) {}
        }
        .popup(isPresented: $showPopUp) {
            explanationView(pageSelected: 0)
            .frame(height: 650)
        } customize: {
            $0
                .type (.toast)
                .position(.bottom)
                .isOpaque(true)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.4))
        }.popup(isPresented:
            $showAnnouncementsPage) {
                announcementView(viewModel: screen1VM)
                .frame(height: 650)
            } customize: {
                $0
                .type (.toast)
                .position(.bottom)
                .isOpaque(true)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.4))
            }
    }
    func backgroundColor(for index: Int) -> LinearGradient {
        if index % 3 == 0 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.57, green: 0.56, blue: 0.98), Color(red: 0.85, green: 0.58, blue: 0.99)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if index % 3 == 1 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.16, green: 0.62, blue: 0.52), Color(red: 0.59, green: 0.79, blue: 0.44)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.54, blue: 0.51), Color(red: 0.97, green: 0.69, blue: 0.46)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    func overlayShape(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(self.overlayColor(for: index), lineWidth: 0.50)
    }
    
    func overlayColor(for index: Int) -> Color {
        if index % 3 == 0 {
            return Color(red: 0.14, green: 0.61, blue: 0.85)
        } else if index % 3 == 1 {
            return Color(red: 0.15, green: 0.90, blue: 0.69)
        } else {
            return Color(red: 1, green: 0.74, blue: 0.60)
        }
    }
}

struct MostPopularBetsView: View {
    @StateObject var bookVM: bookViewModel
    var body: some View {
        VStack (alignment: .center, spacing: 15) {
            Text("Most Popular Bets")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                    .foregroundColor(.white)
            VStack {
                ForEach(0..<bookVM.mostPopularBets.count, id: \.self) { index in
                    if index < 5 {
                        PopularBetView(index: index, bookVM: bookVM)
                    }
                }
            }
        }
    }
}


struct PopularBetView: View {
    let index: Int
    @StateObject var bookVM: bookViewModel
    private var extra: String {
        if bookVM.mostPopularBets[index].betType == .over {
            return "O"
        } else if bookVM.mostPopularBets[index].betType == .under {
            return "U"
        } else {
            if bookVM.mostPopularBets[index].betLine >= 0 {
                return "+"
            }
        }
        return ""
    }

    var body: some View {
        
        HStack (spacing: 0) {
            //Spacer()
            Text("\(index + 1).")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))

            Text("\(bookVM.mostPopularBets[index].teamName) \(extra)\(bookVM.mostPopularBets[index].betLine)")
                .font(.custom(K.customFonts.lexendDecaMedium, size:
                                bookVM.mostPopularBets[index].teamName.count < 20 ? 16 : 13))
                             //   (bet.teamBetOn?.count ?? 10 > 35 ? 9: 11)))

                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5))
                .cornerRadius(7.5)
                .frame(maxWidth: 300, alignment: .leading)
        }.frame(maxWidth: .infinity, maxHeight: 40) // This line
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(K.finalColor.cardBlue)
        .overlay(self.overlayShape(for: 2))
        .cornerRadius(7.5)
        

    }
    
    func overlayShape(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(self.overlayColor(for: index), lineWidth: 0.50)
    }
    
    func overlayColor(for index: Int) -> Color {
        if index % 3 == 0 {
            return Color(red: 0.14, green: 0.61, blue: 0.85)
        } else if index % 3 == 1 {
            return Color(red: 0.15, green: 0.90, blue: 0.69)
        } else {
            return Color(red: 1, green: 0.74, blue: 0.60)
        }
    }
    
}

//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfileView(tab: .dashboard)
//    }
//}
