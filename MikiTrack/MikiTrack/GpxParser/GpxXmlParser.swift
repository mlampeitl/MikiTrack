//
//  GpxXmlParser.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 04.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Foundation

class GpxXmlParser :  NSObject, XMLParserDelegate
{
    private var theGpxString: String = "";
    private var theGpxData: Data;
    private var theXmlParser: XMLParser;
    private var theTrackpoints: [GpxTrackPoint]?;
    private var theCurrentTrackpoint: GpxTrackPoint?;
    private var theCurrentString: String?;
    private var _tracks: [GpxTrack]?;
    private var _currentTrack: GpxTrack? = nil;

    private var inTrackPoint: Bool = false;
    private var inTrack: Bool = false;

    private let cTrackElementKey: String = "trk";
    private let cTrackNameElementKey: String = "name";
    private let cTrackPointElementKey: String = "trkpt";
    private let cElevationElementKey: String = "ele";
    private let cTimeStampElementKey: String = "time";
    
    
    
    init (gpxString : String) throws
    {
        if gpxString.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        theGpxString = gpxString
        
        // Init Parser
        _currentTrack = nil;
        theGpxData = Data(theGpxString.utf8);
        theXmlParser = XMLParser(data: theGpxData);

        super.init();
        theXmlParser.delegate = self;
        theXmlParser.parse();

    }
    
    // Start Document >> Initalize the GPX Structure
    func parserDidStartDocument(_ parser: XMLParser) {
        theTrackpoints = [];
        theCurrentTrackpoint = nil;
        theCurrentString = nil;
        _currentTrack = nil;
        _tracks = [];
    }
    
    // Sart Element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        // Track
        if elementName == cTrackElementKey
        {
            inTrack = true
            _currentTrack = GpxTrack();
        }
        // Track embedded
        if inTrack
        {
            if (elementName == cTrackNameElementKey)
            {
                theCurrentString = "";
            }
        }

        // TrackPoint
        if elementName == cTrackPointElementKey
        {
            inTrackPoint = true
            
            // Get lat/lon
            let myLatString:String? = attributeDict["lat"];
            let myLonString:String? = attributeDict["lon"];

            // Create a new trackpoint
            theCurrentTrackpoint = GpxTrackPoint();
            //Lat
            if !(myLatString == nil && myLatString!.isEmpty)
            {
                let myLat = (myLatString! as NSString).doubleValue
                theCurrentTrackpoint?.lattitude = myLat;
            }
            
            //Lon
            if !(myLonString == nil && myLonString!.isEmpty)
            {
                let myLon = (myLonString! as NSString).doubleValue
                theCurrentTrackpoint?.longitude = myLon;
            }

        }
        
        // TrackPoint embedded
        if inTrackPoint
        {
            if (elementName == cElevationElementKey)
                || (elementName == cTimeStampElementKey)
            {
                theCurrentString = "";
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if theCurrentString != nil
        {
            theCurrentString = String(theCurrentString!) + string;
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        //Track / Name
        if inTrack && (elementName == cTrackNameElementKey)
        {
            let myName:String? = theCurrentString;
            if _currentTrack != nil
            {
                _currentTrack!.trackName = myName;
            }
            theCurrentString = nil;
        }
        // End of Track
        if inTrack && (elementName == cTrackElementKey)
        {
            // Add Track to Array
            if (_tracks != nil) && (_currentTrack != nil)
            {
                _tracks!.append(_currentTrack!);
            }
            
            // Reset variables
            _currentTrack = nil;
            theCurrentString = nil;
            inTrack = false;
        }


        // TrackPoint / Elevation
        if inTrackPoint && (elementName == cElevationElementKey)
        {
            let myEleString:String? = theCurrentString;
            if !(myEleString == nil && myEleString!.isEmpty)
            {
                let myEle = (myEleString! as NSString).doubleValue
                theCurrentTrackpoint?.elevation = myEle;
            }
            theCurrentString = nil;
        }

        // TrackPoint / Time
        if inTrackPoint && (elementName == cTimeStampElementKey)
        {
            let myTimestampString:String? = theCurrentString;
            if !(myTimestampString == nil && myTimestampString!.isEmpty)
            {
                let myDateFormatter = ISO8601DateFormatter();
                let myTimestamp = myDateFormatter.date(from: myTimestampString!);
                theCurrentTrackpoint?.timestamp = myTimestamp;
            }
            theCurrentString = nil;
        }

        
        // End of Trackpoint
        if inTrackPoint && (elementName == cTrackPointElementKey)
        {
            // Add TrackPoint to Array
            if (theTrackpoints != nil) && (theCurrentTrackpoint != nil)
            {
                theTrackpoints!.append(theCurrentTrackpoint!);
            }
            if inTrack && (_currentTrack != nil)
            {
                _currentTrack!.trackPoints.append(theCurrentTrackpoint!);
            }
            
            // Reset variables
            theCurrentTrackpoint = nil;
            theCurrentString = nil;
            inTrackPoint = false;
        }
    }
}
