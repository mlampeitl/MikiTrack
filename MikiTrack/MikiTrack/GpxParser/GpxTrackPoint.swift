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
    var lattitude : Double?
    var longitude : Double?
    var elevation : Double?
    var timestamp : Date?
    
    init ()
    {
        lattitude = nil;
        longitude = nil;
        elevation = nil;
        timestamp = nil;
    }
    
    convenience init(ts: Date, lat: Double, lon: Double, ele: Double? = nil)
    {
        self.init();
        lattitude = lat;
        longitude = lon;
        elevation = ele;
        timestamp = ts;
    }

}
