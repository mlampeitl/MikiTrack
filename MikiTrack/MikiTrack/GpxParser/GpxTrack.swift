//
//  GpxTrack.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 07.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Foundation

class GpxTrack
{
    var trackPoints: [GpxTrackPoint] = [];
    private var _trackName: String? = nil;
    
    init()
    {
        self._trackName = nil;
        self.trackPoints = [];
    }
    
    var trackName : String?
    {
        get { return _trackName; }
        set {_trackName = newValue; }
    }
}
