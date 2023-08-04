//
//  chatService.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/3/23.
//

import Foundation
import Firebase

struct ChatService {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    mutating func getChats(groupID: String, completion: @escaping ([Message]?, Error?) -> Void) {
        listener = db.collection("groups").document(groupID).collection("chats")
            .order(by: "timeSent", descending: false)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("There was an error getting the chats: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents were found")
                    return
                }
                
                var messages: [Message] = []
                for document in documents {
                    let data = document.data()
                    
                    guard let userID = data["userID"] as? String,
                          let username = data["username"] as? String,
                          let messageContent = data["messageContent"] as? String,
                          let timestamp = data["timeSent"] as? Timestamp else {
                        continue
                    }
                    
                    let message = Message(messageContent: messageContent, timeSent: timestamp.dateValue(), userID: userID, username: username, groupID: groupID)
                    messages.append(message)
                }
                print("\(messages) is messages")
                completion(messages, nil)
            }
    }

    func removeListener() {
        listener?.remove()
    }

    func uploadMessage(messageData: Message, groupID: String, completion: @escaping (Error?) -> Void) {

        var data: [String: Any] = [
            "messageContent": messageData.messageContent,
            "timeSent": messageData.timeSent,
            "userID": messageData.userID,
            "username": messageData.username,
            "groupID": messageData.groupID
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("groups").document(groupID).collection("chats").addDocument(data: data) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    // func uploadChat
}
