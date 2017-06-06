//
//  SheetController.swift
//  ImagePickerController
//
//  Created by sunny on 2017/6/5.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

let sheetInset: CGFloat = 10

class SheetController: NSObject {
    
    fileprivate(set) lazy var sheetCollectionView: UICollectionView = {
        let layout = SheetCollectionViewLayout()
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "com.cepheus.imagePicker"
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.register(SheetPreviewCollectionViewCell.self, forCellWithReuseIdentifier: SheetPreviewCollectionViewCell.identifier)
        collectionView.register(SheetActionCollectionViewCell.self, forCellWithReuseIdentifier: SheetActionCollectionViewCell.identifier)
       return collectionView
    }()
    
    var previewCollectionView: PreviewCollectionView
    
    fileprivate(set) var actions = [ImagePickerAction]()
    
    var actionHandlingCallBack: (() -> ())?
    
    fileprivate(set) var previewHeight: CGFloat = 0
    var numberOfSelectionImages = 0
    
    var preferredSheetHeight: CGFloat {
        return allIndexPath().map { self.sizeForSheetItemAt($0).height }.reduce(0, +)
    }
    
    init(previewCollectionView: PreviewCollectionView) {
        self.previewCollectionView = previewCollectionView
        
        super.init()
    }

    
    // MARK: - Data Source
    
    fileprivate func numberOfSections() -> Int {
        return 2
    }
    
    
    fileprivate func numberOfItemsInSection(_ section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return actions.count
    }
    

    fileprivate func allIndexPath() -> [IndexPath] {
        let s = numberOfSections()
        return (0 ..< s).map{ (section: Int) -> (Int, Int) in (self.numberOfItemsInSection(section), section) }.flatMap { (numberOfItems: Int, section: Int) -> [IndexPath] in
            (0 ..< numberOfItems).map { (item: Int) -> IndexPath in IndexPath(item: item, section: section) }    
        }
    }
    
    fileprivate func sizeForSheetItemAt(_ indexPath: IndexPath) -> CGSize {
        let height: CGFloat = {
            if indexPath.section == 0 {
                return previewHeight
            }
            let actionItemheight: CGFloat = 57
            let insets = attributesForItemAtIndexPath(indexPath).backgroundInsets
            return actionItemheight + insets.top + insets.bottom
        }()
        return CGSize(width: sheetCollectionView.bounds.width, height: height)
    }
    
    
    
    // MARK: - Design
    
    fileprivate func attributesForItemAtIndexPath(_ indexPath: IndexPath) -> (corners: RoundedCorner, backgroundInsets: UIEdgeInsets) {
        let cornerRadius: CGFloat = 13
        let innerInset: CGFloat = 4
        var indexPaths = allIndexPath()
        
        guard indexPaths.first != indexPath else {
            return (.top(cornerRadius), UIEdgeInsets(top: 0, left: CGFloat(sheetInset), bottom: 0, right: CGFloat(sheetInset)))
        }
        
        let cancelIndexPath = actions.index { $0.style == ImagePickerActionStyle.cancel }
            .map { IndexPath(item: $0, section: 1) }
        
        
        if let cancelIndexPath = cancelIndexPath {
            if cancelIndexPath == indexPath {
                return (.all(cornerRadius), UIEdgeInsets(top: innerInset, left: sheetInset, bottom: sheetInset, right: sheetInset))
            }
            
            indexPaths.removeLast()
            
            if indexPath == indexPaths.last {
                return (.bottom(cornerRadius), UIEdgeInsets(top: 0, left: CGFloat(sheetInset), bottom: CGFloat(innerInset), right: CGFloat(sheetInset)))
            }
        }
        else if indexPath == indexPaths.last {
            return (.bottom(cornerRadius), UIEdgeInsets(top: 0, left: CGFloat(sheetInset), bottom: CGFloat(sheetInset), right: CGFloat(sheetInset)))
        }
        
        return (.none, UIEdgeInsets(top: 0, left: CGFloat(sheetInset), bottom: 0, right: CGFloat(sheetInset)))
    }
    
    // MARK: - Actions
    
    func reloadActionItems() {
        sheetCollectionView.reloadSections(IndexSet(integer: 1))
    }

    fileprivate func fontForAction(_ action: ImagePickerAction) -> UIFont {
        if action.style == .cancel {
            return UIFont.boldSystemFont(ofSize: 21)
        }
        return UIFont.systemFont(ofSize: 21)
    }
    
    func addAction(_ action: ImagePickerAction) {
        if action.style == .cancel {
            actions = actions.filter { $0.style != .cancel }
        }
        
        actions.append(action)
        
        if let index = actions.index(where: { $0.style == .cancel }) {
            let cancelAction = actions.remove(at: index)
            actions.append(cancelAction)
        }
        
        reloadActionItems()
    }
    
    func removeAllActions() {
        actions = []
        reloadActionItems()
    }

    fileprivate func handleAction(_ action: ImagePickerAction) {
        actionHandlingCallBack?()
        action.handle(numberOfSelectionImages)
    }
    
    func handleCancelAction() {
        let cancelAction = actions.filter { $0.style == .cancel }
            .first
        
        if let cancelAction = cancelAction {
            handleAction(cancelAction)
        }
        else {
            actionHandlingCallBack?()
        }
    }
    
    func setPreviewHeight(_ height: CGFloat, invalidateLayout: Bool) {
        previewHeight = height
        if invalidateLayout {
            sheetCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}


extension SheetController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SheetCollectionViewCell
        
        if indexPath.section == 0 {
            let previewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SheetPreviewCollectionViewCell.identifier, for: indexPath) as! SheetPreviewCollectionViewCell
            previewCell.collectionView = previewCollectionView
            
            cell = previewCell
        }
        else {
            let action = actions[indexPath.item]
            let actionCell = collectionView.dequeueReusableCell(withReuseIdentifier: SheetActionCollectionViewCell.identifier, for: indexPath) as! SheetActionCollectionViewCell
            actionCell.textLabel.font = fontForAction(action)
            actionCell.textLabel.text = numberOfSelectionImages > 0 ? action.secondaryTitle(numberOfSelectionImages) : action.title
            
            cell = actionCell
        }
        
        cell.separatorVisible = (indexPath.section == 1)
        
        // iOS specific design
        (cell.roundedCorners, cell.backgroundInsets) = attributesForItemAtIndexPath(indexPath)
        cell.normalBackgroundColor = UIColor(white: 0.97, alpha: 1)
        cell.highlightedBackgroundColor = UIColor(white: 0.92, alpha: 1)
        cell.separatorColor = UIColor(white: 0.84, alpha: 1)
        
        return cell


    }
}

extension SheetController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        handleAction(actions[indexPath.item])
    }
}


extension SheetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForSheetItemAt(indexPath)
    }
    
}










