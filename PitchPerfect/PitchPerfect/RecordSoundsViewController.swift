//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Aniket Ghode on 3/22/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    
    // MARK: RecordingState (raw values correspond to sender tags)
    
    enum RecordingState { case recording, notRecording }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.notRecording)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        configureUI(.notRecording)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Recording was not successful", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { alertAction in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    func configureUI(_ recorderState: RecordingState){
        switch recorderState {
        case .notRecording:
            recordingButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = "Tap to Record."
        case .recording:
            recordingLabel.text = "Recording in Progress."
            stopRecordingButton.isEnabled = true
            recordingButton.isEnabled = false
        }
    }
}

