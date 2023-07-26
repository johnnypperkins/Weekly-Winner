//
//  imageUploader.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/25/23.
//


import Foundation
import UIKit
import FirebaseStorage

struct imageUploader {
    @available(*, renamed: "uploadImage(use:image:)")
    static func uploadImage(use: String, image: UIImage, completion: @escaping(String) -> Void){
        Task {
            let result = await uploadImage(use: use, image: image)
            completion(result)
        }
    }
    
    
    static func uploadImage(use: String, image: UIImage) async -> String {
        print("entered4")
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return ""}
        
        let filename = NSUUID().uuidString
        print("entered5")
        let ref = Storage.storage().reference(withPath:"/\(use)/\(filename)")
        
        return await withCheckedContinuation { continuation in
            ref.putData(imageData, metadata: nil) {_, error in
                if let error = error {
                    print("failed to uploaqd image with error: \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL {imageUrl, _ in
                    guard let imageUrl1 = imageUrl?.absoluteString else {return}
                    continuation.resume(returning: imageUrl1)
                }
            }
            
            
        }
    }
}

