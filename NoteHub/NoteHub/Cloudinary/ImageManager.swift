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
    private var imageCache: [String: Data] = [:]
    private let cacheQueue = DispatchQueue(label: "ImageCacheQueue", attributes: .concurrent)
    
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
        // Проверяем кэш
        if let cachedData = getCachedImage(urlString: urlString) {
            return DBImage(url: urlString, data: cachedData)
        }
        
        // Загружаем изображение
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Сохраняем в кэш
        cacheImage(urlString: urlString, data: data)
        
        return DBImage(url: urlString, data: data)
    }
    
    // Получить изображение только по URL (без загрузки данных) - для быстрой загрузки списка заметок
    func getImageURLOnly(urlString: String) -> DBImage {
        // Если есть в кэше, возвращаем с данными
        if let cachedData = getCachedImage(urlString: urlString) {
            return DBImage(url: urlString, data: cachedData)
        }
        // Иначе возвращаем только URL, данные будут загружены позже
        return DBImage(url: urlString, data: Data())
    }
    
    private func getCachedImage(urlString: String) -> Data? {
        return cacheQueue.sync {
            return imageCache[urlString]
        }
    }
    
    private func cacheImage(urlString: String, data: Data) {
        cacheQueue.async(flags: .barrier) {
            self.imageCache[urlString] = data
        }
    }
}

