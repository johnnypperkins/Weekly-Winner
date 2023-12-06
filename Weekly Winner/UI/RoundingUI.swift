//
//  RoundingUI.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 7/7/23.
//

import Foundation
import SwiftUI

struct LeftRoundedCorners: Shape {
    var radius: CGFloat = .infinity
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // top right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY)) // start of bottom left curve
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius,
                        startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius)) // end of top left curve
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius,
                        startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        }
    }
}
struct RightRoundedCorners: Shape {
    var radius: CGFloat = .infinity
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // start of top right curve
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius,
                        startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius)) // end of bottom right curve
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius,
                        startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
        }
    }
}

struct TopRoundedCorners: Shape {
    var radius: CGFloat = .infinity
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY)) // start of top left curve
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius,
                        startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // end of top right curve
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius,
                        startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
        }
    }
}

struct BottomRoundedCorners: Shape {
    var radius: CGFloat = .infinity
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // top right
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY)) // start of bottom right curve
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius,
                        startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY)) // end of bottom left curve
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius,
                        startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        }
    }
}

struct RoundedCorners: Shape {
    var topLeft: CGFloat = 0.0
    var topRight: CGFloat = 0.0
    var bottomLeft: CGFloat = 0.0
    var bottomRight: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let topRight = min(min(self.topRight, height/2), width/2)
        let topLeft = min(min(self.topLeft, height/2), width/2)
        let bottomLeft = min(min(self.bottomLeft, height/2), width/2)
        let bottomRight = min(min(self.bottomRight, height/2), width/2)

        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - topRight, y: 0))
        path.addArc(center: CGPoint(x: width - topRight, y: topRight), radius: topRight,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - bottomRight))
        path.addArc(center: CGPoint(x: width - bottomRight, y: height - bottomRight), radius: bottomRight,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bottomLeft, y: height))
        path.addArc(center: CGPoint(x: bottomLeft, y: height - bottomLeft), radius: bottomLeft,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addArc(center: CGPoint(x: topLeft, y: topLeft), radius: topLeft,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ConditionalCornerRadius: ViewModifier {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedCorner(radius: topLeft, corners: [.topLeft]))
            .clipShape(RoundedCorner(radius: topRight, corners: [.topRight]))
            .clipShape(RoundedCorner(radius: bottomLeft, corners: [.bottomLeft]))
            .clipShape(RoundedCorner(radius: bottomRight, corners: [.bottomRight]))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}


struct TopRoundedRectangle: Shape {
    var radius: CGFloat = .infinity

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // start at bottom left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius)) // draw line to top left on y axis
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false) // top left corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // line to top right on x axis
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius,
                    startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false) // top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // line to bottom right on x axis
        return path
    }
}

struct BottomRoundedRectangle: Shape {
    var radius: CGFloat = .infinity

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // start at top left
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // line to top right on x axis
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius)) // line to bottom right on y axis
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false) // bottom right corner
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY)) // line to bottom left on x axis
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false) // bottom left corner
        return path
    }
}


