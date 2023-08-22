//
//  chatViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/3/23.
//

import Foundation
import Firebase

class chatViewModel:ObservableObject {
    private var chatService = ChatService()
    
    @Published var allChats: [Message] = []
    @Published var isChatsLoaded: Bool = false
    
    deinit {
        chatService.removeListener()
    }
    

    func reportComment(comment: Message, reason: String) {

        // Upload the flagged comment and reason to Firestore
        let db = Firestore.firestore()

        let data = ["userID": comment.userID,
                    "messageContent": comment.messageContent,
                    "username": comment.username,
                    "groupID": comment.groupID,
                    "timestamp": Timestamp(date: Date()),
                    "reason": reason] as [String: Any]

        Firestore.firestore()
            .collection("flaggedComments")
            .document()
            .setData(data) { error in
                if let error = error {
                    print("DEBUG: Failed to upload tweet with error .. \(error.localizedDescription)")
                    return
                }
                print("DEBUG: Did upload tweet..")

            }
    }

    func uploadChat(message: String, groupID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        var messageData = Message(messageContent: message, timeSent: Date.now, userID: userID, username: UserData.shared.username, groupID: groupID)
        chatService.uploadMessage(messageData: messageData, groupID: groupID) { error in
            if let error = error {
                print(error)
            } else {
                print("chat uploaded ")
            }
        }
    }
    
    func getChats(groupID: String, completion: @escaping (Error) -> Void) {
        chatService.getChats(groupID: groupID) { messages, error in
            if let error = error {
                print("\(error) could not get")
            } else {
                self.allChats = messages ?? []
                self.isChatsLoaded = true
            }
        }
    }
}
