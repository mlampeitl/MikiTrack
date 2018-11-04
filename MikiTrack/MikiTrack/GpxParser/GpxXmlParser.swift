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
    
    private let cTrackPointElementKey: String = "trkpt";
    private let cElevationElementKey: String = "ele";
    private let cTimeStampElementKey: String = "time";
    private var inTrackPoint: Bool = false;
    
    
    
    init (gpxString : String) throws
    {
        if gpxString.isEmpty { throw GpxParserError.gpxIsEmpty }
        
        theGpxString = gpxString
        
        // Init Parser
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
    }
    
    // Sart Element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        
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
            theCurrentTrackpoint = nil;
            theCurrentString = nil;
            inTrackPoint = false;
        }
    }
}
