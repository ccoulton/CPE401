//
//  ViewController.swift
//  Assignment3
//
//  Created by Charles Coulton on 4/6/15.
//  Copyright (c) 2015 Charles Coulton. All rights reserved.
//

import UIKit
import CoreFoundation

class ViewController: UIViewController, NSStreamDelegate {

    @IBOutlet weak var Host_Port: UITextField!
    @IBOutlet weak var Host_Name: UITextField!
    @IBOutlet weak var User_Name: UITextField!
    @IBAction func Host_connect(sender: UIButton) {
        var TCPin: Unmanaged<CFReadStream>?
        var TCPout: Unmanaged<CFWriteStream>?
        var Port: UInt32
        if let number = self.Host_Port.text.toInt()
            {
            Port = UInt32(number)
            }
        else{
            println("\(self.Host_Port.text) is not a number")
            Port = 1111
        }
        let TCPalloc: CFAllocator!
        //try to connect to server
        CFStreamCreatePairWithSocketToHost(TCPalloc,
            self.Host_Name.text!,
            Port,
            &TCPin,
            &TCPout)
        //var opened = CFWriteStreamOpen(TCPout.CFWriteStream!)
        var streamIn: NSStream?
        var streamOut: NSStream?
        
        streamOut = TCPout!.takeRetainedValue()
        streamIn = TCPin!.takeRetainedValue()
        streamIn?.delegate = self
        ste
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
    }

}

