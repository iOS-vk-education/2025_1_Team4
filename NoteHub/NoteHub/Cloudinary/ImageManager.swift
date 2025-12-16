//
//  ImageManager.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 10.12.2025.
//

import Cloudinary
import Foundation

final class ImageManager {
    static let instance = ImageManager()
    
    private let cloudinary: CLDCloudinary
    
    private init() {
        let config = CLDConfiguration(
            cloudName: CloudinaryConfig.cloudName,
            secure: true
        )
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    
    func createImage(createimageRequest: CreateImageRequest) async throws -> DBImage {
        let iid = UUID().uuidString
        let publicId = "noteImages/\(iid)"
        
        let params = CLDUploadRequestParams()
            .setPublicId(publicId)
        
        return try await withCheckedThrowingContinuation { continuation in
            cloudinary
                .createUploader()
                .upload(
                    data: createimageRequest.data,
                    uploadPreset: CloudinaryConfig.uploadPreset,
                    params: params, completionHandler:  { result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let secureUrl = result?.secureUrl else {
                            continuation.resume(throwing: URLError(.badServerResponse))
                            return
                        }
                        
                        let dbImage = DBImage(url: secureUrl, data: createimageRequest.data)
                        continuation.resume(returning: dbImage)
                    })
        }
    }
    
    func getImage(urlString: String) async throws -> DBImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return DBImage(url: urlString, data: data)
    }
}

