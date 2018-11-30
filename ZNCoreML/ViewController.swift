//
//  ViewController.swift
//  ZNCoreML
//
//  Created by xinpin on 2018/11/29.
//  Copyright © 2018年 Nix. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifier: UILabel!
    @IBOutlet weak var visionClassifier: UILabel!
    
    lazy var model: Inceptionv3 = {
        var model = Inceptionv3()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func camera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) { return }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = true
        present(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func coreMLPredictionWithInceptionv3FromImage(_ image: UIImage) {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        guard let prediction = try? model.prediction(image: newImage.buffer()!) else { return }
        DispatchQueue.main.async {
            self.classifier.text = "ML 识别结果:\(prediction.classLabel), 匹配率:\(prediction.classLabelProbs[prediction.classLabel] ?? 0)."
        }
        print("ML 识别结果:\(prediction.classLabel), 匹配率:\(prediction.classLabelProbs[prediction.classLabel] ?? 0).")
    }
    
    func visionPredictionWithInceptionv3FromImage(_ image: UIImage) {
        
        let cgImage = image.cgImage!
        var vnCoreMLModel: VNCoreMLModel!
        do {
            vnCoreMLModel = try VNCoreMLModel(for: model.model)
        } catch {
            print(error)
            return
        }
        
        let handle = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
        let request = VNCoreMLRequest.init(model: vnCoreMLModel) { [weak self] (request, error) in
            var confidence: Float = 0.0
            var tempClassification: VNClassificationObservation?
            for classification in request.results! {
                guard let cf = classification as? VNClassificationObservation else { continue }
                if (cf.confidence > confidence) {
                    confidence = cf.confidence
                    tempClassification = cf
                }
            }
            DispatchQueue.main.async {
                self?.visionClassifier.text = "Vision 识别结果:\(tempClassification?.identifier ?? "None"), 匹配率:\(tempClassification?.confidence ?? 0)"
            }
            print("Vision 识别结果:\(tempClassification?.identifier ?? "None"), 匹配率:\(tempClassification?.confidence ?? 0)")
        }
        
        do {
            try handle.perform([request])
        } catch {
            print(error)
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        imageView.image = image

        classifier.text = "ML: Analyzing Image..."
        visionClassifier.text = "Vision: Analyzing Image..."
        
        let group = DispatchGroup.init()
        let mlQueue: DispatchQueue = DispatchQueue.init(label: "mlQueue")
        let visionQueue: DispatchQueue = DispatchQueue.init(label: "visionQueue")
        mlQueue.async (group: group) {
            self.coreMLPredictionWithInceptionv3FromImage(image)
        }
        visionQueue.async (group: group){
            // 耗时相对较长
            self.visionPredictionWithInceptionv3FromImage(image)
        }
        group.notify(queue: DispatchQueue.main) {
            print("end")
        }
        
        /*
        classifier.text = "ML: Analyzing Image..."
        coreMLPredictionWithInceptionv3FromImage(image)

        visionClassifier.text = "Vision: Analyzing Image..."
        visionPredictionWithInceptionv3FromImage(image)
        */
    }
}

