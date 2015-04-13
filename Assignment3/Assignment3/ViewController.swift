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

    //func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
    //}

}

class GetReginfo: UIViewController{
    
    let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
    
    
    @IBOutlet weak var FName: UITextField!
    @IBOutlet weak var LName: UITextField!
    @IBAction func Register(sender:UIButton){
		sender.enabled = false;    
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
		    var temp: NSString
		    temp = "REGISTER "
		    var buffer: NSString
		    buffer = temp.stringByAppendingString(self.mainApp.UserName! as String) //add user name
		    buffer = buffer.stringByAppendingString(" ")  //add a space
		    //wait till registar button returns
		    buffer = buffer.stringByAppendingString(self.FName.text as String)  //add first name to string
		    buffer = buffer.stringByAppendingString(" ")
		    buffer = buffer.stringByAppendingString(self.LName.text as String)  //add last name to string
		    let data: NSData = buffer.dataUsingEncoding(NSUTF8StringEncoding)!
		    mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
		    //read from tcpstreamin
		    //check for ack package
		    var Ack: NSStream = mainApp.ReadFromTCP()
		    //ack split on spaces.
		    sender.enabled = true; //enable button
		})
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

class menuScreen: UIViewController{
    @IBOutlet weak var Keyword: UITextField!
    let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
    var RegInput: GetReginfo?
    //TCP MODUALS
    
    @IBAction func Login(sender: UIButton) {
		sender.enabled = false;  //disable button  
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			var temp: NSString
			temp = "LOGIN "
			var buffer: NSString
			buffer = temp.stringByAppendingString(self.mainApp.UserName! as String)
			let data: NSData = buffer.dataUsingEncoding(NSUTF8StringEncoding)!
			//write to socket
			self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
			//get ack from tpc socket
		   	var ack: NSStream = self.mainApp.ReadFromTCP()
		   	//split ack into ack username ip, and port to set up udp
			//open master UDP socket
			//make list of peers and set up ports for each
			//send HI message to Peers
			//check that the message whent though
			sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Quit(sender:UIButton){
        //close inputstream and clean up
        sender.enabled = false;   //lock button
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	//close socket 
		    mainApp.TCPStreamIn?.close()
		    //remove from runloop
		    mainApp.TCPStreamIn?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
		    //set to nil to close it out
		    mainApp.TCPStreamIn?.delegate = nil
		    //send out quit message to server
		    var temp: NSString
		    temp = "QUIT "
		    temp = temp.stringByAppendingString(self.mainApp.UserName! as String)
		    let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
		    mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
		    //close output stream and clean up after self
		    mainApp.TCPStreamOut?.close()
		    mainApp.TCPStreamOut?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
		    mainApp.TCPStreamOut?.delegate = nil
			sender.enabled = true; //enable button
		})
        //close UDP sockets
        //close master UDP socket
    }
    
    @IBAction func Update(sender:UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //ask for xml file
        //put in "UPDATE "
        //append xml file to string
        //check for bytes avaiable
        //send on socket
        //check that the file has been sent
        //read on socket for success
        //var ack: NSStream = self.mainApp.ReadFromTCP()
        //ack.split()
        //if ack[0] == success good
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Search(sender:UIButton){
        //keyword is in self.Keyword
        if self.Keyword.text == nil{//if textbox was empty
            return}
        else{
            sender.enabled = false;
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //append SEARCH and keyword to data
                var temp: NSString
                temp = NSString(format: "%@", "SEARCH ")
                temp = temp.stringByAppendingString(self.Keyword.text)
                let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
                //write to socket
                self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                //read from socket
                /*var resultBuffer:NSMutableData = NSMutableData(length: 1024)!
                var bytesRead:Int = 0
                bytesRead = self.mainApp.TCPStreamIn?.read(UnsafeMutablePointer<UInt8>(resultBuffer.mutableBytes), maxLength: 1024) as Int!
                resultBuffer.length = bytesRead;
                var result = NSString(data: resultBuffer, encoding: NSUTF8StringEncoding)!
                print(result)*/
               	self.mainApp.ReadFromTCP()
                //display resulting xml
                
                sender.enabled = true;
            })
        }
    }
    
    @IBAction func Chat(sender:UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //create new view controller
        //ask for which peer to talk to
        	var temp: NSString = NSString(format: "%@%@%@", "CHAT ", self.mainApp.UserName, " ")
        	//get peer's master udp and chat stream
        	//temp = temp.stringByAppendingString(chat stream)
        	let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
        	//send to udpsocket
        	//self.mainApp.peersudp.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length) //send to peerudp
        	//UDP chat will handle incoming  
        //send "chat
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Friend(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //ask user for friendship
        	var temp: NSString = NSString(format: "%@%@", "FRIEND ", self.mainApp.UserName) 
        //write "FRIEND "+UserName
        //peer sends back REJECT or ACCEPT out if accept get new udp socket for that peer
        //if reject don't make a new udp peer
        //let master UDP socket handle response
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Post(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	var temp: NSString = NSString(format: "%@%@%@", "POST ", self.mainApp.UserName, " ") 
        //push content as xml file marked for friends
       	//temp = temp.appendWithString(NSString(format: "%@%@%@" xml file length, " ", xml file)
        //friends of friends or public
        //if public send to server to update profile
            //and online friends, who flood it to all
            //friends online replacing userid so that
            //sent friend doesn't get it, check from
        //if fof send to friends changing the flag
            //so it's not broadcast again
            //change flag to friends 
        //friends flag causes end of transmission
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Entries(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	var temp: NSString = NSString(format: "%@%@%@", "ENTRIES ", self.mainApp.UserName, " ")
        	//temp = temp.appendwithstring(timestamp)
        //get all wall posts since time in reverse 
        //chronological order
        	sender.enabled = true; //enable button
		})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    	}
    
    }

