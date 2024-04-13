//
//  pastTicketsView.swift
//  Weekly Winner
//
//  Created by Reid Brown on 4/12/24.
//

import Foundation
import SwiftUI

struct pastTicketsView: View {
    @StateObject var viewModel = PastTicketsViewModel()
    let uid: String
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                
                ScrollView {
                    ForEach(viewModel.pastUserTickets, id: \.id) { ticket in
                        NavigationLink(destination: {
                            #warning("THIS DOESNT WORK. Goes to current ticket need to do some gay date thing to get the exact one...")
                            ticketView(username: ticket.username, uid: ticket.uid, groupID: "GlobalDaily", selectedWeek: viewModel.returnStringForSpecificDate(from: ticket.dateCreated), ticketFormatForGroups: [], ownTicket: true, onTicketPage: true, passedTimeFrame: "daily")
                        }, label: {
                            
                            VStack(spacing: 3){
                                HStack{
                                    Text("\(formatDateMMDDYY(from: ticket.dateCreated))")
                                        .lexMedCustom(14, color: .white)
                                    Spacer()
                                }.padding(.horizontal)
                                    .padding(.leading, 2)
                                
                                BetCard(
                                    ticket: ticket,
                                    rank: ticket.rank,
                                    ownCard: false,
                                    currentWeek: false,
                                    homePage: true
                                ).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                    .padding(.horizontal)
                            }
                        })
                    }
                }.padding(.vertical)
            }
            
        }
        .onAppear() {
            viewModel.loadPastTickets(uid: uid) {
                
            }
        }
    }
}
