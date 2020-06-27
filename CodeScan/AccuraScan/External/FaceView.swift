//

import UIKit
import AccuraOCR
import FaceMatchSDK

class FaceView: UIView {

    var faceImage: UIImage? = nil
    var faceRegion: NSFaceRegion? = nil

    override func draw(_ rect: CGRect) {
        guard let image = faceImage else { return }
        
        let rect = self.bounds
        let fx = rect.size.width * 1.0  / image.size.width
        let fy = rect.size.height * 1.0 / image.size.height
        
        var f = fx
        if f > fy {
            f = fy
        }
        
        let dw = f * image.size.width
        let dh = f * image.size.height
        let dx = (rect.size.width - dw) / 2
        let dy = (rect.size.height - dh) / 2
        image.draw(in: CGRect(x: dx, y: dy, width: dw, height: dh))
        
        guard let region = self.faceRegion else { return }
        
        if region.face == 1 {
            UIColor.green.set()
            let currentContext = UIGraphicsGetCurrentContext()
            
            let x1 = region.bound.origin.x * f + dx
            let x2 = (region.bound.origin.x + region.bound.size.height) * f + dx
            let y1 = region.bound.origin.y * f + dy
            let y2 = (region.bound.origin.y + region.bound.size.height) * f + dy
            
            /* Set the width for the line */
            currentContext?.setLineWidth(2.0)
            
            /* Start the line at this point */
            currentContext?.move(to: CGPoint(x: x1, y: y1))
            
            /* And end it at this point */
            currentContext?.addLine(to: CGPoint(x: x2, y: y1))
            currentContext?.addLine(to: CGPoint(x: x2, y: y2))
            currentContext?.addLine(to: CGPoint(x: x1, y: y2))
            currentContext?.addLine(to: CGPoint(x: x1, y: y1))
            
            /* Use the context's current color to draw the line */
            currentContext?.strokePath()
        }
    }
    
    func getFaceRegion() -> NSFaceRegion? {
        return faceRegion
    }
    
    func setFaceRegion(_ region: NSFaceRegion?) {
        self.faceRegion = region
    }
    
    func getImage() -> UIImage? {
        return faceImage
    }
    
    func setImage(_ image: UIImage?) {
        self.faceImage = image
    }
}
