//
//  ViewController.swift
//  Project13_Test
//
//  Created by Sabrina Fletcher on 4/2/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //crashes if you play with sliders before an image is loadeda
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    @IBOutlet weak var radius: UISlider!
    var currentImage: UIImage!
    var currentFilter: CIFilter!
    var context: CIContext!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "InstaFilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")

        if currentImage == nil {
            intensity.isEnabled = false
            radius.isEnabled = false
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        
        dismiss(animated: true)
        
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let img = imageView.image{
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError: contextInfo:)), nil)
        } else{
            let ac = UIAlertController(title: "No Image!", message: "You have not imported an image to alter.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else{
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func applyProcessing() {
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        
       
        let inputKeys = currentFilter.inputKeys
        
        
        if inputKeys.contains(where: {$0.contains(kCIInputIntensityKey) && $0.contains(kCIInputRadiusKey) && $0.contains(kCIInputCenterKey)}){
            intensity.isEnabled = true
            radius.isEnabled = true
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            currentFilter.setValue(radius.value * 300, forKey: kCIInputRadiusKey)
            currentFilter.setValue(CIVector(x:currentImage.size.width / 2, y: currentImage.size.height / 2) , forKey: kCIInputCenterKey)
        }
        
        if inputKeys.contains(where: {$0.contains(kCIInputRadiusKey) && $0.contains(kCIInputScaleKey) && $0.contains(kCIInputCenterKey)}){
            intensity.isEnabled = true
            radius.isEnabled = true
            currentFilter.setValue(radius.value * 300, forKey: kCIInputRadiusKey)
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
            currentFilter.setValue(CIVector(x:currentImage.size.width / 2, y: currentImage.size.height / 2) , forKey: kCIInputCenterKey)
        }
        
        if inputKeys.contains(where: {$0.contains(kCIInputIntensityKey) && $0.contains(kCIInputRadiusKey)}){
            intensity.isEnabled = true
            radius.isEnabled = true
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            currentFilter.setValue(radius.value * 300, forKey: kCIInputRadiusKey)
            
        }
        
        if (inputKeys.contains(where: {$0.contains(kCIInputRadiusKey) && $0.contains(kCIInputScaleKey)})){
            intensity.isEnabled = true
            radius.isEnabled = true
            currentFilter.setValue(radius.value * 300, forKey: kCIInputRadiusKey)
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(where: {$0.contains(kCIInputCenterKey) && $0.contains(kCIInputScaleKey)}){
            radius.isEnabled = false
            intensity.isEnabled = true
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
            currentFilter.setValue(CIVector(x:currentImage.size.width / 2, y: currentImage.size.height / 2) , forKey: kCIInputCenterKey)
        }
        
        if inputKeys.contains(kCIInputIntensityKey){
            intensity.isEnabled = true
            radius.isEnabled = false
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey){
            intensity.isEnabled = false
            radius.isEnabled = true
            currentFilter.setValue(radius.value * 300, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            radius.isEnabled = false
            intensity.isEnabled = true
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey){
            currentFilter.setValue(CIVector(x:currentImage.size.width / 2, y: currentImage.size.height / 2) , forKey: kCIInputCenterKey)
        }

        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
        if currentImage != nil && currentFilter != nil{
            title = currentFilter.name
        }
        
//        if let ciimage =  currentFilter.outputImage{
//            let processedImage = UIImage(ciImage: ciimage)
//            self.imageView.image = processedImage
//        }
      
    }
    
    func setFilter(action: UIAlertAction){
        //make sure we have a valid image before continuing
        
        guard currentImage != nil else { return }
        
        currentFilter = CIFilter(name: action.title!)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        title = currentFilter.name
        
        applyProcessing()
    }
    
}

