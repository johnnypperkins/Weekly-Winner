//
//  pastTicketsViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown on 4/12/24.
//

import Foundation
import Firebase

class PastTicketsViewModel: ObservableObject {
    @Published var pastUserTickets: [Ticket] = []
    private let betService = BetService()
    
    
    /// Loads all all previous user tickets
    func loadPastTickets(uid: String, completion: @escaping() -> Void) {
        betService.fetchPastTickets(uid: uid) { tickets in
            DispatchQueue.main.async {
                self.pastUserTickets = tickets
                completion()
            }
        }
    }
    
    func returnStringForSpecificDate(from timestamp: Timestamp) -> String {
    
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC-5")! // Set to UTC-5

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Month/Day/Year Hours:Minutes in 24-hour format
        dateFormatter.timeZone = TimeZone(identifier: "UTC-5")! // Set to UTC-5

        // Convert Firestore Timestamp to Date
        let utcDate = timestamp.dateValue()

        // Adjust the date to UTC-5 and subtract 6 hours and 59 minutes to align with 00:01
        var inputDate = calendar.date(byAdding: .second, value: TimeZone(identifier: "UTC-5")!.secondsFromGMT(), to: utcDate)!
        inputDate = calendar.date(byAdding: .hour, value: 5, to: inputDate)!
        inputDate = calendar.date(byAdding: .minute, value: 1, to: inputDate)!

        // Get the current date in UTC-5
        let currentDateInUTC5 = calendar.date(byAdding: .second, value: TimeZone(identifier: "UTC-5")!.secondsFromGMT(), to: Date())!
        print("CURRENT DATE UTC-5", currentDateInUTC5)

        // Initialize the current day to the inputDate
//        var currentDay = inputDate

//        // Keep adding days until a day in the future is added
//        while currentDay <= currentDateInUTC5 {
//            days.append(dateFormatter.string(from: currentDay))
//            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
//        }

        return dateFormatter.string(from: inputDate)
    }
    
}

