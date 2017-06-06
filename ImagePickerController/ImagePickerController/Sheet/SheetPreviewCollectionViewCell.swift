//
//  SheetPreviewCollectionViewCell.swift
//  ImagePickerController
//
//  Created by sunny on 2017/6/5.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

class SheetPreviewCollectionViewCell: SheetCollectionViewCell {

    
    var collectionView: PreviewCollectionView? {
        willSet {
            if let collectionView = collectionView {
                collectionView.removeFromSuperview()
            }
            
            if let collectionView = newValue {
                addSubview(collectionView)
            }
        }
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        collectionView = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView?.frame = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
    }


}
