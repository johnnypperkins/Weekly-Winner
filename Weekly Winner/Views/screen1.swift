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


struct UserProfileView: View {
    @ObservedObject private var authenticationVM = authenticationViewModel()
    @ObservedObject private var bookVM = bookViewModel()
    @ObservedObject private var ticketVM = ticketViewModel()
    @ObservedObject private var groupsVM = groupsViewModel()
    @StateObject var countdownTimer = CountdownTimer()
    @State private var showWebpage = false
    @Binding var tab: Tab
   // @State private var showRulesPage = false
    

    var body: some View {
        VStack(spacing: 15) {
            //Spacer()
            ProfileHeaderView(authVM: authenticationVM)
                .padding(.top, 10)
                .padding(.horizontal)
            
            countDown()
                .padding(.top, 5)
            //Spacer()
            VStack {
                yourGroups(groupsVM: groupsVM, tab: $tab)
                    .padding(.horizontal)
                
                MostPopularBetsView(bookVM: bookVM)
                    .padding(.horizontal)
                Spacer()
            }.padding(.bottom,45)

        }
        .sheet(isPresented: $showWebpage) {
            SafariView(url: URL(string: authenticationVM.updateURL)!)
                                    }
       
        
        .background(K.finalColor.backgroundBlue)
        .onAppear() {
            authenticationVM.forceUpdate () {
                if authenticationVM.updateURL != ""{
                    AppUtility.shared.showCustomAlert(alertType: .none, message: "There is a new, necessary update. Sorry we know this is annoying...", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: nil) { action in
                        if action == AlertButtonAction.okButton{
                            showWebpage.toggle()
                        }
                        
                    }
                }
            }
            authenticationVM.fetchUser() {
                
                print("\(UserData.shared.username) is username")
            }
            groupsVM.fetchUserTickets() {}
            groupsVM.fetchUserGroups {

            }
            bookVM.fetchMostPopularBets()
        }.padding(.top, 35)
        //Spacer()
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
    @State private var showRulesPage = false
    @StateObject var authVM: authenticationViewModel
    var body: some View {
        HStack() {
            if authVM.currUser?.profileImageUrl != nil {
                KFImage(URL(string: authVM.currUser?.profileImageUrl ?? "sampleImage"))
                    .resizable()
                    .clipShape(Circle())
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
            }else {
                Image("sampleImage")
                    .resizable()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
            }
            
            Text(authVM.currUser?.username ?? "nil")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.94))
                .frame(height: 30)

            Spacer()
            
            Button(action: {
                showRulesPage.toggle()
            }, label: {
                VStack {
                    Text("How to play?")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                    //Spacer()
                }//.padding(.top, 20)
                    //.contentShape(Rectangle())
                    //.background(.brown) // Use the desired background color
                //.cornerRadius(8)
                     // Adjust the padding as needed
            })
            
            
//            Link("@WagerPool", destination: URL(string: "https://www.instagram.com/wagerpool/")!)
//                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
//                .foregroundColor(.white)
//                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10)) // Adds padding around the link
                //.background(Color.blue) // Use any color you prefer for the background

//            Button(action: {
//                                            self.showWebpage = true
//                                        }) {
//                                            Text("@WagerPool")
//                                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
//                                                .foregroundColor(.white)
//                                                .padding([.leading,.bottom])
//                                        }
//                                        .sheet(isPresented: $showWebpage) {
//                                            SafariView(url: URL(string: "https://www.instagram.com/wagerpool/")!)
//                                        }
            
            
        }
        .padding(.top,5)
        .sheet(isPresented: $showRulesPage) {
            rulesView()
                //.padding(.horizontal)
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.hidden)
            .background(K.finalColor.backgroundBlue)
        }//.edgesIgnoringSafeArea(.top)
    }
}

struct rulesView: View {
    var body: some View {
        ScrollView {
            VStack (spacing: 5) {
                Text("How Does WagerPool Work?")
                    .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                    .foregroundColor(K.finalColor.titleBlue)
                    .padding(.vertical)
                Text("     WagerPool is a completely free social gambling app where the user's objective is to earn as much “fictional money” as possible over the course of the week. Users will fill out the 'Global' ticket, which will contain the number of bets available to place for the user for that week (Sun-Sun). In an effort to create an engaging and competitive experience, the number of bets available for users to place will change week to week. Spreads and lines are conveniently located on the app’s 'Bets' tab. After looking at the various spreads and lines, users will return to their 'Global' ticket with their picks for the week. The user automatically joins and competes in the global group upon creating an account.")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(K.finalColor.textWhite)
                
                Text("     As each user's bets hit or miss, the user will be ranked among other players in their group(s) based on how much 'money' they have made over the course of the week. It is important to note that users can only win money and any losses will not be deducted from the user’s total (it can be thought of as all free play). Also, pushes count as a win. As the week comes to a close, the user who has made the most fictional money in the GLOBAL GROUP will win ACTUAL MONEY that will be paid out through a payment service of their choice: venmo, cashapp, paypal, etc. The current prizes offered can be found by clicking on the green dollar sign on the global group page.")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(K.finalColor.textWhite)
                
                Text("     Users also have the option of creating their own personal groups. Players will be able to join and bet on the week on their own terms (such as club sports, intramural teams, or philanthropic events) outside of the app. WagerPool would serve as your group’s coordinator. If you would like to have a personal group sponsored, you can send a direct message to @wagerpool on instagram.")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(K.finalColor.textWhite)
            }.padding(.horizontal)
        }
    }
}


