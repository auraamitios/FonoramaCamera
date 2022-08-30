//
//  ViewController.swift
//  FanoramaCamera
//
//  Created by Tripathi, Amitkumar on 30/08/22.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    /// Capture session
    var session: AVCaptureSession?
    /// Photo output
    let output = AVCapturePhotoOutput()
    /// Video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    /// shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.green, for: .normal)
        return button
    }()
    
    let clickedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        
        shutterButton.addTarget(self, action: #selector(shutterButtonClicked(_:)), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)

        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2,
                                       y: view.frame.size.height - 60)
        resetButton.center = CGPoint(x: view.safeAreaInsets.left + 50,
                                     y: view.safeAreaInsets.top + 10)
        clickedImageView.frame = CGRect(x: view.safeAreaInsets.left + 50,
                                        y: view.safeAreaInsets.top + 30,
                                        width: 180,
                                        height: 250)
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    strongSelf.setUpCamera()
                }
            }
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch {
                print(error)
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func shutterButtonClicked(_ sender: UIButton) {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
        
    }
    
    @objc private func resetButtonClicked(_ sender: UIButton) {
        
        clickedImageView.removeFromSuperview()
        session?.startRunning()
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return}
        let image = UIImage(data: data)
        
        /// stop the running session after getting the image
        session?.stopRunning()
        
//        let imageView = UIImageView(image: image)
//        imageView.contentMode = .scaleAspectFill
//        imageView.frame = view.bounds
//        view.addSubview(imageView)
//
        view.addSubview(clickedImageView)
        clickedImageView.image = image
        view.addSubview(resetButton)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
