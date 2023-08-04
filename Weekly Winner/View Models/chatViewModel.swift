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
