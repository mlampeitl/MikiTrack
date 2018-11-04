//
//  GpxParserError.swift
//  MikiTrack
//
//  Created by Michael Lampeitl on 04.11.18.
//  Copyright © 2018 AlienTec. All rights reserved.
//

import Foundation

enum GpxParserError : Error {
    case fileNameIsEmpty
    case fileNotFound
    case fileNotReadable
    case fileIsEmpty
    case readFileContentsError (readError: Error)
    case gpxIsEmpty
}
