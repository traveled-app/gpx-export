//
//  ExportGpx.swift
//  GoCalendar
//
//  Created by david on 10/17/19.
//  Copyright © 2019 Go To Labs. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class MessageWithSubject: NSObject, UIActivityItemSource {

    let subject:String
    let message:String

    init(subject: String, message: String) {
        self.subject = subject
        self.message = message

        super.init()
    }
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return message
    }
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}

@objcMembers class ExportGPX:NSObject {
    static func export(locations:[CLLocation], presenter:UIViewController) {
        NSLog("Export %ld events", locations.count)
        if locations.count > 0 {
            let header = ["<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
                          "<gpx xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\"",
                          "creator=\"Traveled App\"",
                          "version=\"1.1\"",
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"",
                          "xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\">",
                          ""
            ]
            let file = "traveled.gpx"
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = dir.appendingPathComponent(file)
                //writing
                var gpx = ""
                
                // gpx xml header
                for line in header {
                    gpx += line
                    gpx += "\n"
                }
                // gpx locations
                for i in locations {
                    // try "wpt" attributes: name, cmt, desc
                    gpx += "  <wpt lat=\"\(i.coordinate.latitude)\" lon=\"\(i.coordinate.longitude)\"></wpt>\n"
                }
                gpx += "\n</gpx>\n"
                do{
                    // write file
                    try gpx.write(to: fileURL, atomically: false, encoding: .utf8)
                }catch{
                    print("error writing")
                }
                // set up activity view
                let mws = MessageWithSubject.init(subject: "Traveled GPX File Export", message: "Attached is a GPX file containing the location of every place visited while using the Traveled app.")
                
                // present activity view
                let activ = UIActivityViewController.init(activityItems: [mws, fileURL], applicationActivities: nil)
                //activ.excludedActivityTypes = [UIActivityViewController.Type]
                presenter.present(activ, animated: true) {
                }
            }
        }
        else {
            self.alertError(message: "\nNo events available for export in the specified time range\n\nGPX file not exported", presenter: presenter)
        }
    }
    
    static func alertError(message: String, presenter: UIViewController)
    {
        let ac = UIAlertController.init(title: "Notice", message: message, preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.destructive, handler: nil))
        presenter.present(ac, animated: true, completion: nil)
    }
}
