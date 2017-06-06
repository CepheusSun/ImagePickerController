//
//  ImagePickerAction.swift
//  ImagePickerController
//
//  Created by sunny on 2017/6/5.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

public enum ImagePickerActionStyle {
    case `default`
    case cancel
}

open class ImagePickerAction {
    public typealias Title = (Int) -> String
    public typealias Handler = (ImagePickerAction) -> ()
    public typealias SecondaryHandler = (ImagePickerAction, Int) -> ()
    
    open let title: String
    open let secondaryTitle: Title
    open let style: ImagePickerActionStyle

    
    fileprivate let handler: Handler?
    fileprivate let secondaryHandler: SecondaryHandler?
    
    public init(cancelTitle: String) {
        self.title = cancelTitle
        self.secondaryTitle = {_ in cancelTitle}
        self.style = .cancel
        self.handler = nil
        self.secondaryHandler = nil
    }
    
    public convenience init(title: String,
                            secondaryTitle: String? = nil,
                            style: ImagePickerActionStyle = .default,
                            handler: @escaping Handler,
                            secondaryHandler: SecondaryHandler? = nil) {
        let sendaryClosure: Title = {_ in return secondaryTitle ?? "" }
        self.init(title: title,
                  secondary: sendaryClosure,
                  style: style,
                  handler: handler,
                  secondaryHandler: secondaryHandler)
    }
    
    public init(title: String,
                secondary: Title?,
                style: ImagePickerActionStyle = .default,
                handler: @escaping Handler,
                secondaryHandler secondaryHandlerOrNil: SecondaryHandler? = nil) {
        
        var secondaryHandler = secondaryHandlerOrNil
        if secondaryHandler == nil {
            secondaryHandler = { action, _ in
                handler(action)
            }
        }
        
        self.title = title
        self.secondaryTitle = secondary ?? { _ in title }
        self.style = style
        self.handler = handler
        self.secondaryHandler = secondaryHandler
    }
    
    func handle(_ numberOfImages: Int = 0) {
        if numberOfImages > 0 {
            secondaryHandler?(self, numberOfImages)
        }
        else {
            handler?(self)
        }
    }
    
}

infix operator ??

fileprivate func ?? (left: ImagePickerAction.Title?, right: @escaping ImagePickerAction.Title) -> ImagePickerAction.Title {
    if let left = left {
        return left
    }
    
    return right
}
