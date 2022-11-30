import AVFoundation
import HaishinKit
import UIKit
import CoreVideo

final class PronamaEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CISourceOverCompositing")

    var extent = CGRect.zero {
        didSet {
            if extent == oldValue {
                return
            }
            UIGraphicsBeginImageContext(extent.size)
            let image = UIImage(named: "Icon.png")!
            image.draw(at: CGPoint(x: 50, y: 50))
            pronama = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)
            UIGraphicsEndImageContext()
        }
    }
    var pronama: CIImage?

    override init() {
        super.init()
    }

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        extent = image.extent
        filter.setValue(pronama!, forKey: "inputImage")
        filter.setValue(image, forKey: "inputBackgroundImage")
        return filter.outputImage!
    }
}

final class MonochromeEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CIColorMonochrome")

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        return filter.outputImage!
    }
}

final class FaceUnityEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CIColorControls")

   
    override init() {
        super.init()
    }
    
    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        guard let info = info else {
            return image
        }
        let pixelBuffer = CMSampleBufferGetImageBuffer(info)
        guard let renderedPixelBuffer = FUManager.share().renderItems(to: pixelBuffer) else {
            return image
        }
        filter.setValue(CIImage(cvPixelBuffer: renderedPixelBuffer.takeUnretainedValue()), forKey: "inputImage")
        filter.setValue(0.8, forKey: "inputSaturation")
//        filter.setValue(1.0, forKey: "inputBrightness")
        filter.setValue(1.0, forKey: "inputContrast")
        return filter.outputImage!
    }
}

