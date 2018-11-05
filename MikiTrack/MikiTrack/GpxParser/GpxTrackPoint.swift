//
//  GpxTrackPoint.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 04.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Foundation

class GpxTrackPoint
{
    private var _hash : Data?
    private var _lattitude : Double?
    private var _longitude : Double?
    private var _elevation : Double?
    private var _timestamp : Date?
    
    init ()
    {
        _hash = nil;
        _lattitude = nil;
        _longitude = nil;
        _elevation = nil;
        _timestamp = nil;
    }
    
    convenience init(ts: Date, lat: Double, lon: Double, ele: Double? = nil)
    {
        self.init();
        _lattitude = lat;
        _longitude = lon;
        _elevation = ele;
        _timestamp = ts;
    }

    ///
    /// Properties
    ///
    var lattitude : Double?
    {
        get { return _lattitude; }
        set { _lattitude = newValue; }
    }
    var longitude : Double?
    {
        get { return _longitude; }
        set { _longitude = newValue; }
    }
    var elevation : Double?
    {
        get { return _elevation; }
        set { _elevation = newValue; }
    }
    var timestamp : Date?
    {
        get { return _timestamp; }
        set { _timestamp = newValue; }
    }
    
    //Calculate hash
    private func calculateHash()
    {
        var myLatStr = "";
        var myLonStr = "";
        var myTsStr = "";
        if _lattitude != nil { myLatStr = String(_lattitude!); }
        if _longitude != nil { myLonStr = String(_longitude!); }
        if _timestamp != nil { myTsStr = ISO8601DateFormatter().string(from: _timestamp!); }
        let myString = String("\(myLatStr)|\(myLonStr)|\(myTsStr)");
        
        //ToDo: Implement CryptoSwift
    }
}
