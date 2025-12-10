//
//  ImageManager.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 10.12.2025.
//

import Foundation
import FirebaseStorage

final class ImageManager {
    static let instance = ImageManager()
    private init() {}
    
    func createImage(createimageRequest: CreateImageRequest) async throws -> DBImage {
        do {
            let iid = UUID().uuidString
            let ref = Storage.storage().reference().child("noteImages/\(iid).jpg")
            print("Uploading size: \(createimageRequest.data.count)")
            let metadata = try await ref.putDataAsync(createimageRequest.data)
            print("Upload success: \(metadata)")
            let url = try await ref.downloadURL()
            print("Download URL: \(url)")
            return DBImage(url: url.absoluteString, data: createimageRequest.data)
        } catch {
            print("Upload error: \(error)")
            throw error
        }
//        let iid = UUID().uuidString
//        let ref = Storage.storage().reference().child("noteImages/\(iid).jpg")
//        _ = try await ref.putDataAsync(createimageRequest.data)
//        let url = try await ref.downloadURL()
//        return DBImage(url: url.absoluteString, data: createimageRequest.data)
    }
    
    func getImage(urlString: String) async throws -> DBImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return DBImage(url: urlString, data: data)
    }
}
