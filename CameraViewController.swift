//
//  CameraViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/5/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

var jsonDict:NSMutableDictionary = [:]

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var changeView: UIBarButtonItem!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    var session: AVCaptureSession?
    var videoOutput :  AVCaptureMovieFileOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice! = nil
    var camera : Bool = true
    @IBOutlet weak var IndicatorOutlet: UIActivityIndicatorView!
    
    let manager = CLLocationManager()
//    let jsonFile = FileSaveHelper(fileName: "gps", fileExtension: .JSON, subDirectory: "selfDrivingJson", directory: .documentDirectory)
    
    var latitude = ""
    var longitude = ""
    var timer = Timer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initiateVideoCamera()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        jsonDict["longitude"] = []
        jsonDict["latitude"] = []
        
    }
    
    func initiateVideoCamera(){
        print("Video Camera is Running")
        
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetHigh
        var input : AVCaptureDeviceInput?
        var error: NSError?
        
        if (camera == false) {
            let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            
            for device in videoDevices! {
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.front {
                    captureDevice = device
                    break
                }
            }
        }else{
            captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
        
        do{
            input = try AVCaptureDeviceInput(device: captureDevice)
            
            if error == nil && session!.canAddInput(input){
                session!.addInput(input)
                
                self.videoOutput = AVCaptureMovieFileOutput()
                
                if session!.canAddOutput(videoOutput){
                    session!.addOutput(videoOutput)
                    
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
//                    let connection =  videoOutput?.connection(withMediaType: AVMediaTypeVideo)
//                    if (connection?.isVideoOrientationSupported)! {
//                        connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//                        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//                    }else{
//                        connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//                        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//                    }
                    videoPreviewLayer!.frame = cameraView.frame
                    cameraView.layer.addSublayer(videoPreviewLayer!)
                    
                    session!.startRunning()
                }
            }
            
        }catch let err as NSError{
                error = err
                input = nil
                print(error!.localizedDescription)
            }
        }
    
    //switch front and back camera
    @IBAction func switchCamera(_ sender: Any) {
        self.camera = !camera
        session!.stopRunning()
        videoPreviewLayer!.removeFromSuperlayer()
        initiateVideoCamera()
    }
    
    //click buttom site start recording
    @IBAction func capVideo(_ sender: Any) {
        let fileName = "gpsVideo.mp4"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent(fileName)
        if self.videoOutput!.isRecording{
            self.videoOutput!.stopRecording()
            self.navigationItem.hidesBackButton = false
            self.changeView.isEnabled = true
            self.recordBtn.setImage(#imageLiteral(resourceName: "capture"), for: UIControlState())
            self.IndicatorOutlet.isHidden = false
            self.IndicatorOutlet.startAnimating()
            manager.stopUpdatingLocation()
            timer.invalidate()
            
            return
        }else{
            //begin video capture
            self.recordBtn.setImage(#imageLiteral(resourceName: "video_record"), for: UIControlState())
            self.changeView.isEnabled = false
            self.navigationItem.hidesBackButton = true
            self.videoOutput?.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
            //beginning write gps record
            manager.startUpdatingLocation()
            eachSecAppendJSON()
        }
    }
    
    //get full video path
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error) {
        doVideoProcessing(outputFileURL)
    }
    
    //do ouput
    func doVideoProcessing(_ outputPath:URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputPath)
        }) { (success, error) in
            if error == nil{
                print("Save video is success:\(success)")
                DispatchQueue.main.async(execute: {
                    self.IndicatorOutlet!.stopAnimating()
                    self.showAlert("Saved", message: "Video saved to Photos")
                })
            }
            else{
                DispatchQueue.main.async(execute: {
                    self.IndicatorOutlet!.stopAnimating()
                    self.showAlert("Error", message: error!.localizedDescription)
                })
            }
        }
    }
    
    //get user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //set location to dictionary
        self.latitude = String(myLocation.latitude)
        self.longitude = String(myLocation.longitude)
    }
    
    //each second run this function to save data
    func eachSecAppendJSON(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.appendJson), userInfo: nil, repeats: true)
    }
    
    //add json data to dictionary
    func appendJson(){
        if var long = jsonDict["longitude"] as? [String] {
            long.append(longitude)
            jsonDict["longitude"] = long
        }
        if var lati = jsonDict["latitude"] as? [String] {
            lati.append(latitude)
            jsonDict["latitude"] = lati
        }
    }
    
    //alert message
    func showAlert(_ title: String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(done)
        self.present(alert, animated: false, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {_ in
            let orient = UIApplication.shared.statusBarOrientation
            let connection = self.videoOutput?.connection(withMediaType: AVMediaTypeVideo)
            switch (orient){
            case .landscapeRight:
                    connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                    self.videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                    self.videoPreviewLayer!.frame = self.cameraView.frame
                break
            case .portrait:
                connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                self.videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                self.videoPreviewLayer!.frame = self.cameraView.frame
                break
            default:
                break
            }
        })
    }
}

