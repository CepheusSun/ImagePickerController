//
//  ViewController.swift
//  ImagePickerController
//
//  Created by sunny on 2017/6/5.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .system)
        button.setTitle("Tap Me!", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(presentImagePickerSheet(_:)), for: .touchUpInside)
        
    }

    // MARK: - Other Methods
    
    func presentImagePickerSheet(_ gestureRecognizer: UITapGestureRecognizer) {
        
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .photoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.present(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerController(mediaType: .imageAndVideo)
        controller.addAction(ImagePickerAction(title: "拍照",
                                               secondaryTitle: "确认",
                                               handler: { _ in presentImagePickerController(.camera) },
                                               secondaryHandler: { idx, numberOfPhotos in }))
        
        controller.addAction(ImagePickerAction(title: "从相册获取",
                                               secondaryTitle: nil,
                                               handler: { _ in presentImagePickerController(.photoLibrary) },
                                               secondaryHandler: { _, numberOfPhotos in }))
        
        controller.addAction(ImagePickerAction(cancelTitle: "取消"))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = self.view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: self.view.center, size: CGSize())
        }
        self.present(controller, animated: true, completion: nil)
            
      
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

