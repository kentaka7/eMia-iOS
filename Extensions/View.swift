//
//  View.swift
//  eMia
//

import UIKit

extension UIView {
   
   func shake() {
      let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
      animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
      animation.duration = 0.6
      animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
      layer.add(animation, forKey: "shake")
   }
   
   class func loadFrom(nibNamed: String, bundle: Bundle? = nil) -> UIView? {
      return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
   }
   
   func testAnimation() {
      let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn) {[weak self] in
         guard let `self` = self else {
            return
         }
         self.backgroundColor = UIColor(hexString: "000000")
      }
      animator.startAnimation()
   }
   
   var screenshot: UIImage? {
      let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
      let image = renderer.image { _ in
         self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
      }
      return image
   }
   
   var screenshot2: UIImage?
   {
      var image: UIImage?
      UIGraphicsBeginImageContext(self.bounds.size)
      if let context = UIGraphicsGetCurrentContext() {
         self.layer.render(in: context)
         image = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
      }
      return image
   }
   
   // It returns view with screenshot already (?)
   var snapshot: UIView? {
      let snapshot = self.snapshotView(afterScreenUpdates: true)
      return snapshot
   }
   
   @discardableResult
   public func setAsCircle() -> Self {
      self.clipsToBounds = true
      let frameSize = self.frame.size
      self.layer.cornerRadius = min(frameSize.width, frameSize.height) / 2.0
      return self
   }

   var x: CGFloat {
      get {
         return self.frame.origin.x
      }
      set {
         self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.size.width,
                             height: self.frame.size.height)
      }
   }
   
   var y: CGFloat {
      get {
         return self.frame.origin.y
      }
      set {
         self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.size.width,
                             height: self.frame.size.height)
      }
   }
   
   var width: CGFloat {
      get {
         return self.frame.size.width
      }
      set {
         self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue,
                             height: self.frame.size.height)
      }
   }
   
   var height: CGFloat {
      get {
         return self.frame.height
      }
      set {
         self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width:
            self.frame.size.width, height: newValue)
      }
   }
}
