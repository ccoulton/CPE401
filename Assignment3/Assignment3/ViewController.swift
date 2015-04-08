//
//  ViewController.swift
//  Assignment3
//
//  Created by Charles Coulton on 4/6/15.
//  Copyright (c) 2015 Charles Coulton. All rights reserved.
//

import UIKit
import CoreFoundation
//import bridge

class InputScreen: UIViewController{

    @IBOutlet weak var Host_Port: UITextField!
    @IBOutlet weak var Host_Name: UITextField!
    @IBOutlet weak var User_Name: UITextField!
    @IBAction func Host_connect(sender: UIButton) {
        var Port: UInt32
        var Host: NSString
        Host = self.Host_Name.text
        /*var addr: sockaddr
        
        TCPsock = socket(AF_INET, SOCK_STREAM)
        //bind(TCPsock, addr, <#socklen_t#>)*/
        if let number = self.Host_Port.text.toInt()
            {
            Port = UInt32(number)
            }
        else{
            print(self.Host_Port.text)
            Port = 0
        }
        //
        let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
        mainApp.TCPconnect(Host, host_Port: Port)
        mainApp.UserName = self.User_Name.text
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

class menuScreen: UIViewController{
    let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
    
    @IBAction func Login(sender: UIButton) {
        var temp: NSString
        temp = "LOGIN "
        var buffer: NSString
        buffer = temp.stringByAppendingString(mainApp.UserName!)
        let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
        mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }//*/
   @IBAction func Quit(sender:UIButton)
    {
    mainApp.TCPStreamIn?.close()
    //mainApp.TCPStreamOut?.write("QUIT ", maxLength: 1024)
    mainApp.TCPStreamOut?.close()
    
    }//*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    	}
    
    }

