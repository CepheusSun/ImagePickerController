//
//  SheetCollectionViewLayout.swift
//  ImagePickerController
//
//  Created by sunny on 2017/6/5.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

class SheetCollectionViewLayout: UICollectionViewFlowLayout {

    fileprivate var layoutAttributes = [[UICollectionViewLayoutAttributes]]()
    fileprivate var invalidatedAttributes: [[UICollectionViewLayoutAttributes]]?
    fileprivate var contentSize = CGSize.zero
    
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        
        layoutAttributes.removeAll(keepingCapacity: false)
        contentSize = CGSize.zero
        
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            let sections = dataSource.numberOfSections?(in: collectionView) ?? 0
            var origin = CGPoint()
            
            for section in 0 ..< sections {
                var sectionAttributes = [UICollectionViewLayoutAttributes]()
                let items = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                let indexPaths = (0 ..< items).map { IndexPath(item: $0, section: section) }
                
                for indexPath in indexPaths {
                    let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? CGSize.zero
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect(origin: origin, size: size)
                    
                    sectionAttributes.append(attributes)
                    origin.y = attributes.frame.maxY
                }
                
                layoutAttributes.append(sectionAttributes)
            }
            
            contentSize = CGSize(width: collectionView.frame.width, height: origin.y)
        }

    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        invalidatedAttributes = layoutAttributes
        super.invalidateLayout()
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.reduce([], +).filter{ rect.intersects($0.frame) }
    }
    
    private func layoutAttributesForItem(At indexPath: IndexPath,
                                         allAttributes: [[UICollectionViewLayoutAttributes]]) -> UICollectionViewLayoutAttributes? {
        
        guard allAttributes.count > indexPath.section && allAttributes[indexPath.section].count > indexPath.item else {
            return nil
        }
        
        return allAttributes[indexPath.section][indexPath.item]
    }
    
    private func invalidatedLayoutAttributes(ForItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let invalidatedLayoutAttributes = invalidatedAttributes else {
            return nil
        }
        
        return layoutAttributesForItem(At: indexPath, allAttributes: invalidatedLayoutAttributes)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return invalidatedLayoutAttributes(ForItemAt: itemIndexPath) ?? layoutAttributesForItem(at: itemIndexPath)
    }
}
