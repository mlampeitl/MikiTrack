//
//  ViewController.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 04.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var fileNameTextField: NSTextField!
    
    @IBAction func selectFile(_ sender: NSButton)
    {
        //Open Panel
        let myFileDialog = NSOpenPanel();
        myFileDialog.isExtensionHidden = true;
        myFileDialog.canChooseDirectories = false;
        myFileDialog.allowsMultipleSelection = false;
        myFileDialog.allowedFileTypes = ["gpx"]
        
        if(myFileDialog.runModal() == NSApplication.ModalResponse.OK)
        {
            let result = myFileDialog.url
            if (result != nil)
            {
                let path=result!.path
                fileNameTextField.stringValue = path
            }
        }
        else
        {
            return; //User pressed cancel
        }
    }
    
    @IBAction func loadGpxFile(_ sender: NSButton)
    {
        let myFileName: String = fileNameTextField.stringValue;
        
        // Init Parser
        do
        {
            var myGpxParser: GpxParser? = nil;
            try  myGpxParser = GpxParser(gpxFileName: myFileName);
            if myGpxParser != nil
            {
                try myGpxParser!.parse();
            }
        }
        catch is GpxParserError
        {
        }
        catch
        {
            
        }
    }
    
}

