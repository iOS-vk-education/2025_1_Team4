//
//  CameraView.swift
//  NoteHub
//
//  Created for camera functionality
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var capturedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Проверяем доступность камеры
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DispatchQueue.main.async {
                self.isPresented = false
            }
            return picker
        }
        
        // Проверяем разрешение еще раз перед открытием
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .authorized else {
            DispatchQueue.main.async {
                self.isPresented = false
            }
            return picker
        }
        
        // Настраиваем picker только если все проверки пройдены
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        
        // Устанавливаем режим фото (по умолчанию)
        picker.cameraCaptureMode = .photo
        
        // Проверяем доступность задней камеры
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            picker.cameraDevice = .rear
        } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
            picker.cameraDevice = .front
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

