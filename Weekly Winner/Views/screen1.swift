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
    @StateObject var authenticationVM = authenticationViewModel()
    @StateObject var bookVM = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    @StateObject var groupsVM = groupsViewModel()
    @StateObject var countdownTimer = CountdownTimer()
    @State private var showWebpage = false
    
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
                yourGroups(groupsVM: groupsVM)
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
            
            print("appeared")
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
            
            Link("@WagerPool", destination: URL(string: "https://www.instagram.com/wagerpool/")!)
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10)) // Adds padding around the link
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
            
            
        }.padding(.top,5)
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

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
