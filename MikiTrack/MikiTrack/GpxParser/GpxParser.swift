//
//  GpxParser.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 04.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Foundation

class GpxParser
{
    var theGpxString : String = ""

    init ()
    {
        theGpxString = "";
    }
    
    convenience init (gpx : String) throws
    {
        // Init
        self.init();
        
        // Method contract
        if gpx.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        //set the gpx string
        theGpxString = gpx;
    }
    
    convenience init(gpxFileName : String) throws
    {
        // Init
        self.init();
        
        // Load the GPX file to the gpx string
        try loadGpxFile(gpxFileName: gpxFileName)
    }

    convenience init(gpxFileName : String, parse : Bool) throws
    {
        // Load file
        try self.init(gpxFileName: gpxFileName);
        
        // Parse string
        if parse
        {
            try self.parse()
        }
    }

    convenience init(gpx : String, parse : Bool) throws
    {
        // Set gpx string
        try self.init(gpx: gpx);
        
        // Parse string
        if parse
        {
            try self.parse()
        }
    }
    
    func loadGpxFile(gpxFileName : String) throws
    {
        // Method contract
        if gpxFileName.isEmpty { throw GpxParserError.fileNameIsEmpty }
        
        // File exists and is readable
        let myFileMan = FileManager.default;
        if !myFileMan.fileExists(atPath: gpxFileName) { throw GpxParserError.fileNotFound }
        if !myFileMan.isReadableFile(atPath: gpxFileName) { throw GpxParserError.fileNotReadable }

        // Load File
        var myString: String;

        // Read File
        do {
            try myString = String(contentsOfFile: gpxFileName)
        }
        catch
        {
            throw GpxParserError.readFileContentsError(readError: error)
        }
        
        if myString.isEmpty
        {
            throw GpxParserError.fileIsEmpty
        }
        theGpxString = myString;
        
    }
    
    func parse(gpxFileName: String) throws
    {
        // Method contract
        if gpxFileName.isEmpty { throw GpxParserError.fileNameIsEmpty }
        
        //Load gpx file
        try loadGpxFile(gpxFileName: gpxFileName);
        
        //Parse
        try parse();
    }

    func parse(gpx: String) throws
    {
        // Method contract
        if gpx.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        // Set gpx string
        theGpxString = gpx;
        
        //Parse
        try parse();
    }

    func parse() throws
    {
        // Check if gpxString is not empty
        if theGpxString.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        // Create GpxXmlParser
        var myParser: GpxXmlParser;
        try myParser = GpxXmlParser(gpxString: theGpxString);
                
    }
    
}