struct RoundSomeCorners: Shape {
    var topLeft: CGFloat = 0.0
    var topRight: CGFloat = 0.0
    var bottomLeft: CGFloat = 0.0
    var bottomRight: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        let tr = min(min(topRight, height/2), width/2)
        let tl = min(min(topLeft, height/2), width/2)
        let bl = min(min(bottomLeft, height/2), width/2)
        let br = min(min(bottomRight, height/2), width/2)

        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - tr, y: 0))
        path.addArc(center: CGPoint(x: width - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - br))
        path.addArc(center: CGPoint(x: width - br, y: height - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: height))
        path.addArc(center: CGPoint(x: bl, y: height - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}







// CODE FOR GROUPS THAT IS SAVED

//                    if viewModel.userTickets.count <= 2 {
//
//
//                        ZStack {
//                                Button(action: {
//                                    selectedGroup = 0
//                                }) {
//                                    ZStack{
//                                        Image(systemName: "plus")
//                                            .foregroundColor(.white)
//                                            .frame(width: 45, height: 35, alignment: .center)
//                                            .background(selectedGroup == 0 ? K.finalColor.titleBlue : K.finalColor.cardBlue)
//                                            .cornerRadius(5)
//
//                                    }
//                                    Spacer()
//                                }
//                                    Spacer()
//                                    HStack {
//                                        ForEach(1..<viewModel.userTickets.count+1, id: \.self) { index in
//
//                                        }
//                                    }
//                                Spacer()
//
//                        }.padding(.horizontal, 10)
//
//                    } else {
//
//                        HStack(spacing: 10) {
//                            Button(action: {
//                                selectedGroup = 0
//                            }) {
//                                Image(systemName: "plus")
//                                    .foregroundColor(.white)
//                                    .frame(width: 45, height: 35, alignment: .center)
//                                    .background(selectedGroup == 0 ? K.finalColor.titleBlue : K.finalColor.cardBlue)
//                                    .cornerRadius(5)
//                            }
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack {
//                                    ForEach(1..<viewModel.userTickets.count+1, id: \.self) { index in
//
//                                        Button(action: {
//                                            self.selectedGroup = index
//                                            viewModel.fetchCurrentRankedTickets(groupID: viewModel.userTickets[index-1].groupID) {}
//                                            showingChat = false
//                                            whichWeek = 0
//                                            print("\(selectedGroup) is selected")
//                                        }) {
//                                            Text(viewModel.userTickets[index-1].groupName)
//                                                .font(.custom(K.customFonts.lexendDecaLight, size: 16))
//                                                .foregroundColor(.white)
//                                                .frame(width: 105, height: 35, alignment: .center)
//                                                .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
//                                                .cornerRadius(5)
//                                        }
//
//                                    }
//                                }
//                        }
//
//                        }.padding(.horizontal, 16)
//
//                    }

/*
 Text("Search Group")
     .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
     .foregroundColor(.white)
     .padding(.top,20)
 
 SearchBar(text: keywordBinding, placeholder: "Search Groups")
 if (viewModel.userTickets.count >= P.maxNumGroupsCanJoin) {
     Text("Max Groups Joined")
         .foregroundColor(Color.red)
 }
 ZStack{
     if !viewModel.queriedGroups.isEmpty {
         withAnimation {
             ScrollView {
                 VStack {
                     ForEach(viewModel.queriedGroups, id: \.groupName) { group in
                         let group1 = group
                         if (viewModel.userTickets.count < P.maxNumGroupsCanJoin) {
                             Button(action: {
                                 // Destination view code
                                 selectedGroupBar = group
                                 isJoinSheetPresented.toggle()
                             }) {
                                 HStack{
                                     VStack(alignment: .leading){
                                         HStack{
                                             if group.groupImageURL != ""{
                                                 KFImage(URL(string: group.groupImageURL))
                                                     .resizable()
                                                     .cornerRadius(25)
                                                     .frame(width: 40, height: 40, alignment: .leading)
                                             }
                                             else {
                                                 Image(systemName: "person.3.fill")
                                                     .resizable()
                                                     .cornerRadius(25)
                                                     .frame(width: 40, height: 40, alignment: .leading)
                                             }
                                             
                                             VStack(alignment: .leading) {
                                                 
                                                 HStack {
                                                     Text("\(group.groupName)")
                                                         .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                         .foregroundColor(.white)
                                                     
                                                     Spacer()
                                                     if group.password != "" {
                                                         Text("Private Group")
                                                             .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                             .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                                             .frame(alignment: .top)
                                                     }
                                                     else{
                                                         Text("Public Group")
                                                             .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                             .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                                             .frame(alignment: .top)
                                                     }
                                                 }.frame(minWidth: 0, maxWidth: .infinity)
                                                 
                                                 Text("\(group.groupSlogan)")
                                                     .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                                       .foregroundColor(.white)
                                             }
                                             Spacer()
                                             
                                         }
                                         HStack {
                                             Text("Group Admin")
                                                 .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                               .foregroundColor(.white)
                                             Spacer()
                                             Text(group.groupAdminUsername)
                                               .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                               .foregroundColor(.white)
                                         }
                                         .padding(.top,10)

                                         HStack{
                                             Spacer()
                                             
                                             Text("Join")
                                                 .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                 .foregroundColor(.white)
                                                             //shadow
                                             
                                             Spacer()
                                         }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 40 , maxHeight: 40)
                                             .background(Color(red: 0.31, green: 0.57, blue: 1))
                                             .cornerRadius(10)
                                             .padding(.top,10)
                                         
                                     }.frame(minWidth: 0, maxWidth: .infinity)
                                         .padding(.horizontal,15)
                                         .padding(.vertical,20)
                                 }
                                 .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                 .cornerRadius(10)
                                 .padding(.horizontal,16)
                             }
                             .sheet(item: $selectedGroupBar) {
                                 groupSelected in
                                 GroupJoinSheet(group: groupSelected, viewModel: viewModel, isPresented: $isJoinSheetPresented)
                                     .presentationDetents([.fraction(0.50)])
                             }
                         } else {
                             groupBarView(group: group)
                         }
                     }.padding(.bottom,10)
                 }.padding(.bottom, 60)
             }
         }.animation(.easeInOut, value: 20)
     }
     if searchText.isEmpty {
         VStack {
             Spacer()
             Button {
                 print(viewModel.userTickets)
                 isShowingSheet.toggle()
             } label: {
                 HStack{
                     Spacer()
                     
                     Text("Create")
                         .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                         .foregroundColor(.white)
                     //shadow
                     
                     Spacer()
                 }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                     .background(Color(red: 0.31, green: 0.57, blue: 1))
                     .cornerRadius(10)
                     .padding(.horizontal,16)
                     .padding(.bottom,100)
             }
         }.frame(minHeight: 0, maxHeight: .infinity)
     }
 }*/
