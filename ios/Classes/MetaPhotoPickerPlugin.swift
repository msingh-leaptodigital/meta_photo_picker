import Flutter
import UIKit
import PhotosUI
import Photos

public class MetaPhotoPickerPlugin: NSObject, FlutterPlugin {
    private var flutterResult: FlutterResult?
    private var pickerConfig: [String: Any]?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "meta_photo_picker", binaryMessenger: registrar.messenger())
        let instance = MetaPhotoPickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "pickPhotos":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Invalid arguments",
                                  details: nil))
                return
            }
            self.flutterResult = result
            self.pickerConfig = args
            presentPhotoPicker(config: args)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func presentPhotoPicker(config: [String: Any]) {
        guard #available(iOS 14, *) else {
            flutterResult?(FlutterError(code: "UNSUPPORTED_VERSION",
                                       message: "PHPicker requires iOS 14 or later",
                                       details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            
            // Set selection limit
            if let selectionLimit = config["selectionLimit"] as? Int {
                configuration.selectionLimit = selectionLimit
            }
            
            // Set filter
            if let filterString = config["filter"] as? String {
                switch filterString {
                case "images":
                    configuration.filter = .images
                case "videos":
                    configuration.filter = .videos
                case "livePhotos":
                    configuration.filter = .livePhotos
                case "any":
                    configuration.filter = .any(of: [.images, .videos, .livePhotos])
                default:
                    configuration.filter = .images
                }
            }
            
            // Set preferred asset representation mode
            if let modeString = config["preferredAssetRepresentationMode"] as? String {
                switch modeString {
                case "automatic":
                    configuration.preferredAssetRepresentationMode = .automatic
                case "current":
                    configuration.preferredAssetRepresentationMode = .current
                case "compatible":
                    configuration.preferredAssetRepresentationMode = .compatible
                default:
                    configuration.preferredAssetRepresentationMode = .current
                }
            }
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.present(picker, animated: true)
            }
        }
    }
    
    private func formatBytes(_ bytes: Double) -> String {
        let kb = bytes / 1024
        let mb = kb / 1024
        let gb = mb / 1024
        
        if gb >= 1 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.2f KB", kb)
        } else {
            return String(format: "%.0f bytes", bytes)
        }
    }
    
    private func orientationString(_ orientation: UIImage.Orientation) -> String {
        switch orientation {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        case .upMirrored: return "UpMirrored"
        case .downMirrored: return "DownMirrored"
        case .leftMirrored: return "LeftMirrored"
        case .rightMirrored: return "RightMirrored"
        @unknown default: return "Unknown"
        }
    }
}

@available(iOS 14, *)
extension MetaPhotoPickerPlugin: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            flutterResult?(nil) // User cancelled
            return
        }
        
        let compressionQuality = (pickerConfig?["compressionQuality"] as? Double) ?? 0.8
        let group = DispatchGroup()
        var photoInfoList: [[String: Any]] = []
        
        for result in results {
            group.enter()
            
            let itemProvider = result.itemProvider
            let assetIdentifier = result.assetIdentifier
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self, let image = image as? UIImage else {
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                        group.leave()
                        return
                    }
                    
                    // Get file name
                    var fileName = "Unknown"
                    if let suggestedName = itemProvider.suggestedName {
                        fileName = suggestedName
                    } else {
                        fileName = "Image_\(Date().timeIntervalSince1970).jpg"
                    }
                    
                    // Get file type
                    var fileType = "JPEG"
                    if let typeIdentifier = itemProvider.registeredTypeIdentifiers.first {
                        if typeIdentifier.contains("png") {
                            fileType = "PNG"
                        } else if typeIdentifier.contains("heic") {
                            fileType = "HEIC"
                        } else if typeIdentifier.contains("gif") {
                            fileType = "GIF"
                        } else if typeIdentifier.contains("jpeg") || typeIdentifier.contains("jpg") {
                            fileType = "JPEG"
                        }
                    }
                    
                    // Convert image to data without compression
                    var imageData: Data?
                    if fileType == "PNG" {
                        imageData = image.pngData()
                    } else if fileType == "HEIC" {
                        // For HEIC, try to get original data first
                        imageData = image.jpegData(compressionQuality: 1.0)
                    } else {
                        // For JPEG and others, use maximum quality (no compression)
                        imageData = image.jpegData(compressionQuality: 1.0)
                    }
                    
                    guard let data = imageData else {
                        group.leave()
                        return
                    }
                    
                    // Calculate file size
                    let bytes = Double(data.count)
                    let fileSize = self.formatBytes(bytes)
                    
                    // Get dimensions
                    let width = Int(image.size.width)
                    let height = Int(image.size.height)
                    
                    // Note: We don't fetch creation date from PHAsset to avoid requiring photo library permission
                    // PHPicker is privacy-preserving and doesn't need permission
                    // Use current date as fallback
                    let creationDate = ISO8601DateFormatter().string(from: Date())
                    
                    // Create photo info dictionary
                    let photoInfo: [String: Any] = [
                        "id": UUID().uuidString,
                        "fileName": fileName,
                        "fileSizeBytes": data.count,
                        "fileSize": fileSize,
                        "dimensions": [
                            "width": width,
                            "height": height
                        ],
                        "creationDate": creationDate as Any,
                        "fileType": fileType,
                        "assetIdentifier": assetIdentifier as Any,
                        "imageData": FlutterStandardTypedData(bytes: data),
                        "scale": image.scale,
                        "orientation": self.orientationString(image.imageOrientation)
                    ]
                    
                    photoInfoList.append(photoInfo)
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.flutterResult?(photoInfoList)
        }
    }
}
