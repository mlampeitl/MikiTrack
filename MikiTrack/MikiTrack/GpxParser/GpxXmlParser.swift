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
    private var _gpx: String = "";
    private var _gpxData: Data;
    private var _xmlParser: XMLParser;
    private var _trackPoints: [GpxTrackPoint]?;
    private var _currentTrackPoint: GpxTrackPoint?;
    private var _currentString: String?;
    private var _tracks: [GpxTrack]?;
    private var _currentTrack: GpxTrack? = nil;

    private var _inTrackPoint: Bool = false;
    private var _inTrack: Bool = false;

    private let cTrackElementKey: String = "trk";
    private let cTrackNameElementKey: String = "name";
    private let cTrackPointElementKey: String = "trkpt";
    private let cElevationElementKey: String = "ele";
    private let cTimeStampElementKey: String = "time";
    
    
    
    init (gpxString : String) throws
    {
        if gpxString.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        _gpx = gpxString
        
        // Init Parser
        _currentTrack = nil;
        _gpxData = Data(_gpx.utf8);
        _xmlParser = XMLParser(data: _gpxData);

        super.init();
        _xmlParser.delegate = self;
        _xmlParser.parse();

    }
    
    // Start Document >> Initalize the GPX Structure
    func parserDidStartDocument(_ parser: XMLParser) {
        _trackPoints = [];
        _currentTrackPoint = nil;
        _currentString = nil;
        _currentTrack = nil;
        _tracks = [];
    }
    
    // Sart Element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        // Track
        if elementName == cTrackElementKey
        {
            _inTrack = true
            _currentTrack = GpxTrack();
        }
        // Track embedded
        if _inTrack
        {
            if (elementName == cTrackNameElementKey)
            {
                _currentString = "";
            }
        }

        // TrackPoint
        if elementName == cTrackPointElementKey
        {
            _inTrackPoint = true
            
            // Get lat/lon
            let myLatString:String? = attributeDict["lat"];
            let myLonString:String? = attributeDict["lon"];

            // Create a new trackpoint
            _currentTrackPoint = GpxTrackPoint();
            //Lat
            if !(myLatString == nil && myLatString!.isEmpty)
            {
                let myLat = (myLatString! as NSString).doubleValue
                _currentTrackPoint?.lattitude = myLat;
            }
            
            //Lon
            if !(myLonString == nil && myLonString!.isEmpty)
            {
                let myLon = (myLonString! as NSString).doubleValue
                _currentTrackPoint?.longitude = myLon;
            }

        }
        
        // TrackPoint embedded
        if _inTrackPoint
        {
            if (elementName == cElevationElementKey)
                || (elementName == cTimeStampElementKey)
            {
                _currentString = "";
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if _currentString != nil
        {
            _currentString = String(_currentString!) + string;
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        //Track / Name
        if _inTrack && (elementName == cTrackNameElementKey)
        {
            let myName:String? = _currentString;
            if _currentTrack != nil
            {
                _currentTrack!.trackName = myName;
            }
            _currentString = nil;
        }
        // End of Track
        if _inTrack && (elementName == cTrackElementKey)
        {
            // Add Track to Array
            if (_tracks != nil) && (_currentTrack != nil)
            {
                _tracks!.append(_currentTrack!);
            }
            
            // Reset variables
            _currentTrack = nil;
            _currentString = nil;
            _inTrack = false;
        }


        // TrackPoint / Elevation
        if _inTrackPoint && (elementName == cElevationElementKey)
        {
            let myEleString:String? = _currentString;
            if !(myEleString == nil && myEleString!.isEmpty)
            {
                let myEle = (myEleString! as NSString).doubleValue
                _currentTrackPoint?.elevation = myEle;
            }
            _currentString = nil;
        }

        // TrackPoint / Time
        if _inTrackPoint && (elementName == cTimeStampElementKey)
        {
            let myTimestampString:String? = _currentString;
            if !(myTimestampString == nil && myTimestampString!.isEmpty)
            {
                let myDateFormatter = ISO8601DateFormatter();
                let myTimestamp = myDateFormatter.date(from: myTimestampString!);
                _currentTrackPoint?.timestamp = myTimestamp;
            }
            _currentString = nil;
        }

        
        // End of Trackpoint
        if _inTrackPoint && (elementName == cTrackPointElementKey)
        {
            // Add TrackPoint to Array
            if (_trackPoints != nil) && (_currentTrackPoint != nil)
            {
                _trackPoints!.append(_currentTrackPoint!);
            }
            if _inTrack && (_currentTrack != nil)
            {
                _currentTrack!.trackPoints.append(_currentTrackPoint!);
            }
            
            // Reset variables
            _currentTrackPoint = nil;
            _currentString = nil;
            _inTrackPoint = false;
        }
    }
}
