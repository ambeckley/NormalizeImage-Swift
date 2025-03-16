# NormalizeImage Swift Package

A Swift package that helps preprocess images for machine learning models by resizing and normalizing them to match the typical input format required by models, such as ImageNet normalization. The package works with iOS platforms.

## Features

- Resize images to a target size (e.g., 384x384).
- Convert images into a `MLMultiArray` for CoreML model input.
- Normalize images based on ImageNet mean and standard deviation values.
- Supports both iOS (via `UIKit`) support needs to be added to support MacOS (via `AppKit`)

## Requirements

- Swift 5.0 or higher
- Xcode 12.0 or higher
- iOS 13.0+ or macOS 10.15+ (depending on your platform)

## Installation

You can install the `NormalizeImage` package via Swift Package Manager. To integrate it into your project:

1. Open your Xcode project.
2. Go to `File` > `Swift Packages` > `Add Package Dependency...`.
3. Enter the URL for this repository
4. Select the version you'd like to use.

## Usage

### Importing the Package

To use this package in your project, import it as follows:

```swift
import NormalizeImage
import UIKit
import CoreML

// Create an instance of NormalizeImage
let imageNormalizer = NormalizeImage()

// Load an image (e.g., from assets or camera)
guard let image = UIImage(named: "example_image.png") else {
    print("Failed to load image.")
    return
}

// Define the target width and height (e.g., 384x384)
let targetWidth = 384
let targetHeight = 384

// Preprocess the image
if let processedImageArray = imageNormalizer.preprocessImage(image: image, width: targetWidth, height: targetHeight) {
    print("Image successfully preprocessed and converted to MLMultiArray.")
    
    // You can now use the `processedImageArray` with your CoreML model:
    // let prediction = try model.prediction(input: processedImageArray)
} else {
    print("Failed to preprocess image.")
}
```



   

