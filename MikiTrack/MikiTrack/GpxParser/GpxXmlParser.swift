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

    private let _trackElementKey: String = "trk";
    private let _trackNameElementKey: String = "name";
    private let _trackPointElementKey: String = "trkpt";
    private let _elevationElementKey: String = "ele";
    private let _timeStampElementKey: String = "time";
    
    
    
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
        if elementName == _trackElementKey
        {
            _inTrack = true
            _currentTrack = GpxTrack();
        }
        // Track embedded
        if _inTrack
        {
            if (elementName == _trackNameElementKey)
            {
                _currentString = "";
            }
        }

        // TrackPoint
        if elementName == _trackPointElementKey
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
            if (elementName == _elevationElementKey)
                || (elementName == _timeStampElementKey)
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
        if _inTrack && (elementName == _trackNameElementKey)
        {
            let myName:String? = _currentString;
            if _currentTrack != nil
            {
                _currentTrack!.trackName = myName;
            }
            _currentString = nil;
        }
        // End of Track
        if _inTrack && (elementName == _trackElementKey)
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
        if _inTrackPoint && (elementName == _elevationElementKey)
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
        if _inTrackPoint && (elementName == _timeStampElementKey)
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
        if _inTrackPoint && (elementName == _trackPointElementKey)
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
