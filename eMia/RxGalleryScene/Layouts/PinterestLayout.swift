import UIKit

protocol PinterestLayoutDelegate: class {
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection: Int) -> Int
}

class PinterestLayout: UICollectionViewFlowLayout {

   weak var delegate: PinterestLayoutDelegate!
   
   private var numberOfColumns = 2
   private var cellPadding: CGFloat = 6
   
   private var cache = [UICollectionViewLayoutAttributes]()
   
   fileprivate var contentHeight: CGFloat = 0
   
   private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
         return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
   }
   
   private var columnWidth: CGFloat {
      return contentWidth / CGFloat(numberOfColumns)
   }
   
   override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
   }
   
   override func prepare() {
      guard cache.isEmpty == true, let collectionView = collectionView else {
         return
      }
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
         xOffset.append(CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      for item in 0 ..< delegate.collectionView(collectionView, numberOfItemsinSection: 0) {
         let indexPath = IndexPath(item: item, section: 0)
         let photoSize = delegate.collectionView(collectionView, photoSizeAtIndexPath: indexPath)
         let k = columnWidth / photoSize.width
         let height = photoSize.height * k + cellPadding * 2 + 54.0
         let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
         let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
         let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
         attributes.frame = insetFrame
         cache.append(attributes)
         contentHeight = max(contentHeight, frame.maxY)
         yOffset[column] = yOffset[column] + height
         column = column < (numberOfColumns - 1) ? (column + 1) : 0
      }
   }
   
   override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

      var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
      
      let attributesArray = super.layoutAttributesForElements(in: rect)

      guard let _ = self.collectionView else {
         return attributesArray
      }
      
      for attributes in attributesArray ?? [] {
         if attributes.frame.intersects(rect) {
            // Loop through the cache and look for items in the rect
            for cachedAttr in cache {
               if cachedAttr.frame.intersects(rect) {
                  visibleLayoutAttributes.append(cachedAttr)
                  contentHeight = max(contentHeight, rect.maxY)
               }
            }
         }
      }
      return visibleLayoutAttributes
   }
   
   override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
   }
}
