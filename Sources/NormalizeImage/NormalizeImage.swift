// The Swift Programming Language
// https://docs.swift.org/swift-book
// Written by Aaron Beckley
// March 16 2025


import CoreML
import CoreImage
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit //Support needs to be added for Appkit with NSImage instead of UIImage
#endif

public struct NormalizeImage {
    public func preprocessImage(image: UIImage, width: Int, height: Int) -> MLMultiArray? {
        // Resize image to 384x384 (or other required size for the model)
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: width, height: height)) else {
            print("Failed to resize image.")
            return nil
        }

        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: resizedImage) else {
            print("Failed to convert UIImage to CIImage.")
            return nil
        }

        // Convert CIImage to a 3D tensor (MultiArray)
        guard let multiArray = createMultiArray(from: ciImage) else {
            print("Failed to convert CIImage to MLMultiArray.")
            return nil
        }

        // Normalize the MultiArray (ImageNet mean and std values)
        normalizeMultiArray(multiArray)

        return multiArray
    }


    // Resize UIImage to the target size
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }


    // Convert CIImage to MLMultiArray
    func createMultiArray(from ciImage: CIImage) -> MLMultiArray? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            //print("Failed to create CGImage from CIImage.")
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        let channels = 3 // RGB channels

        // Create MLMultiArray with Double precision (64-bit)
        do {
            let multiArray = try MLMultiArray(shape: [1, NSNumber(value: channels), NSNumber(value: height), NSNumber(value: width)], dataType: .double) // Use .double for higher precision
            
            let pixelData = cgImage.dataProvider?.data
            guard let pixelBytes = CFDataGetBytePtr(pixelData) else {
                print("Failed to get pixel data.")
                return nil
            }

            
            
            // Loop through the pixels and populate the MultiArray with Double precision values
            for y in 0..<height {
                for x in 0..<width {
                    let pixelIndex = (y * width + x) * 4  // BGRA format, 4 bytes per pixel (including alpha)
                    
                    for c in 0..<3 { // RGB channels
                        let pixelValue = Double(pixelBytes[pixelIndex + c]) / 255.0  // Normalize to [0, 1] using Double
                        multiArray[[0, NSNumber(value: c), NSNumber(value: y), NSNumber(value: x)]] = NSNumber(value: pixelValue)
                    }
                }
            }
            
            return multiArray
        } catch {
            print("Error creating MLMultiArray: \(error)")
            return nil
        }
    }


    // Normalize the MultiArray based on ImageNet mean and std values
    func normalizeMultiArray(_ multiArray: MLMultiArray) {
        let mean: [Double] = [0.485, 0.456, 0.406] // Use Double precision for mean
        let std: [Double] = [0.229, 0.224, 0.225] // Use Double precision for std

        let count = multiArray.count
        var pixelCount = 0 // Counter for //printing normalized pixel values
        
        // Now perform normalization based on mean and std
        for i in 0..<count {
            let value = multiArray[i].doubleValue  // Use doubleValue for Double precision
            let c = i % 3  // For RGB channels
            let normalizedValue = (value - mean[c]) / std[c]
            multiArray[i] = NSNumber(value: normalizedValue)
            
            pixelCount += 1
        }
    }


}


