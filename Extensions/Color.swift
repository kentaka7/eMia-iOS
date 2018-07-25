//
//  Color.swift
//  eMia
//

import UIKit

// MARK: - Color types
enum ColorType: UInt32 {
   case pink = 0xff3366
   case crimson = 0xb8083e
   case burgundy = 0x56071f
   case blue = 0x0081f4
   case gray = 0x979797
   case darkGray = 0x3D3D3D
   case lime = 0x70ff00
   
   var color: UIColor { return UIColor(self) }
}

// MARK: - Initialization
extension UIColor {
   
   convenience init(_ type: ColorType) {
      self.init(rgbValue: type.rawValue)
   }
   
   convenience init(rgbaValue: UInt32) {
      let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
      let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
      let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
      let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0
      
      self.init(red: red, green: green, blue: blue, alpha: alpha)
   }
   
   convenience init(rgbValue: UInt32, alpha: CGFloat = 1) {
      let red   = CGFloat((rgbValue >> 16) & 0xff) / 255.0
      let green = CGFloat((rgbValue >>  8) & 0xff) / 255.0
      let blue  = CGFloat((rgbValue      ) & 0xff) / 255.0
      
      self.init(red: red, green: green, blue: blue, alpha: alpha)
   }
   
   convenience init(hexString: String) {
      let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
      var int = UInt32()
      Scanner(string: hex).scanHexInt32(&int)
      let alpha, red, green, blue: UInt32
      switch hex.count {
      case 3: // RGB (12-bit)
         (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
      case 6: // RGB (24-bit)
         (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
      case 8: // ARGB (32-bit)
         (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
      default:
         (alpha, red, green, blue) = (1, 1, 1, 0)
      }
      self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
   }
   
   var imageRepresentation: UIImage {
      let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
      UIGraphicsBeginImageContext(rect.size)
      let context = UIGraphicsGetCurrentContext()
      
      context?.setFillColor(self.cgColor)
      context?.fill(rect)
      
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return image!
   }

}

//    MARK - Color scheme
extension UIColor {
   static var tint: UIColor {
      return UIColor.black
   }
   
   enum Navigation {
      static var background: UIColor {
         return GlobalColors.kBrandNavBarColor
      }
      static var tintColor = UIColor.white
   }
   
   enum Background {
      static var forAdditionalInfo = UIColor(rgbValue: 0xfff6f8)
      static var settings = UIColor.white
      static var main = UIColor.white
      
   }
   
   enum TintColor {
      static let textView = UIColor(.blue)
   }
   
   enum Text {
      static let title = UIColor(rgbValue: 0x464646)
      static let subtitle = UIColor(rgbValue: 0x838383)
   }
}
