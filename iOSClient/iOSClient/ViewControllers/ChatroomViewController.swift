//
//  ChatroomViewController.swift
//  iOSClient
//
//  Created by Milad on 12/9/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import Photos
import Firebase // for User class

protocol ChatroomViewControllerProtocol: AnyObject {
  func didtapLogout(completion: @escaping (Error?) -> Void)
}

final class ChatroomViewController: MessagesViewController  {

  weak var delegate: ChatroomViewControllerProtocol?
  
  private let user: User
  private var messages: [Message] = []
  private let storage = Storage.storage().reference()
  private let db = Firestore.firestore()
  private var chatManager: ChatManager?
  
  private var isSendingPhoto = false {
    didSet {
      DispatchQueue.main.async {
//        self.messageInputBar.leftStackViewItems.forEach { item in
//          item.isEnabled = !self.isSendingPhoto
//        }
        self.messageInputBar.isUserInteractionEnabled = !self.isSendingPhoto
      }
    }
  }
  
  init(user: User, chatManager: ChatManager) {
    self.user = user
    self.chatManager = chatManager
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    chatManager?.addChatListener(handleDocumentChange(_:))
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    let cameraItem = InputBarButtonItem(type: .custom) //UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
    cameraItem.tintColor = .primary
    cameraItem.image = #imageLiteral(resourceName: "camera")
    cameraItem.addTarget(self, action: #selector(cameraButtonPressed),for: .primaryActionTriggered)
    cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
    messageInputBar.leftStackView.alignment = .center
    messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
    messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    
    maintainPositionOnKeyboardFrameChanged = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let logOutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ChatroomViewController.logout) )
    navigationItem.leftBarButtonItem = logOutButton
    navigationController!.navigationBar.tintColor = .black
    title = "Main Chat"
    
    navigationController?.navigationBar.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
    navigationItem.leftBarButtonItem = nil
  }
  
  deinit {
    chatManager?.removeChatListener()
  }
  
  // MARK: - Actions
  
  @objc private func cameraButtonPressed() {
    let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
      self.openCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
      self.openGallery()
    }))
    
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @objc func logout() {
    print(#function)
    showLoadingHUD(for: self.view, text: "Logging out")
    delegate?.didtapLogout() { [weak self] (error) in
      if error != nil {
        print("ERROR OCCURED WHILE LOGGING OUT")
      }
      self!.hideLoadingHUD(for: self!.view)
    }
  }
}

// MARK: - Helpers
extension ChatroomViewController {
  private func save(_ message: Message) {
    chatManager?.save(message) { error in
      if let e = error {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  private func insertNewMessage(_ message: Message) {
    guard !messages.contains(message) else {
      return
    }
    
    messages.append(message)
    messages.sort()
    
    //messagesCollectionView.reloadData()
    
    let isLatestMessage = messages.index(of: message) == (messages.count - 1)
    let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
    
    // Reload last section to update header/footer labels and insert a new one
//    messagesCollectionView.performBatchUpdates({
//      messagesCollectionView.insertSections([messages.count - 1])
//      if messages.count >= 2 {
//        messagesCollectionView.reloadSections([messages.count - 2])
//      }
//    }, completion: { [weak self] _ in
//      if isLatestMessage == true {
//        self?.messagesCollectionView.scrollToBottom(animated: true)
//      }
//    })
    
    //print(message)
    
    if shouldScrollToBottom || message.downloadURL != nil { // TODO: - gracefully handle scrolling when images download
      DispatchQueue.main.async {
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
      }
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard var message = Message(document: change.document) else {
      return
    }
    
    switch change.type {
    case .added:
      if let url = message.downloadURL {
        downloadImage(at: url) { [weak self] image in
          guard let self = self else {
            return
          }
          guard let image = image else {
            return
          }

          message.image = image
          self.insertNewMessage(message)
        }
      } else {
        insertNewMessage(message)
      }
      
    default:
      break
    }
  }
  
  private func uploadImage(_ image: UIImage, to channelName: String, completion: @escaping (URL?) -> Void) {
    guard let scaledImage = image.scaledToSafeUploadSize,
      let data = scaledImage.jpegData(compressionQuality: 0.4) else {
        completion(nil)
        return
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
    let ref = storage.child(channelName).child(imageName)
    ref.putData(data, metadata: metadata) { meta, error in
      ref.downloadURL() { url, error in
        completion(url)
      }
    }
  }
  
  private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
    let ref = Storage.storage().reference(forURL: url.absoluteString)
    let megaByte = Int64(1 * 1024 * 1024)
    
    ref.getData(maxSize: megaByte) { data, error in
      guard let imageData = data else {
        completion(nil)
        return
      }
      
      completion(UIImage(data: imageData))
    }
  }
  
  private func sendPhoto(_ image: UIImage) {
    isSendingPhoto = true
    
    uploadImage(image, to: "main") { [weak self] url in
      guard let `self` = self else {
        return
      }
      self.isSendingPhoto = false
      
      guard let url = url else {
        return
      }
      
      var message = Message(user: self.user, image: image)
      message.downloadURL = url
      
      self.save(message)
      //self.messagesCollectionView.scrollToBottom()
    }
  }
}

extension ChatroomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let asset = info[.phAsset] as? PHAsset {
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { [weak self] result, info in
        guard let image = result else {
          return
        }
        
        print("sending image as PHAsset?")
        self!.sendPhoto(image)
      }
    } else if let image = info[.originalImage] as? UIImage {
      print("sending image as UIImage")
      sendPhoto(image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func openCamera() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = UIImagePickerController.SourceType.camera
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
    } else {
      let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func openGallery() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.allowsEditing = false
      imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
      self.present(imagePicker, animated: true, completion: nil)
    } else {
      let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
}

extension ChatroomViewController: MessagesDataSource {
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func currentSender() -> Sender {
    return Sender(id: user.uid, displayName: user.displayName!)
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func cellTopLabelAttributedText(for message: MessageType,
                                  at indexPath: IndexPath) -> NSAttributedString? {
    
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
}

extension ChatroomViewController: MessageInputBarDelegate {
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    let message = Message(user: user, content: text)
    save(message)
    inputBar.inputTextView.text = ""
  }

}

extension ChatroomViewController: MessagesLayoutDelegate {
  
  func avatarSize(for message: MessageType, at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return .zero
  }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }
}

extension ChatroomViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
    return false
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}