struct countDown: View {
    @StateObject var countdownTimer = CountdownTimer()
  var body: some View {
    ZStack() {
        VStack(alignment: .center) {
          HStack{
              Text("WagerPool")
                  .font(.custom(K.customFonts.lexendDecaSB, size: 24))
                  .foregroundColor(K.finalColor.titleBlue)
              //Spacer()
          }.frame(minWidth: 0, maxWidth: .infinity)
              .padding(.horizontal)
            VStack(spacing: 0) {
                Text(countdownTimer.timeRemaining)
                    .font(.custom(K.customFonts.juraRegular, size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom)
            }
          .frame(height: 25)
          
      }
      .frame(height: 60)
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
    .background(K.finalColor.cardBlue)
    .cornerRadius(10)
    .padding(.horizontal, 16)
  }
}

struct yourGroups: View {
    @StateObject var groupsVM: groupsViewModel
    @Binding var tab: Tab
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Your Groups")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 24).weight(.medium))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<groupsVM.userTickets.count, id: \.self) { index in
                        // Use your custom view or data here.
                        // Replace `Text("Item \(index)")` with your custom view
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 3) {
                                
                                if groupsVM.userGroupsLoaded {
                                    if groupsVM.userGroups[index].groupImageURL != "" {
                                        HStack {
                                            Spacer()
                                            KFImage(URL(string: groupsVM.userGroups[index].groupImageURL))
                                                .resizable()
                                                .cornerRadius(7.5)
                                                .foregroundColor(.clear)
                                                .scaledToFit()
                                                .frame(height: 95)
                                            Spacer()
                                        }
                                    }
                                    else {
                                        Image(systemName: "photo.circle.fill")
                                            .resizable()
                                            .cornerRadius(7.5)
                                            .foregroundColor(.clear)
                                            .scaledToFit()
                                            .frame(height: 95)
                                    }
                                }
                                HStack(alignment: .top) {
                                    Spacer()
                                    Text(groupsVM.userTickets[index].groupName)
                                        .font(.custom(K.customFonts.poppinsMedium, size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                           
                                }
                               
                                
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                HStack() {
                                    Text("Rank")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("#\(groupsVM.userTickets[index].rank)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                                HStack() {
                                    Text("Potential")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(groupsVM.userTickets[index].totalPotentialWon)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                                HStack() {
                                    Text("Total Won")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(groupsVM.userTickets[index].totalWon)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(10)
                        .frame(width: 135, height: 205)
                        .background(self.backgroundColor(for: index))
                        .cornerRadius(12)
                        .overlay(self.overlayShape(for: index))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                                
                                    HStack {
                                        Spacer()
                                        Image(systemName: "person.3.fill")
                                            .resizable()
                                            .cornerRadius(7.5)
                                            .foregroundColor(.white)
                                            .scaledToFit()
                                            .frame(height: 95)
                                        Spacer()
                                    }
                            HStack(alignment: .top) {
                                Spacer()
                                Text("Join/Create!")
                                    .font(.custom(K.customFonts.poppinsMedium, size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                       
                            }
                           
                            
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Button {
                                
                                withAnimation {
                                    tab = .groups
                                }
                                
                            } label: {
                                HStack{
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 17, height: 10)
                                        .foregroundColor(.white)
                                    //shadow
                                    
                                    Spacer()
                                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30 , maxHeight: 30)
                                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                                    .cornerRadius(10)
                                    .padding(.horizontal,16)
                            }
                               
                        }
                    }
                    .padding(10)
                    .frame(width: 140, height: 205)
                    .background(K.finalColor.backgroundBlue)
                    .cornerRadius(12)
                    .overlay(self.overlayShape(for: 1))
                }
            }
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
        .cornerRadius(7.5)

    }
    
}

//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfileView(tab: .dashboard)
//    }
//}
