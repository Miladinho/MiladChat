//
//  ChatManager.swift
//  iOSClient
//
//  Created by Milad on 11/27/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import Foundation
import Firebase // for User class
import FirebaseFirestore

class ChatManager {
  private let storage = Storage.storage().reference()
  private let db = Firestore.firestore()
  private var reference: CollectionReference?
  private var messageListener: ListenerRegistration?
  
  init(path: String) {
    reference = db.collection(path)
  }
  
  func addChatListener(_ handleDocumentChange: @escaping (DocumentChange) -> Void) {
    messageListener = reference?.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        handleDocumentChange(change)
      }
    }
  }
  
  func removeChatListener() {
    messageListener?.remove()
  }
  
  func save(_ message: Message, callback: @escaping (Error?) -> Void) {
    reference?.addDocument(data: message.representation) { error in
      callback(error)
    }
  }
}
